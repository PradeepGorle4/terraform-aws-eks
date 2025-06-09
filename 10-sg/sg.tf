module "mysql_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    sg_description = "created for mysql instances in expense-dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "bastion_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_name = "bastion"
    sg_description = "created for bastion instances in expense-dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "alb_ingress_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_name = "app-alb"
    sg_description = "created for Backend App Load balancer in expense-dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "eks_control_plane_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-control-plane"
    sg_description = "created for eks-control-plane in expense-dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}


module "eks_node_sg" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-node"
    sg_description = "created for eks-node in expense-dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}


# port 22, 443, 1194, 943 - ports to be opened for VPN
# module "vpn_sg" {
#     source = "../../terraform-aws-securitygroup"
#     project_name = var.project_name
#     environment = var.environment
#     sg_name = "vpn"
#     sg_description = "created for VPN Instances in expense-dev"
#     vpc_id = data.aws_ssm_parameter.vpc_id.value
#     common_tags = var.common_tags
# }


resource "aws_security_group_rule" "eks_control_plane_node" { # control_plane accepting traffic from Node
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = module.eks_node_sg.sg_id
    security_group_id = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "eks_node_control_plane" { # node accepting traffic from control plane
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = module.eks_control_plane_sg.sg_id
    security_group_id = module.eks_node_sg.sg_id
}


resource "aws_security_group_rule" "eks_node_alb_ingress" { # node accepting traffic from ingress alb
    type = "ingress"
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
    source_security_group_id = module.alb_ingress_sg.sg_id
    security_group_id = module.eks_node_sg.sg_id
}


resource "aws_security_group_rule" "eks_node_vpc" { # node accepting traffic from our VPC
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # our Private IP address range
    security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "eks_node_bastion" { # node accepting traffic from bastion
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.eks_node_sg.sg_id
}


# App ALB accepting traffic from bastion

resource "aws_security_group_rule" "alb_ingress_bastion" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.alb_ingress_sg.sg_id
}


resource "aws_security_group_rule" "alb_ingress_public_https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = module.alb_ingress_sg.sg_id
}


resource "aws_security_group_rule" "alb_ingress_bastion_https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.alb_ingress_sg.sg_id
}

# (snow or jira ticket number) Bastion host should be access from office N/W(i.e. via vpn, connect to office n/w and then access)
resource "aws_security_group_rule" "bastion_public" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Usually u can give your office cidrs or static IP's so that only traffic is allowed from office N/W
    security_group_id = module.bastion_sg.sg_id
}


resource "aws_security_group_rule" "mysql_bastion" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.bastion_sg.sg_id
    security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "mysql_eks_nodes" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = module.eks_node_sg.sg_id
    security_group_id = module.mysql_sg.sg_id
}




