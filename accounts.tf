resource "linux_group" "app" {
  name   = var.identifier
  gid    = var.app_group_id
  system = true
}

resource "linux_user" "app" {
  name = var.identifier
  uid  = var.app_user_id
  gid  = linux_group.app.gid
}
