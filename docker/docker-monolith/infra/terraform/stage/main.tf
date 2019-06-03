terraform {
  # Версия terraform
  required_version = "0.11.7"
}

provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "${var.project}"
  region  = "${var.region}"
}

module "docker" {
  source           = "..\/modules\/docker"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  instances_count = "${var.instances_count}"
}

