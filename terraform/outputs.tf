output "ec2_public_ip" { value = aws_instance.web.public_ip }
output "app_ecr_repository_url" { value = aws_ecr_repository.app.repository_url }
output "mysql_ecr_repository_url" { value = aws_ecr_repository.mysql.repository_url }

