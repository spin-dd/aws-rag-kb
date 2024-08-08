output "domain_name" {
  sensitive = false
  value     = aws_apigatewayv2_domain_name.kb["demo"].domain_name
}
