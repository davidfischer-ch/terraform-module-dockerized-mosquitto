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

output "network_aliases" {
  description = "Names the broker answers to on its own network. What a client on it should use."
  value       = var.network_aliases
}

output "listener_address" {
  description = "Address the published ports bind to. Loopback unless deliberately widened."
  value       = var.listener_address
}

output "tls_listener_port" {
  description = "Port of the TLS listener."
  value       = var.tls_listener_port
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
  description = "MQTT client username. Null when the broker is configured with `accounts`."
  value       = var.username
}

output "password" {
  description = "MQTT client password. Null when the broker is configured with `accounts`."
  sensitive   = true
  value       = var.password
}

output "accounts" {
  description = "Every account the broker accepts, keyed by username."
  sensitive   = true
  value       = local.accounts
}

output "account_names" {
  description = "The usernames the broker accepts, sorted. Safe to log, unlike `accounts`."
  value       = local.account_names
}
