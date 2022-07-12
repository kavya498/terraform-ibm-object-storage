output "id" {
  description = "The Object Storage instance id"
  value       = data.external.instance.result.id
  depends_on  = [ibm_resource_key.cos_credentials]
}

output "name" {
  description = "The Object Storage instance name"
  value       = data.external.instance.result.name
  depends_on  = [ibm_resource_key.cos_credentials]
}

output "crn" {
  description = "The crn of the Object Storage instance"
  value       = data.external.instance.result.id
  depends_on  = [ibm_resource_key.cos_credentials]
}

output "location" {
  description = "The Object Storage instance location"
  value       = var.resource_location
  depends_on  = [ibm_resource_key.cos_credentials]
}

output "key_name" {
  description = "The name of the credential provisioned for the Object Storage instance"
  value       = local.key_name
  depends_on  = [ibm_resource_key.cos_credentials]
}

output "key_id" {
  description = "The name of the credential provisioned for the Object Storage instance"
  value       = ibm_resource_key.cos_credentials.id
}

output "service" {
  description = "The name of the key provisioned for the Object Storage instance"
  value       = local.service
  depends_on  = [ibm_resource_key.cos_credentials]
}

output "label" {
  description = "The label used for the Object Storage instance"
  value       = var.label
  depends_on  = [ibm_resource_key.cos_credentials]
}

output "type" {
  description = "The type of the resource"
  value       = null
}
