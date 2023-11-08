resource "linux_group" "app" {
  name   = var.identifier
  gid    = var.gid
  system = true
}

resource "linux_user" "app" {
  name = var.identifier
  uid  = var.uid
  gid  = linux_group.app.gid
}
