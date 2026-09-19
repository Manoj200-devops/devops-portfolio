output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "app_instance_ids" {
  description = "IDs of the application EC2 instances"
  value       = aws_instance.app[*].id
}

output "app_private_ips" {
  description = "Private IP addresses of the application servers"
  value       = aws_instance.app[*].private_ip
}

output "rds_endpoint" {
  description = "Endpoint of the PostgreSQL RDS database"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "Port used by the PostgreSQL database"
  value       = aws_db_instance.main.port
}