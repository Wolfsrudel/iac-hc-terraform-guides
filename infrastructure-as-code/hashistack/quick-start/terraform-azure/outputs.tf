output "zREADME" {
  description = "Full README for interacting with the Hashistack resources."
  value       = "${module.hashistack_azure.zREADME}"
}

output "lb_fqdn" {
  value = "${module.hashistack_azure.lb_fqdn}"
}

output "lb_public_ip_address" {
  value = "${module.hashistack_azure.lb_public_ip_address}"
}

output "quick_ssh_string" {
  value = "${module.hashistack_azure.quick_ssh_string}"
}
