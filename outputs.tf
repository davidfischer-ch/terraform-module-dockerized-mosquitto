output "app_user" {
  description = "Linux user running the Mosquitto container."
  value       = linux_user.app
}

output "app_group" {
  description = "Linux group of the Mosquitto container."
  value       = linux_group.app
}

output "host" {
  description = "Hostname of the Mosquitto container."
  value       = docker_container.app.hostname
}

output "listener_port" {
  description = "MQTT listener port."
  value       = var.listener_port
}

output "websocket_port" {
  description = "WebSocket listener port."
  value       = var.websocket_port
}

output "username" {
  description = "MQTT client username."
  value       = var.username
}

output "password" {
  description = "MQTT client password."
  sensitive   = true
  value       = var.password
}
