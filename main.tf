resource "docker_container" "server" {

  lifecycle {
    replace_triggered_by = [
      local_sensitive_file.main_config
    ]
  }

  image = var.image_id
  name  = var.identifier

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  # wait   = true

  # shm_size = 256 # MB

  # command = ["mosquitto", "-c", "${local.container_config_directory}/mosquitto.conf"]

  hostname = var.identifier

  networks_advanced {
    name = var.network_id
  }

  env = [
  ]

  volumes {
    container_path = "${local.container_config_directory}/mosquitto.conf"
    host_path      = local_sensitive_file.main_config.filename
    read_only      = true
  }

  volumes {
    container_path = local.container_data_directory
    host_path      = local.host_data_directory
    read_only      = false
  }

  volumes {
    container_path = local.container_logs_directory
    host_path      = local.host_logs_directory
    read_only      = false
  }
}
