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
  default     = true
}

variable "wait" {
  type        = bool
  description = "Wait for the container to reach an healthy state after creation."
  default     = true
}

variable "image_id" {
  type        = string
  description = "Mosquitto image's ID."
}

# Process ------------------------------------------------------------------------------------------

variable "app_uid" {
  type        = number
  description = "UID of the user running the container and owning the data directories."
  default     = 1883
}

variable "app_gid" {
  type        = number
  description = "GID of the user running the container and owning the data directories."
  default     = 1883
}

variable "privileged" {
  type        = bool
  description = "Run the container in privileged mode."
  default     = false
}

variable "cap_add" {
  type        = set(string)
  description = "Linux capabilities to add to the container."
  default     = []
}

variable "cap_drop" {
  type        = set(string)
  description = "Linux capabilities to drop from the container."
  default     = []
}

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  description = "Add entries to container hosts file."
  default     = {}
}

variable "network_id" {
  type        = string
  description = "Attach the containers to given network."
}

variable "listener_port" {
  type        = number
  description = "Bind the MQTT server's listener port."
  default     = 1883

  validation {
    condition     = var.listener_port >= 1 && var.listener_port <= 65535
    error_message = "Argument `listener_port` must be between 1 and 65535."
  }
}

variable "websocket_port" {
  type        = number
  description = "Bind the MQTT server's websocket port."
  default     = 9001

  validation {
    condition     = var.websocket_port >= 1 && var.websocket_port <= 65535
    error_message = "Argument `websocket_port` must be between 1 and 65535."
  }
}

# Storage ------------------------------------------------------------------------------------------

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

# Logging ------------------------------------------------------------------------------------------

variable "log_types" {
  type        = list(string)
  description = "Log types to enable (debug, error, warning, notice, information, subscribe, unsubscribe, websockets, none, all)."
  default     = ["error", "warning", "notice", "information"]

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
  type        = string
  description = "MQTT authentication username."
}

variable "password" {
  type        = string
  description = "MQTT authentication password."
  sensitive   = true
}
