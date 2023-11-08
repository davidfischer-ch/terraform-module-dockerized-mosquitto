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
}
