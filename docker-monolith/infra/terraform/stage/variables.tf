variable project {
  description = "Project ID"
}

variable region {
  # Описание переменной
  description = "Region"

  # Значение по умолчанию
  default = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the public key used for ssh access in provisioner"
}

variable instances_count {
  description = "Count of instances"
  default     = "1"
}
