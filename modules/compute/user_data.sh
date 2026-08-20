#!/bin/bash

set -e

dnf install -y nginx

cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS DevOps Lab</title>
</head>
<body>
    <h1>AWS DevOps Lab</h1>
    <h2>Environment: DEV</h2>

    <p>Infrastructure provisioned with Terraform.</p>
    <p>Web server configured automatically with EC2 User Data.</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx