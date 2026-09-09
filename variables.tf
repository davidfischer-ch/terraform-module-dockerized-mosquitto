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

variable "healthcheck_enabled" {
  type        = bool
  description = <<-EOT
    Enable the healthcheck (a TCP connect to the listener)?

    What it proves is that the broker is accepting connections on the port it was configured for,
    which is what `wait` needs and what a supervisor restarts on. It deliberately does not
    authenticate: a healthcheck holding an account's password would be a credential in the
    container's command line, and a broker that refuses a bad password is a broker that is up.
  EOT
  default     = true
}

variable "healthcheck_interval" {
  type        = string
  description = "Time between healthcheck attempts."
  default     = "10s"
}

variable "healthcheck_timeout" {
  type        = string
  description = "Maximum time to wait for a healthcheck to complete."
  default     = "5s"
}

variable "healthcheck_retries" {
  type        = number
  description = "Number of consecutive failures before marking unhealthy."
  default     = 5

  validation {
    condition     = var.healthcheck_retries >= 1
    error_message = "Argument `healthcheck_retries` must be at least 1."
  }
}

variable "healthcheck_start_period" {
  type        = string
  description = "Grace period during startup where healthcheck failures are not counted."
  default     = "1m0s"
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
  validation {
    condition     = length(setsubtract(var.cap_add, local.linux_capabilities)) == 0
    error_message = "Each entry in `cap_add` must be a valid Linux capability name."
  }
}

variable "cap_drop" {
  type        = set(string)
  description = "Linux capabilities to drop from the container."
  default     = []
  validation {
    condition     = length(setsubtract(var.cap_drop, local.linux_capabilities)) == 0
    error_message = "Each entry in `cap_drop` must be a valid Linux capability name."
  }
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

variable "network_aliases" {
  type        = list(string)
  description = <<-EOT
    Names the broker answers to on its own network, resolved by docker's embedded DNS.

    An alias rather than a container address: a bridge address changes whenever the container is
    recreated, and a client pinned to one fails quietly the next time it is. Give it the name the
    server certificate carries, and TLS validates for whoever joins the network.
  EOT
  default     = []
}

variable "listener_address" {
  type        = string
  description = <<-EOT
    Address the published ports bind to.

    Loopback, because a client that shares a docker network with the broker reaches the container
    directly and never touches a published port at all. What the published port is for is the
    client that cannot join a network: one running with `network_mode = host`, for which loopback
    is the host's own. Binding `0.0.0.0` instead would offer the bus to every device in the house.
  EOT
  default     = "127.0.0.1"
}

variable "plaintext_enabled" {
  type        = bool
  description = <<-EOT
    Whether to keep serving unencrypted MQTT on `listener_port`.

    On, so that adding TLS to a broker with clients already on it does not cut them off mid-change.
    Turn it off once every client has been moved, which is the point of doing this at all.
  EOT
  default     = true
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

variable "tls_enabled" {
  type        = bool
  description = <<-EOT
    Whether to serve TLS on `tls_listener_port`, from the certificate given as `ssl_crt`.

    Without it a password crosses the network in the clear on every connect, and whoever reads one
    can publish as that client from then on.
  EOT
  default     = true
}

variable "tls_listener_port" {
  type        = number
  description = "Port for the TLS listener. 8883 is the registered one for MQTT over TLS."
  default     = 8883
}

variable "websocket_enabled" {
  type        = bool
  description = <<-EOT
    Whether to serve MQTT over websockets on `websocket_port`.

    Off: a websocket listener is for a browser talking to the broker directly, and nothing here
    does. Publishing the port without it is worse than useless, since it maps a host port to a
    listener that was never configured.
  EOT
  default     = false
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
  description = "MQTT authentication username. Ignored when `accounts` is set."
  default     = null
}

variable "password" {
  type        = string
  description = "MQTT authentication password. Ignored when `accounts` is set."
  default     = null
  sensitive   = true
}

variable "accounts" {
  type = map(object({
    password = string
    read     = optional(list(string), [])
    write    = optional(list(string), [])
  }))
  description = <<-EOT
    One entry per client, keyed by username, each scoped to the topics it needs.

    A broker with one shared account gives every client read and write over every topic, which
    makes a leaked credential worth the whole bus. Per-client accounts and an ACL narrow that to
    the prefixes each one was granted.

    `read` and `write` are topic patterns as mosquitto writes them, wildcards included:
    `home/events/#`. An account listing neither may authenticate and reach nothing, which is a
    useful thing to be able to say deliberately.

    Leave empty to keep the single `username` / `password` pair, which grants that one account
    everything.
  EOT
  default     = {}
  sensitive   = true
}

variable "anonymous" {
  type        = bool
  description = "Whether to accept unauthenticated clients. Off, and worth keeping off."
  default     = false
}


# Security -----------------------------------------------------------------------------------------

variable "ssl_crt" {
  type        = string
  description = <<-EOT
    Server certificate, PEM. Required when `tls_enabled`.

    The household's own wildcard rather than one generated here, for a reason that is entirely
    about renewal: this one is already rotated, and it is signed by an authority every client
    already trusts. A certificate minted by this module would need its authority copied into each
    client, and a renewal story of its own that nothing would run.
  EOT
  default     = null
  sensitive   = true
}

variable "ssl_key" {
  type        = string
  description = "Private key for `ssl_crt`, PEM. Required when `tls_enabled`."
  default     = null
  sensitive   = true
}
