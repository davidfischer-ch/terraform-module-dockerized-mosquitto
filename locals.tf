locals {
  container_config_directory = "/mosquitto/config"
  container_data_directory   = "/mosquitto/data"
  container_logs_directory   = "/mosquitto/log"
  host_config_directory      = "${var.data_directory}/config"
  host_data_directory        = "${var.data_directory}/data"
  host_logs_directory        = "${var.data_directory}/logs"

  container_password_file = "/tmp/password"
  container_acl_file      = "${local.container_config_directory}/mosquitto.aclfile"

  # The single pair and the map are one thing internally: a lone `username` becomes an account
  # granted everything, which is what a broker with one credential already was.
  accounts = length(var.accounts) > 0 ? var.accounts : {
    (var.username) = { password = var.password, read = ["#"], write = ["#"] }
  }

  # Sorted, because both the entrypoint and the ACL file are rendered from this and a map's
  # iteration order would otherwise rewrite them, replacing the container, on no real change.
  #
  # `nonsensitive` because a username is not one. The passwords make `accounts` sensitive and that
  # would otherwise spread to everything derived from it, including the ACL, which carries no
  # secret and is the one file worth reading in a plan before it is applied.
  account_names = nonsensitive(sort(keys(local.accounts)))

  # One variable per account rather than one carrying them all: a password is never split on a
  # delimiter it might legitimately contain.
  env = {
    for name in local.account_names :
    "MQTT_PASSWORD_${upper(replace(name, "/[^A-Za-z0-9]/", "_"))}" => local.accounts[name].password
  }

  # Written by terraform rather than by the entrypoint: an ACL needs no hashing, and a file the
  # plan can show is one somebody can review before it is applied.
  acl_file = join("\n\n", [
    for name in local.account_names : join("\n", concat(
      ["user ${name}"],
      [for topic in nonsensitive(local.accounts[name].read) : "topic read ${topic}"],
      [for topic in nonsensitive(local.accounts[name].write) : "topic write ${topic}"],
    ))
  ])

  # The port the healthcheck knocks on, inside the container. The encrypted listener when there is
  # one, since that is the one clients are meant to use.
  healthcheck_port = var.tls_enabled ? 8883 : (var.plaintext_enabled ? 1883 : 9001)

  container_tls_cert_file = "${local.container_config_directory}/server.crt"
  container_tls_key_file  = "${local.container_config_directory}/server.key"

  forced_context = {
    password_file     = local.container_password_file
    acl_file          = local.container_acl_file
    anonymous         = var.anonymous
    config_directory  = local.container_config_directory
    data_directory    = local.container_data_directory
    logs_directory    = local.container_logs_directory
    log_types         = var.log_types
    plaintext_enabled = var.plaintext_enabled
    websocket_enabled = var.websocket_enabled
    tls_enabled       = var.tls_enabled
    tls_cert_file     = local.container_tls_cert_file
    tls_key_file      = local.container_tls_key_file
  }

  linux_capabilities = [
    "ALL",
    "AUDIT_CONTROL",
    "AUDIT_READ",
    "AUDIT_WRITE",
    "BLOCK_SUSPEND",
    "BPF",
    "CHECKPOINT_RESTORE",
    "CHOWN",
    "DAC_OVERRIDE",
    "DAC_READ_SEARCH",
    "FOWNER",
    "FSETID",
    "IPC_LOCK",
    "IPC_OWNER",
    "KILL",
    "LEASE",
    "LINUX_IMMUTABLE",
    "MAC_ADMIN",
    "MAC_OVERRIDE",
    "MKNOD",
    "NET_ADMIN",
    "NET_BIND_SERVICE",
    "NET_BROADCAST",
    "NET_RAW",
    "PERFMON",
    "SETFCAP",
    "SETGID",
    "SETPCAP",
    "SETUID",
    "SYS_ADMIN",
    "SYS_BOOT",
    "SYS_CHROOT",
    "SYS_MODULE",
    "SYS_NICE",
    "SYS_PACCT",
    "SYS_PTRACE",
    "SYS_RAWIO",
    "SYS_RESOURCE",
    "SYS_TIME",
    "SYS_TTY_CONFIG",
    "SYSLOG",
    "WAKE_ALARM"
  ]
}
