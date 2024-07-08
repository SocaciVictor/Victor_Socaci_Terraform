resource "random_password" "password" {
  count   = var.vm_count
  length  = 16
  special = true
}
