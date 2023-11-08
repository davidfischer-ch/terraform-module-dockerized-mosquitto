resource "local_file" "entrypoint" {
  filename             = "${local.host_config_directory}/entrypoint.sh"
  file_permission      = "0755"
  directory_permission = "0755"

  content = <<EOT
#!/bin/sh
set -e

echo "Generating password file"
mosquitto_passwd -b ${local.container_password_file} "${var.username}" "$PASSWORD"
echo "Starting server"
exec "$@"
EOT
}
