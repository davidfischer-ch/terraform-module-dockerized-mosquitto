output "host" {
  value = docker_container.server.hostname
}

output "listener_port" {
  value = var.listener_port
}

output "other_port" {
  value = var.other_port
}

output "username" {
  value = var.username
}

output "password" {
  value     = var.password
  sensitive = true
}
