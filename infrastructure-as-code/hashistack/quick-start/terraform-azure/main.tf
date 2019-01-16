resource "azurerm_resource_group" "hashistack" {
  name     = "${var.name}"
  location = "${var.azure_region}"
}

module "ssh_key" {
  source               = "github.com/hashicorp-modules/ssh-keypair-data.git"
  private_key_filename = "id_rsa_${var.name}"
}

module "network_azure" {
  source           = "git@github.com:hashicorp-modules/network-azure.git"
  name             = "${var.name}"
  environment      = "${var.environment}"
  location         = "${var.azure_region}"
  os               = "${var.azure_os}"
  public_key_data  = "${module.ssh_key.public_key_openssh}"
  jumphost_vm_size = "${var.azure_vm_size}"
  vnet_cidr        = "${var.azure_vnet_cidr}"
  subnet_cidrs     = ["${var.azure_subnet_cidrs}"]

  custom_data = <<EOF
${data.template_file.base_install.rendered}
${data.template_file.consul_install.rendered}
${data.template_file.vault_install.rendered}
${data.template_file.nomad_install.rendered}
${data.template_file.hashistack_quick_start.rendered}
${data.template_file.java_install.rendered}
${data.template_file.docker_install.rendered}
${data.template_file.consul_auto_join.rendered}
EOF
}

module "hashistack_azure" {
  source                     = "git@github.com:hashicorp-modules/hashistack-azure.git//quick-start"
  name                       = "${var.name}"
  provider                   = "${var.provider}"
  environment                = "${var.environment}"
  local_ip_url               = "${var.local_ip_url}"
  admin_username             = "${var.admin_username}"
  admin_password             = "${var.admin_password}"
  admin_public_key_openssh   = "${module.ssh_key.public_key_openssh}"
  azure_region               = "${var.azure_region}"
  azure_asg_initial_vm_count = "${var.azure_asg_initial_vm_count}"
  azure_os                   = "${var.azure_os}"
  azure_vm_size              = "${var.azure_vm_size}"
  azure_subnet_id            = "${module.network_azure.subnet_ids[0]}"

  azure_vm_custom_data = <<EOF
${data.template_file.base_install.rendered}
${data.template_file.consul_install.rendered}
${data.template_file.vault_install.rendered}
${data.template_file.nomad_install.rendered}
${data.template_file.hashistack_quick_start.rendered}
${data.template_file.java_install.rendered}
${data.template_file.docker_install.rendered}
${data.template_file.consul_auto_join.rendered}
EOF
}
