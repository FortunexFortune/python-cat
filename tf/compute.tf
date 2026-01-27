data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "minikube" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  name = local.service_name

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = module.red_tiger.private_subnets[2].id
  vpc_security_group_ids = [aws_security_group.minikube.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data                   = base64encode(file("${path.module}/cloud-init.yaml"))
  user_data_replace_on_change = true
  tags = {
    Name = local.service_name
  }

  root_block_device = [
    {
      volume_size = 20
      volume_type = "gp3"
      delete_on_termination = true
    }
  ]

  depends_on = [module.red_tiger]
}

resource "aws_security_group" "minikube" {
  name   = local.service_name
  vpc_id = module.red_tiger.vpc_id

  tags = {
    Name = local.service_name
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.minikube.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_iam_role" "ec2_ssm_role" {
  name = local.service_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = local.service_name
  role = aws_iam_role.ec2_ssm_role.name
}

