resource "linux_user" "app" {
  name   = var.identifier
  uid    = var.app_uid
  gid    = var.app_uid
  system = true
}
