output "project_name" {
  value = var.project_name
}

output "alb_arn" {
  value = aws_lb.waf-alb.arn
}

output "bucket_name" {
  value = var.bucket_name
}
