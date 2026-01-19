output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public-subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.Private-subnet.id
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}
