# --- networking/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.pa_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.pa_rds_subnetgroup.*.name
}

output "db_security_group" {
  value = [aws_security_group.pa_sg["rds"].id]
}

output "public_sg" {
  value = aws_security_group.pa_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.pa_public_subnet.*.id
}