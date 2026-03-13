resource "docker_container" "app" {

  lifecycle {
    replace_triggered_by = [
      local_file.entrypoint,
      local_file.main_config
    ]
  }

  entrypoint = ["/bin/sh", "${local.container_config_directory}/entrypoint.sh"]
  command    = ["mosquitto", "-c", "${local.container_config_directory}/mosquitto.conf"]
  image      = var.image_id
  name       = var.identifier

  must_run = var.enabled
  start    = var.enabled
  restart  = "always"
  wait     = var.wait

  privileged = var.privileged

  dynamic "capabilities" {
    for_each = length(var.cap_add) + length(var.cap_drop) > 0 ? [1] : []
    content {
      add  = [for cap in var.cap_add : "CAP_${cap}"]
      drop = [for cap in var.cap_drop : "CAP_${cap}"]
    }
  }

  # shm_size = 256 # MB

  env = formatlist("%s=%s", keys(local.env), values(local.env))

  dynamic "host" {
    for_each = var.hosts
    content {
      host = host.key
      ip   = host.value
    }
  }

  hostname = var.identifier

  networks_advanced {
    name = var.network_id
  }

  network_mode = "bridge"

  ports {
    internal = "1883"
    external = var.listener_port
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  ports {
    internal = "9001"
    external = var.websocket_port
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  user = linux_user.app.name

  # Config owner root:root
  volumes {
    container_path = "${local.container_config_directory}/entrypoint.sh"
    host_path      = local_file.entrypoint.filename
    read_only      = true
  }

  # Config owner root:root
  volumes {
    container_path = "${local.container_config_directory}/mosquitto.conf"
    host_path      = local_file.main_config.filename
    read_only      = true
  }

  # Data owner app:app
  volumes {
    container_path = local.container_data_directory
    host_path      = local.host_data_directory
    read_only      = false
  }

  # Logs owner app:app
  volumes {
    container_path = local.container_logs_directory
    host_path      = local.host_logs_directory
    read_only      = false
  }

  provisioner "local-exec" {
    command = <<EOT
      chown "${linux_user.app.name}:${linux_group.app.name}" "${local.host_data_directory}"
      chown "${linux_user.app.name}:${linux_group.app.name}" "${local.host_logs_directory}"
    EOT
  }
}
