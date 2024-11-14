module "backend" {
  source = "terraform-aws-modules/ec2-instance/aws"
  ami    = data.aws_ami.expense_server.id
  name   = local.resource_name

  instance_type          = "t2.micro"
  vpc_security_group_ids = [local.backend_sg_id]
  subnet_id              = local.private_subnet_id

  tags = merge(
    var.common_tags,
    var.backend_tags,
    {
      Name : local.resource_name
    }
  )
}