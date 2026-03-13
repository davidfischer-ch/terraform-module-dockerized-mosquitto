locals {
  container_config_directory = "/mosquitto/config"
  container_data_directory   = "/mosquitto/data"
  container_logs_directory   = "/mosquitto/log"
  host_config_directory      = "${var.data_directory}/config"
  host_data_directory        = "${var.data_directory}/data"
  host_logs_directory        = "${var.data_directory}/logs"

  container_password_file = "/tmp/password"

  env = {
    PASSWORD = var.password
  }

  forced_context = {
    password_file    = local.container_password_file
    config_directory = local.container_config_directory
    data_directory   = local.container_data_directory
    logs_directory   = local.container_logs_directory
    log_types        = var.log_types
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
