output "private_subnet_group_name" {
  sensitive = false
  value     = aws_db_subnet_group.private.name
}

output "private_zones" {
  sensitive = false
  value     = [for i in aws_subnet.private : i.availability_zone]
}

