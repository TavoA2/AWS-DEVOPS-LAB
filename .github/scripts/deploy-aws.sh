#!/usr/bin/env bash
set -euo pipefail

DEPLOY_STATE=${DEPLOY_STATE:-${RUNNER_TEMP:?}/aws-deployment}

template_address=module.autoscaling.aws_launch_template.web
refresh_preferences=MinHealthyPercentage=50,InstanceWarmup=180,SkipMatching=true

asg() {
  aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" --output json |
    jq -ce '.AutoScalingGroups | select(length == 1) | .[0]'
}

latest_refresh() {
  aws autoscaling describe-instance-refreshes --auto-scaling-group-name "$ASG_NAME" \
    --query 'InstanceRefreshes[0].InstanceRefreshId' --output text
}

refresh_status() {
  aws autoscaling describe-instance-refreshes --auto-scaling-group-name "$ASG_NAME" \
    --instance-refresh-ids "$1" --query 'InstanceRefreshes[0].Status' --output text
}

terminal() {
  case "$1" in
    Successful|Failed|Cancelled|RollbackSuccessful|RollbackFailed) return 0 ;;
    *) return 1 ;;
  esac
}

wait_success() {
  local status
  for ((attempt = 0; attempt < 40; attempt++)); do
    status=$(refresh_status "$1")
    echo "Refresh $1: $status"
    if [[ "$status" == Successful ]]; then return 0; fi
    if terminal "$status"; then return 1; fi
    sleep 30
  done
  echo "Timed out waiting for refresh $1" >&2
  return 1
}

template_image() {
  aws ec2 describe-launch-template-versions --launch-template-id "$1" --versions "$2" \
    --query 'LaunchTemplateVersions[0].LaunchTemplateData.UserData' --output text |
    base64 --decode | awk '$1 == "docker" && $2 == "pull" && NF == 3 { print $3 }'
}

start_refresh() {
  aws autoscaling start-instance-refresh --auto-scaling-group-name "$ASG_NAME" \
    --strategy Rolling --preferences "$refresh_preferences" \
    --desired-configuration "LaunchTemplate={LaunchTemplateId=$template_id,Version=$1}" \
    --query 'InstanceRefreshId' --output text
}

healthy_targets() {
  local group="$1" version="$2" health
  health=$(aws elbv2 describe-target-health --target-group-arn "$target_group" --output json) || return
  jq -en --argjson group "$group" --argjson health "$health" --arg version "$version" --arg target "$target_group" '
    ($health.TargetHealthDescriptions | map(select(.TargetHealth.State == "healthy") | .Target.Id)) as $healthy
    | ($group.DesiredCapacity > 0)
      and ($group.LaunchTemplate.Version == $version)
      and ($group.TargetGroupARNs == [$target])
      and ([$group.Instances[] | select(.LifecycleState == "InService")] | length == $group.DesiredCapacity)
      and (all($group.Instances[] | select(.LifecycleState == "InService");
        .HealthStatus == "Healthy" and .LaunchTemplate.Version == $version
        and .LaunchTemplate.LaunchTemplateId == $group.LaunchTemplate.LaunchTemplateId
        and (.InstanceId as $id | $healthy | index($id) != null)))' >/dev/null
}

smoke_test() {
  local response
  response=$(curl --fail --silent --show-error --max-time 15 --retry 5 --retry-delay 5 "$alb_url")
  grep -Fq 'AWS DevOps Lab' <<< "$response"
}

validate_application() {
  for ((attempt = 0; attempt < 20; attempt++)); do
    if healthy_targets "$(asg)" "$1"; then
      smoke_test
      return
    fi
    sleep 15
  done
  echo 'The expected ASG instances did not become healthy in the ALB.' >&2
  return 1
}

load_stable() {
  read -r template_id stable_version target_group alb_url previous_refresh < "$DEPLOY_STATE/stable"
}

