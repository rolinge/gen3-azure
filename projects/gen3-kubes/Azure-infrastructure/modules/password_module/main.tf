

resource "random_string" "app" {
  length           = 16
  special          = true
  number           = true
  lower           = true
  upper           = true
  override_special = "/@£$"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_sepcial      = 1
}

output "password" {
  value = random_string.app.result
}
