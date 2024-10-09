locals {
  ubuntu_user_data = <<-EOF
              #!/bin/bash

              # Update the package index
              apt-get update -y

              # Install necessary packages for Docker
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common

              # Add Docker's official GPG key
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

              # Set up the Docker stable repository
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

              # Update the package index again
              apt-get update -y

              # Install Docker Engine
              apt-get install -y docker-ce docker-ce-cli containerd.io

              # Start Docker service
              systemctl start docker
              systemctl enable docker

              # Install Nginx
              apt-get install -y nginx

              # Start Nginx
              systemctl start nginx
              systemctl enable nginx

              # Gather system information
              OS_VERSION=$(lsb_release -a 2>/dev/null | grep 'Description' | cut -f2-)
              DISK_SPACE=$(df -h | grep '/$')
              MEMORY=$(free -h)
              PROCESSES=$(ps aux)

              # Create a web page
              cat <<EOT > /var/www/html/index.html
              <html>
              <head><title>Hello World</title></head>
              <body>
              <h1>Hello World</h1>
              <p><strong>OS Version:</strong> $OS_VERSION</p>
              <p><strong>Disk Space:</strong></p><pre>$DISK_SPACE</pre>
              <p><strong>Memory Usage:</strong></p><pre>$MEMORY</pre>
              <p><strong>Running Processes:</strong></p><pre>$PROCESSES</pre>
              </body>
              </html>
              EOT

              # Adjust firewall rules to allow HTTP traffic
              ufw allow 'Nginx HTTP'

              # Restart Nginx to apply changes
              systemctl restart nginx
              EOF

  amazon_linux_user_data = <<-EOF
            #!/bin/bash

            apt-get update -y

            apt-get install -y nginx

            systemctl start nginx
            systemctl enable nginx

            cat <<EOT > /var/www/html/index.html
            <html>
            <head><title>Hello World</title></head>
            <body>
            <h1>Hello World</h1>
            </body>
            </html>
            EOT

            EOF

  instance_type = "t2.micro"
}