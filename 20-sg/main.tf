#this file is creating all security groups and allow ports
#creating mysql security group just group using existing module
module "mysql_sg" {
  source       = "git::https://github.com/venkatswan/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "mysql"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.mysql_sg_tags
}
#creating backend security group
module "backend_sg" {
  source       = "git::https://github.com/venkatswan/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "backend"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.backend_sg_tags
}
#creating frontend security group
module "frontend_sg" {
  source       = "git::https://github.com/venkatswan/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "frontend"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.frontend_sg_tags
}
#creating bastion security group
module "bastion_sg" {
  source       = "git::https://github.com/venkatswan/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "bastion"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.bastion_sg_tags
}

#creating ansible security group
module "ansible_sg" {
  source       = "git::https://github.com/venkatswan/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "ansible"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.ansible_sg_tags
}
#creating security group for application load balancer
module "app_alb_sg" {
  source       = "git::https://github.com/daws-81s/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "app-alb" #expense-dev-app-alb
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.app_alb_sg_tags
}

#creating security group for vpn
module "vpn_sg" {
  source       = "git::https://github.com/daws-81s/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "vpn" #expense-dev-app-alb
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
}


# MySQL allowing connection on 3306 from the instances attached to Backend Security group
# in mysql security group we are adding a ingress rule 
resource "aws_security_group_rule" "mysql_backend" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.backend_sg.id # in inbound added backend_sg to allow backend to connect mysql, in manual will give CIDR
  security_group_id        = module.mysql_sg.id   # where to add -> here it is added in mysql security group
}

# Backend allowing connection on 8080 from the instances attached to Frontend Security group
# # in backend security group we are adding a ingress rule 
# resource "aws_security_group_rule" "backend_frontend" {
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   source_security_group_id = module.frontend_sg.id
#   security_group_id        = module.backend_sg.id
# }

# Frontend allowing connection on 80 from the instances attached to Frontend Security group
# in frontend security group we are adding a ingress rule public need to access fronten [0.0.0.0/0]
# resource "aws_security_group_rule" "frontend_public" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]         # adding CIDR value in ingress rule
#   security_group_id = module.frontend_sg.id # adding cidr value in frontend sg
# }

# MySQL allowing connection on 22 from the bastion
resource "aws_security_group_rule" "mysql_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id        = module.mysql_sg.id
}
# Backend server allowing connection on 22 from the bastion
resource "aws_security_group_rule" "backend_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id        = module.backend_sg.id
}
# Frontend server allowing connection on 22 from the bastion
resource "aws_security_group_rule" "frontend_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id        = module.frontend_sg.id
}
# mysql accepting connection on 22 from the ansible
# resource "aws_security_group_rule" "mysql_ansible" {
#   type                     = "ingress"
#   from_port                = 22
#   to_port                  = 22
#   protocol                 = "tcp"
#   source_security_group_id = module.ansible_sg.id
#   security_group_id        = module.mysql_sg.id
# }
# backend accepting connection on 22 from the ansible
resource "aws_security_group_rule" "backend_ansible" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.ansible_sg.id
  security_group_id        = module.backend_sg.id
}
# frontend allowing connection on 22 from the ansible
resource "aws_security_group_rule" "frontend_ansible" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.ansible_sg.id
  security_group_id        = module.frontend_sg.id
}

# Ansible Server allowing connection on 22 from the public
resource "aws_security_group_rule" "ansible_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ansible_sg.id
}

# Bastion Server allowing connection on 22 from the public
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # company IP Address
  security_group_id = module.bastion_sg.id
}

# Backend Server allowing connection on 22 from the app load balancer
resource "aws_security_group_rule" "backend_app_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.app_alb_sg.id
  security_group_id        = module.backend_sg.id
}

# App ALB accepting connections from bastion
resource "aws_security_group_rule" "app_alb_bastion" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id # adding inbound rule 80 in bastion
  security_group_id        = module.app_alb_sg.id # adding basting sg id in app alb group
}

# VPN accepting connections from public with 22 port
resource "aws_security_group_rule" "vpn_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

# VPN accepting connections from public with 443 port
resource "aws_security_group_rule" "vpn_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

# VPN accepting connections from public with 943 port
resource "aws_security_group_rule" "vpn_public_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

# VPN accepting connections from public with 1194 port
resource "aws_security_group_rule" "vpn_public_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

# application load balancer accecting connection from vpn with 80 port
resource "aws_security_group_rule" "app_alb_vpn" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id        = module.app_alb_sg.id
}

# backend server accecting connection from vpn with 22 port
resource "aws_security_group_rule" "backend_vpn_22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id        = module.backend_sg.id
}

# backend server accecting connection from vpn with 8080 port
resource "aws_security_group_rule" "backend_vpn_8080" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id        = module.backend_sg.id
}