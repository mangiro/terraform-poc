resource "docker_network" "terraform-poc" {
  name = "${var.application}-${var.environment}-net"
  ipam_config {
    subnet = "${var.subnet}"
  }
}

resource "docker_container" "terraform-poc" {
  image = "${var.application}:${var.environment}-${var.commit_hash}"
  name  = "${var.application}-${var.environment}-${var.commit_hash}"
  env   = [
    "POETRY_VIRTUALENVS_CREATE=false"
  ]
  working_dir = "/opt/terraform-poc"
  entrypoint  = [
    "poetry", "run",
    "python3.9", "-m",
    "gunicorn.app.wsgiapp",
    "src.terraform_poc.app",
    "--bind", "0.0.0.0:8080",
    "--workers", "1"
  ]
  tty = true
  ports {
    internal = "8080"
    external = "8080"
    protocol = "tcp"
  }
  networks_advanced {
    name         = "${var.application}-${var.environment}-net"
    ipv4_address = "${var.target}"
  }
}
