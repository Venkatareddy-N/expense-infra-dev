# after creating vpc, vpc_id is stored in aws ssm, now we are getting here to use it
#data-source or data block is ues to get the exististing infra info

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
}

#data-source or data block is ues to get the exististing infra info
data "aws_ssm_parameter" "private_subnet_ids" {
  #/expense/dev/private_subnet_ids
  name = "/${var.project_name}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "app_alb_sg_id" {
  name = "/${var.project_name}/${var.environment}/app_alb_sg_id"
}

