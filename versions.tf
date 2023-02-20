terraform {
  required_version = ">= 1.3.0"
  cloud {
    organization = "cklewar"
    hostname     = "app.terraform.io"

    workspaces {
      name = "f5-xc-site-mesh-group-module"
    }
  }
  
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
<<<<<<< HEAD
      version = "= 0.11.18"
=======
      version = "= 0.11.19"
>>>>>>> 0.11.19
    }
    local = ">= 2.2.3"
    null = ">= 3.1.1"
  }
}