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

variable "wait" {
  type        = bool
  default     = false
  description = "Wait for the container to reach an healthy state after creation."
}

variable "image_id" {
  type        = string
  description = "Mosquitto image's ID."
}

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

# Daemon -------------------------------------------------------------------------------------------

variable "app_uid" {
  type    = number
  default = 1883
}

variable "app_gid" {
  type    = number
  default = 1883
}

# Logging ------------------------------------------------------------------------------------------

variable "log_types" {
  type    = list(string)
  default = ["error", "warning", "notice", "information"]

  validation {
    condition = length(var.log_types) >= 1 && length(setsubtract(
      var.log_types,
      [
        "debug",
        "error",
        "warning",
        "notice",
        "information",
        "subscribe",
        "unsubscribe",
        "websockets",
        "none",
        "all"
      ]
    )) == 0
    error_message = "Log types should be one or more of `debug`, `error`, `warning`, `notice`, `information`, `subscribe`, `unsubscribe`, `websockets`, `none`, `all`."
  }
}

# Authentication -----------------------------------------------------------------------------------

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  default     = {}
  description = "Add entries to container hosts file."
}

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
