param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("plan-on", "plan-off", "status")]
    [string]$Action
)

$ErrorActionPreference = "Stop"
$AwsProfile = "terraform-lab"
$AwsRegion  = "us-east-1"
$AsgName    = "dev-web-asg"
$VpcId      = "vpc-0607d04ce59f4bff7"
$AlbName    = "dev-devops-lab-alb"

# Ejecutar siempre desde el directorio del script.
Set-Location $PSScriptRoot

switch ($Action) {

    "plan-on" {
        Write-Host "Preparing LAB ON plan..." -ForegroundColor Yellow

        terraform plan `
            -var-file="lab.on.tfvars" `
            -out="tfplan-lab-on"

        if ($LASTEXITCODE -ne 0) {
            throw "LAB ON plan failed."
        }

        Write-Host "`nPlan saved: tfplan-lab-on" -ForegroundColor Green
        Write-Host "Review before applying:"
        Write-Host "terraform show tfplan-lab-on"
    }

    "plan-off" {
        Write-Host "Preparing LAB OFF plan..." -ForegroundColor Cyan

        terraform plan `
            -var-file="lab.off.tfvars" `
            -out="tfplan-lab-off"

        if ($LASTEXITCODE -ne 0) {
            throw "LAB OFF plan failed."
        }

        Write-Host "`nPlan saved: tfplan-lab-off" -ForegroundColor Green
        Write-Host "Review before applying:"
        Write-Host "terraform show tfplan-lab-off"
    }

        "status" {
        Write-Host "`n=== LAB STATUS ===" -ForegroundColor Cyan

        # Auto Scaling Group
        $asgJson = aws autoscaling describe-auto-scaling-groups `
            --auto-scaling-group-names $AsgName `
            --region $AwsRegion `
            --profile $AwsProfile `
            --output json

        if ($LASTEXITCODE -ne 0) {
            throw "Unable to query Auto Scaling Group."
        }

        $asg = ($asgJson | ConvertFrom-Json).AutoScalingGroups |
            Select-Object -First 1

        if ($null -eq $asg) {
            throw "Auto Scaling Group not found."
        }

        $desired = [int]$asg.DesiredCapacity
        $instances = @($asg.Instances).Count

        Write-Host "ASG desired capacity: $desired"
        Write-Host "Instances registered in ASG: $instances"

        # NAT Gateway: count available, pending and deleting gateways.
        $natJson = aws ec2 describe-nat-gateways `
            --filter "Name=vpc-id,Values=$VpcId" `
            --region $AwsRegion `
            --profile $AwsProfile `
            --output json

        if ($LASTEXITCODE -ne 0) {
            throw "Unable to query NAT Gateways."
        }

        $nat = @(($natJson | ConvertFrom-Json).NatGateways |
            Where-Object { $_.State -ne "deleted" })

        Write-Host "NAT Gateways not fully deleted: $($nat.Count)"

        # Application Load Balancer
        $albJson = aws elbv2 describe-load-balancers `
            --region $AwsRegion `
            --profile $AwsProfile `
            --output json

        if ($LASTEXITCODE -ne 0) {
            throw "Unable to query Load Balancers."
        }

        $albs = @(($albJson | ConvertFrom-Json).LoadBalancers |
            Where-Object { $_.LoadBalancerName -eq $AlbName })

        Write-Host "LAB ALBs found: $($albs.Count)"

        # Interface Endpoints
        $endpointJson = aws ec2 describe-vpc-endpoints `
            --filters "Name=vpc-id,Values=$VpcId" `
            --region $AwsRegion `
            --profile $AwsProfile `
            --output json

        if ($LASTEXITCODE -ne 0) {
            throw "Unable to query VPC Endpoints."
        }

        $interfaces = @(($endpointJson | ConvertFrom-Json).VpcEndpoints |
            Where-Object {
                $_.VpcEndpointType -eq "Interface" -and
                $_.State -ne "deleted"
            })

        Write-Host "Interface Endpoints not fully deleted: $($interfaces.Count)"

        if (
            $desired -eq 0 -and
            $instances -eq 0 -and
            $nat.Count -eq 0 -and
            $albs.Count -eq 0 -and
            $interfaces.Count -eq 0
        ) {
            Write-Host "`nLAB appears OFF" -ForegroundColor Green
        }
        else {
            Write-Host "`nLAB is ON or transitioning" -ForegroundColor Yellow
        }

        Write-Host "Note: This is not a complete AWS billing audit."
    }
}
