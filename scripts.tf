resource "local_file" "entrypoint" {
  filename             = "${local.host_config_directory}/entrypoint.sh"
  file_permission      = "0755"
  directory_permission = "0755"

  # One `mosquitto_passwd` line per account, generated here rather than looped in shell: the set of
  # accounts is known at plan time, and an explicit line each is what makes the rendered script
  # readable in a diff. Only the first carries `-c`, which creates the file; a later one would
  # truncate every account written before it.
  #
  # The passwords arrive as one environment variable each and are never interpolated into this
  # file, which is world-readable on the host.
  content = <<-EOT
    #!/bin/sh
    set -e

    echo "Generating password file"
    ${join("\n", [
  for index, name in local.account_names :
  format(
    "mosquitto_passwd -b %s%s '%s' \"$MQTT_PASSWORD_%s\"",
    index == 0 ? "-c " : "",
    local.container_password_file,
    name,
    upper(replace(name, "/[^A-Za-z0-9]/", "_")),
  )
])}

    echo "Starting server"
    exec "$@"
  EOT
}
