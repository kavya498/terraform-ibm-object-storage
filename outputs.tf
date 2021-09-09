output "id" {
  description = "The Object Storage instance id"
  value       = data.ibm_resource_instance.cos_instance.id
}

output "name" {
  description = "The Object Storage instance name"
  value       = local.name
  depends_on  = [data.ibm_resource_instance.cos_instance]
}

output "crn" {
  description = "The crn of the Object Storage instance"
  value       = data.ibm_resource_instance.cos_instance.id
}

output "location" {
  description = "The Object Storage instance location"
  value       = var.resource_location
  depends_on  = [data.ibm_resource_instance.cos_instance]
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
  depends_on = [data.ibm_resource_instance.cos_instance]
}

output "label" {
  description = "The label used for the Object Storage instance"
  value       = var.label
  depends_on = [data.ibm_resource_instance.cos_instance]
}

output "type" {
  description = "The type of the resource"
  value       = null
}
