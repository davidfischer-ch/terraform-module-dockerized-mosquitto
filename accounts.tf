resource "linux_group" "app" {
  name   = var.identifier
  gid    = var.app_gid
  system = true
}

resource "linux_user" "app" {
  name   = var.identifier
  uid    = var.app_uid
  gid    = linux_group.app.gid
  system = true
}
