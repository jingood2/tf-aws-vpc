# Main Output Values
output "my_password" {
  value     = module.helloworld.my_password
  sensitive = true
}
