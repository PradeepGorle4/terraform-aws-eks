resource "aws_instance" "this" {
  ami                    = "ami-09c813fb71547fc4f" # This is our join devops AMI
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_all_docker.id]
  # 20GB is not enough
  root_block_device {
    volume_size = 30    # Set root volume size to 50GB
    volume_type = "gp3" # Use gp3 for better performance (optional)
  }
  user_data = file("docker.sh")
  tags = {
    Name = "docker"
  }
}

resource "aws_security_group" "allow_all_docker" {
  name        = "allow_all_docker"
  description = "Allows all inbound traffic and All Outbound traffic"

    ingress = [ 
        {
            description = "Allows all incoming traffic"
            from_port = 0
            to_port = 0
            protocol    = "-1" # All protocols are allowed
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = [  ]
            prefix_list_ids = [  ]
            security_groups = [  ]
            self = false
        }
     ]

    egress = [ 
        {
            description = "Allows all outgoing traffic"
            from_port   = 0
            to_port     = 0
            protocol    = "-1" # All protocols are allowed
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = [  ]
            prefix_list_ids = [  ]
            security_groups = [  ]
            self = false
        }
     ]  

  tags = {
    Name = "allow_tls"
  }
}

output "docker_ip" {
  value = aws_instance.this.public_ip
}

