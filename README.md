# F5-XC-SITE-MESH-GROUP

This repository consists of Terraform templates to bring create a F5XC site mesh group.

## Usage

- Clone this repo with: `git clone --recurse-submodules https://github.com/cklewar/f5-xc-site-mesh-group`
- Enter repository directory with: `cd f5-xc-site-mesh-group`
- Obtain F5XC API certificate file from Console and save it to `cert` directory
- Pick and choose from below examples and add mandatory input data and copy data into file `main.tf.example`
- Rename file __main.tf.example__ to __main.tf__ with: `rename main.tf.example main.tf`
- Initialize with: `terraform init`
- Apply with: `terraform apply -auto-approve` or destroy with: `terraform destroy -auto-approve`

### Example Output

```bash
Terraform will perform the following actions:

  # module.site_mesh_group.volterra_site_mesh_group.site_mesh_group will be created
  + resource "volterra_site_mesh_group" "site_mesh_group" {
      + id          = (known after apply)
      + name        = "site-mesh-group-01"
      + namespace   = "shared"
      + tunnel_type = "SITE_TO_SITE_TUNNEL_IPSEC"
      + type        = "full_mesh"

      + hub {
          + kind      = (known after apply)
          + namespace = "shared"
          + tenant    = "playground"
        }

      + virtual_site {
          + kind      = (known after apply)
          + name      = "virtual-site-01"
          + namespace = "shared"
          + tenant    = "playground"
        }
    }

  # module.virtual_site.volterra_virtual_site.virtual-site will be created
  + resource "volterra_virtual_site" "virtual-site" {
      + id        = (known after apply)
      + name      = "virtual-site-01"
      + namespace = "shared"
      + site_type = "CUSTOMER_EDGE"

      + site_selector {
          + expressions = [
              + "site_mesh_group in (aws-azure-gcp)",
            ]
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

## Create F5XC Site Mesh Group

```hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
  default     = "f5xc"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
  default     = "01"
}

variable "f5xc_api_p12_file" {
  type    = string
}

variable "f5xc_api_url" {
  type    = string
}

variable "f5xc_tenant" {
  type    = string
}

variable "f5xc_namespace" {
  type    = string
  default = "system"
}

provider "volterra" {
  api_p12_file = var.f5xc_api_p12_file
  url          = var.f5xc_api_url
  alias        = "default"
}

module "virtual_site" {
  source                                = "./modules/f5xc/site/virtual"
  f5xc_namespace                        = "shared"
  f5xc_virtual_site_name                = format("%s-virtual-site-%s", var.project_prefix, var.project_suffix)
  f5xc_virtual_site_type                = "CUSTOMER_EDGE"
  f5xc_virtual_site_selector_expression = ["site_mesh_group in (aws-azure-gcp)"]
  providers = {
    volterra = volterra.default
  }
}

module "site_mesh_group_full_mesh" {
  source                           = "./modules/f5xc/site-mesh-group"
  f5xc_namespace                   = var.f5xc_namespace
  f5xc_tenant                      = var.f5xc_tenant
  f5xc_site_2_site_connection_type = "full_mesh"
  f5xc_site_mesh_group_name        = format("%s-site-mesh-group-full-%s", var.project_prefix, var.project_suffix)
  f5xc_site_mesh_group_description = "F5XC Full Mesh SMG"
  f5xc_virtual_site_name           = module.virtual_site.virtual-site["name"]
  f5xc_labels                      = {
    "ves.io/fleet" = "some-fleet"
  }

  providers = {
    volterra = volterra.default
  }
}

module "site_mesh_group_hub_mesh" {
  source                           = "./modules/f5xc/site-mesh-group"
  f5xc_namespace                   = var.f5xc_namespace
  f5xc_tenant                      = var.f5xc_tenant
  f5xc_site_2_site_connection_type = "hub_mesh"
  f5xc_site_mesh_group_name        = format("%s-site-mesh-group-hub-%s", var.project_prefix, var.project_suffix)
  f5xc_site_mesh_group_description = "F5XC Full Mesh SMG"
  f5xc_virtual_site_name           = module.virtual_site.virtual-site["name"]
  f5xc_labels                      = {
    "ves.io/fleet" = "some-fleet"
  }

  providers = {
    volterra = volterra.default
  }
}

module "site_mesh_group_spoke_mesh" {
  source                           = "./modules/f5xc/site-mesh-group"
  f5xc_namespace                   = var.f5xc_namespace
  f5xc_tenant                      = var.f5xc_tenant
  f5xc_site_2_site_connection_type = "spoke_mesh"
  f5xc_site_site_hub_name          = "some-hub"
  f5xc_site_mesh_group_name        = format("%s-site-mesh-group-spoke-%s", var.project_prefix, var.project_suffix)
  f5xc_site_mesh_group_description = "F5XC Full Mesh SMG"
  f5xc_virtual_site_name           = module.virtual_site.virtual-site["name"]
  f5xc_labels                      = {
    "ves.io/fleet" = "some-fleet"
  }

  providers = {
    volterra = volterra.default
  }
}
```