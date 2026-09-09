data "jinja_template" "main_config" {
  source {
    directory = path.module
    template  = file("${path.module}/config/mosquitto.conf.j2")
  }
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

# Which topics each account may reach. Carries no secret, unlike the password file, which is why
# it is written here and mounted rather than generated inside the container.
resource "local_file" "acl" {
  filename             = "${local.host_config_directory}/mosquitto.aclfile"
  content              = "${local.acl_file}\n"
  file_permission      = "0644"
  directory_permission = "0755"
}
