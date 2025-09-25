data "aws_vpc" "default" { default = true }
data "aws_subnet_ids" "default" { vpc_id = data.aws_vpc.default.id }

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
}

resource "aws_ecr_repository" "app" { name = "clo835-app" }
resource "aws_ecr_repository" "mysql" { name = "clo835-mysql" }

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals { type = "Service"; identifiers = ["ec2.amazonaws.com"] }
  }
}

resource "aws_iam_role" "ec2_ecr_role" {
  name = "clo835-ec2-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecr_attach" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "clo835-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "ec2_sg" {
  name   = "clo835-sg"
  vpc_id = data.aws_vpc.default.id

  ingress { from_port=22 to_port=22 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  ingress { from_port=8081 to_port=8083 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  egress  { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet_ids.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              yum install -y unzip
              systemctl enable docker
              systemctl start docker
              usermod -a -G docker ec2-user
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
              unzip /tmp/awscliv2.zip -d /tmp
              /tmp/aws/install
              EOF

  tags = { Name = "clo835-instance" }
}

