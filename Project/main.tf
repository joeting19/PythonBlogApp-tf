# terraform plan --var-file=variables/test.tfvars
# terraform apply --auto-approve --var-file=variables/test.tfvars
# terraform destroy --auto-approve --var-file=variables/test.tfvars

locals {
  name_prefix = "pyblog-${var.environment}"
  vmnames     = ["pyblog", "postgres", "prometheus", "grafana", "nginx"]
}

module "vnet" {
  source        = "../Modules/vnet"
  region        = var.region
  resourcegroup = var.resourcegroup
  vnetcidr      = var.vnetcidr
  subncidrs     = var.subncidrs
  vmnames       = local.vmnames
}

module "vm" {
  source        = "../Modules/vm"
  region        = var.region
  resourcegroup = var.resourcegroup
  vmnames       = local.vmnames
  blog_nics     = module.vnet.blog_nics
}