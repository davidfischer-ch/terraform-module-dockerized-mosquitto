# The certificate the broker serves, and its key.
#
# Both are given rather than generated: the household already holds a wildcard from an authority
# every client trusts, and already rotates it. A certificate minted here would need its own
# authority copied into every client and its own renewal, which nothing would run.
#
# The key is the one secret among the config files, and is the only one written 0600.

resource "local_file" "tls_cert" {
  count = var.tls_enabled ? 1 : 0

  filename             = "${local.host_config_directory}/server.crt"
  content              = var.ssl_crt
  file_permission      = "0644"
  directory_permission = "0755"
}

resource "local_sensitive_file" "tls_key" {
  count = var.tls_enabled ? 1 : 0

  filename             = "${local.host_config_directory}/server.key"
  content              = var.ssl_key
  file_permission      = "0600"
  directory_permission = "0755"
}

# The key is the one file here that the broker must read and nothing else may. Terraform writes it
# as whoever ran the apply, which is root, and the broker runs as its own unprivileged user: the
# file has to be given to that user rather than have its mode widened. The certificate and the ACL
# stay root-owned and world-readable, which is what a public certificate and a topic list are.
resource "terraform_data" "tls_key_owner" {
  count = var.tls_enabled ? 1 : 0

  triggers_replace = [
    local_sensitive_file.tls_key[0].content_sha256,
    linux_user.app.uid,
  ]

  provisioner "local-exec" {
    command = format(
      "chown %s:%s '%s'",
      linux_user.app.uid,
      linux_group.app.gid,
      local_sensitive_file.tls_key[0].filename
    )
  }
}