case "$1" in
  preflight)
    mkdir -p "$DEPLOY_STATE"
    group=$(asg)
    jq -e '.DesiredCapacity > 0 and (.TargetGroupARNs | length == 1)' <<< "$group" >/dev/null || {
      echo 'Deploy requires a running lab with one attached target group.' >&2
      exit 1
    }
    template_id=$(jq -er '.LaunchTemplate.LaunchTemplateId | select(test("^lt-[0-9a-f]+$"))' <<< "$group")
    stable_version=$(jq -er '.LaunchTemplate.Version | select(test("^[1-9][0-9]*$"))' <<< "$group")
    target_group=$(jq -er '.TargetGroupARNs[0]' <<< "$group")
    alb_arn=$(aws elbv2 describe-target-groups --target-group-arns "$target_group" --output json |
      jq -er '.TargetGroups[0].LoadBalancerArns | select(length == 1) | .[0]')
    dns=$(aws elbv2 describe-load-balancers --load-balancer-arns "$alb_arn" --output json |
      jq -er '.LoadBalancers[0] | select(.Type == "application" and .State.Code == "active") | .DNSName')
    alb_url="http://$dns/"
    previous_refresh=$(latest_refresh)
    if [[ "$previous_refresh" != None ]]; then terminal "$(refresh_status "$previous_refresh")"; fi

    stable_image=$(template_image "$template_id" "$stable_version")
    repository="${IMAGE_URI%:*}"
    [[ "$stable_image" == "$repository":* ]]
    stable_tag=$(cut -d: -f2- <<< "$stable_image")
    [[ "$stable_tag" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$ ]]
    aws ecr describe-images --repository-name "$ECR_REPOSITORY" --image-ids imageTag="$stable_tag" >/dev/null
    healthy_targets "$group" "$stable_version"
    smoke_test
    printf '%s %s %s %s %s\n' "$template_id" "$stable_version" "$target_group" "$alb_url" "$previous_refresh" \
      > "$DEPLOY_STATE/stable"
    ;;

  template)
    load_stable
    cd environments/dev
    terraform init -input=false -lockfile=readonly
    # Target the existing template and reject changes to any of its dependencies.
    terraform plan -input=false -lock-timeout=60s -target="$template_address" -out="$DEPLOY_STATE/tfplan"
    terraform show -json "$DEPLOY_STATE/tfplan" | jq -e \
      --arg address "$template_address" --arg id "$template_id" --arg image "$IMAGE_URI" '
      ([.resource_changes[]? | select(.address == $address)] | length == 1)
      and all(.resource_changes[]?;
        (.change.actions == ["no-op"])
        or (.address == $address
          and .change.actions == ["update"]
          and ((.change.before | del(.user_data, .latest_version, .default_version))
            == (.change.after | del(.user_data, .latest_version, .default_version)))
          and ([.change.after_unknown | paths(scalars) as $path
            | select(getpath($path) == true) | $path[0]] - ["latest_version", "default_version"] == [])))
      and any(.resource_changes[]?;
        .address == $address and .change.before.id == $id and .change.after.id == $id
        and (.change.after.user_data | @base64d | split("\n") | index("docker pull " + $image) != null))
    ' >/dev/null || {
      echo 'Refusing plan: expected only an image update to the live launch template.' >&2
      exit 1
    }
    terraform apply -input=false -lock-timeout=60s "$DEPLOY_STATE/tfplan"
    # shellcheck disable=SC2016 # AWS expects the literal version alias.
    version=$(aws ec2 describe-launch-template-versions --launch-template-id "$template_id" \
      --versions '$Latest' --query 'LaunchTemplateVersions[0].VersionNumber' --output text)
    [[ "$version" =~ ^[1-9][0-9]*$ && "$(template_image "$template_id" "$version")" == "$IMAGE_URI" ]]
    printf '%s\n' "$version" > "$DEPLOY_STATE/version"
    ;;

  start)
    load_stable
    version=$(cat "$DEPLOY_STATE/version")
    group=$(asg)
    [[ "$(latest_refresh)" == "$previous_refresh" ]]
    jq -e --arg id "$template_id" '.LaunchTemplate.LaunchTemplateId == $id' <<< "$group" >/dev/null
    healthy_targets "$group" "$stable_version"
    if [[ "$version" == "$stable_version" ]]; then
      echo 'The scanned image is already deployed.'
      exit 0
    fi

    # A previously staged template version must also match the live instance settings.
    aws ec2 describe-launch-template-versions --launch-template-id "$template_id" \
      --versions "$stable_version" "$version" --output json |
      jq -e '
        [.LaunchTemplateVersions[].LaunchTemplateData | del(.UserData)]
        | length == 2 and .[0] == .[1]' >/dev/null || {
          echo 'Refusing refresh: the new template changes live instance settings.' >&2
          exit 1
        }

    refresh_id=$(start_refresh "$version")
    [[ "$refresh_id" =~ ^[a-f0-9-]{36}$ ]]
    printf '%s\n' "$refresh_id" > "$DEPLOY_STATE/refresh"
    echo "Started refresh $refresh_id"
    echo 'started=true' >> "$GITHUB_OUTPUT"
    ;;

  verify)
    load_stable
    if [[ -s "$DEPLOY_STATE/refresh" ]]; then
      wait_success "$(cat "$DEPLOY_STATE/refresh")"
    fi
    validate_application "$(cat "$DEPLOY_STATE/version")"
    ;;

  rollback)
    load_stable
    version=$(cat "$DEPLOY_STATE/version")
    refresh_id=$(cat "$DEPLOY_STATE/refresh")
    [[ "$(latest_refresh)" == "$refresh_id" ]] || {
      echo 'Refusing rollback because the latest refresh belongs to another operation.' >&2
      exit 1
    }
    status=$(refresh_status "$refresh_id")
    case "$status" in
      Pending|InProgress|Baking)
        aws autoscaling cancel-instance-refresh --auto-scaling-group-name "$ASG_NAME" \
          --query 'InstanceRefreshId' --output text | grep -Fx "$refresh_id"
        ;;
      Cancelling) ;;
      *) terminal "$status" ;;
    esac
    for ((attempt = 0; attempt < 20; attempt++)); do
      status=$(refresh_status "$refresh_id")
      if terminal "$status"; then break; fi
      sleep 15
    done
    terminal "$status"
    [[ "$(latest_refresh)" == "$refresh_id" ]]
    asg | jq -e --arg id "$template_id" --arg old "$stable_version" --arg new "$version" '
      .DesiredCapacity > 0 and .LaunchTemplate.LaunchTemplateId == $id
      and (.LaunchTemplate.Version == $old or .LaunchTemplate.Version == $new)' >/dev/null

    rollback_id=$(start_refresh "$stable_version")
    [[ "$rollback_id" =~ ^[a-f0-9-]{36}$ ]]
    wait_success "$rollback_id"
    validate_application "$stable_version"
    echo "Restored launch template $template_id version $stable_version"
    ;;
esac
