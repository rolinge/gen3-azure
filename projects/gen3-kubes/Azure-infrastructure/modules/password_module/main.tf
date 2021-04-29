

resource "random_string" "uid" {
  length           = var.pw_length
  special          = false
  number           = true
  lower            = true
  upper            = true
  override_special = "/@£$"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
}
