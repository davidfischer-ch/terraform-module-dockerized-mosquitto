variable "identifier" {
  type        = string
  description = "Identifier (must be unique, used to name resources)."
  validation {
    condition     = regex("^[a-z]+(-[a-z0-9]+)*$", var.identifier) != null
    error_message = "Argument `identifier` must match regex ^[a-z]+(-[a-z0-9]+)*$."
  }
}

variable "enabled" {
  type        = bool
  description = "Toggle the containers (started or stopped)."
}

variable "image_id" {
  type        = string
  description = "Mosquitto image's ID."
}

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

# Logging

# TODO
variable "log_level" {
  type    = string
  default = "warning"

  validation {
    condition     = contains(["debug", "verbose", "notice", "warning"], var.log_level)
    error_message = "Log level should be one of `debug`, `verbose`, `notice`, `warning`"
  }
}

# Authentication

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

# Networking

variable "network_id" {
  type        = string
  description = "Attach the containers to given network."
}

variable "listener_port" {
  type        = number
  default     = 1883
  description = "Bind the MQTT server's listener port."
}

variable "websocket_port" {
  type        = number
  default     = 9001
  description = "Bind the MQTT server's websocket port."
}
