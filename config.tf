data "jinja_template" "main_config" {
  template = "${path.module}/config/mosquitto.conf.j2"
  context {
    type = "json"
    data = jsonencode(local.forced_context)
  }
}

resource "local_file" "main_config" {
  filename             = "${local.host_config_directory}/mosquitto.conf"
  content              = data.jinja_template.main_config.result
  file_permission      = "0644"
  directory_permission = "0755"
}
