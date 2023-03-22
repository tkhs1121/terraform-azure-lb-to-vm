variable "key_name" {
  type = string
  description = "keypair name"
  default = "key"
}

locals {
  private_key_file = "./${var.key_name}"
}

resource "tls_private_key" "keygen" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename = local.private_key_file
  content   = tls_private_key.keygen.private_key_pem

  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_file}"
  }
}

output "key_name" {
  value = var.key_name
}
