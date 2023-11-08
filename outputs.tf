output "app_user" {
  value = linux_user.app
}

output "host" {
  # Not the good host to communicate with
  value = docker_container.app.hostname
}

output "listener_port" {
  value = var.listener_port
}

output "websocket_port" {
  value = var.websocket_port
}

output "username" {
  value = var.username
}

output "password" {
  value     = var.password
  sensitive = true
}
