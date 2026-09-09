resource "docker_container" "app" {

  # The chown on the key, which has no attribute to reference and so is not implied by anything
  # else here. Without it the broker starts, fails to read the key and restarts forever.
  depends_on = [terraform_data.tls_key_owner]

  lifecycle {
    precondition {
      condition     = var.plaintext_enabled || var.tls_enabled || var.websocket_enabled
      error_message = "Enable one of `plaintext_enabled`, `tls_enabled` or `websocket_enabled`."
    }

    precondition {
      condition     = !var.wait || var.healthcheck_enabled
      error_message = "Argument `healthcheck_enabled` must be true when `wait` is true."
    }

    precondition {
      condition     = !var.tls_enabled || (var.ssl_crt != null && var.ssl_key != null)
      error_message = "Arguments `ssl_crt` and `ssl_key` are required when `tls_enabled` is true."
    }

    # Every file the broker reads once at start. Mosquitto holds its certificate in memory, so a
    # renewed one on disk changes nothing until the container is replaced: without these triggers a
    # renewal would apply cleanly and serve the expired certificate anyway.
    replace_triggered_by = [
      local_file.acl,
      local_file.entrypoint,
      local_file.main_config,
      local_file.tls_cert,
      local_sensitive_file.tls_key,
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

  dynamic "healthcheck" {
    for_each = var.healthcheck_enabled ? [1] : []
    content {
      test         = ["CMD-SHELL", "nc -z 127.0.0.1 ${local.healthcheck_port}"]
      interval     = var.healthcheck_interval
      timeout      = var.healthcheck_timeout
      retries      = var.healthcheck_retries
      start_period = var.healthcheck_start_period
    }
  }

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
    name    = var.network_id
    aliases = var.network_aliases
  }

  network_mode = "bridge"

  dynamic "ports" {
    for_each = var.plaintext_enabled ? [1] : []
    content {
      internal = "1883"
      external = var.listener_port
      ip       = var.listener_address
      protocol = "tcp"
    }
  }

  dynamic "ports" {
    for_each = var.tls_enabled ? [1] : []
    content {
      internal = "8883"
      external = var.tls_listener_port
      ip       = var.listener_address
      protocol = "tcp"
    }
  }

  dynamic "ports" {
    for_each = var.websocket_enabled ? [1] : []
    content {
      internal = "9001"
      external = var.websocket_port
      ip       = var.listener_address
      protocol = "tcp"
    }
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

  # Config owner root:root
  volumes {
    container_path = local.container_acl_file
    host_path      = local_file.acl.filename
    read_only      = true
  }

  # The certificate and its key. Read-only: the broker reads both at start and writes neither.
  dynamic "volumes" {
    for_each = var.tls_enabled ? [1] : []
    content {
      container_path = local.container_tls_cert_file
      host_path      = local_file.tls_cert[0].filename
      read_only      = true
    }
  }

  dynamic "volumes" {
    for_each = var.tls_enabled ? [1] : []
    content {
      container_path = local.container_tls_key_file
      host_path      = local_sensitive_file.tls_key[0].filename
      read_only      = true
    }
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
