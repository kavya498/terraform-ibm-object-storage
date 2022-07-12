
resource null_resource print_names {
  provisioner "local-exec" {
    command = "echo 'Resource group: ${var.resource_group_name}'"
  }
}

data "ibm_resource_group" "resource_group" {
  depends_on = [null_resource.print_names]

  name = var.resource_group_name
}

locals {
  role        = "Manager"
  name_prefix = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name        = var.name != "" ? var.name : "${replace(local.name_prefix, "/[^a-zA-Z0-9_\\-\\.]/", "")}-${var.label}"
  key_name    = "${local.name}-key"
  module_path = substr(path.module, 0, 1) == "/" ? path.module : "./${path.module}"
  tags        = setsubtract(var.tags, [""])
  service     = "cloud-object-storage"
}

// COS Cloud Object Storage
resource ibm_resource_instance cos_instance {
  count             = var.provision ? 1 : 0

  name              = local.name
  service           = local.service
  plan              = var.plan
  location          = var.resource_location
  resource_group_id = data.ibm_resource_group.resource_group.id
  tags              = local.tags

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

data ibm_resource_instance cos_instance {
  depends_on        = [ibm_resource_instance.cos_instance]

  name              = local.name
  service           = local.service
  location          = var.resource_location
  resource_group_id = data.ibm_resource_group.resource_group.id
}

resource "ibm_resource_key" "cos_credentials" {

  name                 = local.key_name
  resource_instance_id = data.ibm_resource_instance.cos_instance.id
  role                 = local.role
  parameters           = { "HMAC" = true }

  //User can increase timeouts
  timeouts {
    create = "15m"
    delete = "15m"
  }
}

module "clis" {
  source = "cloud-native-toolkit/clis/util"
  version = "1.16.2"

  clis = ["jq"]
}

data external instance {
  program = ["bash", "${path.module}/scripts/wait-for-instance.sh"]

  query = {
    bin_dir = module.clis.bin_dir
    ibmcloud_api_key = var.ibmcloud_api_key
    id = data.ibm_resource_instance.cos_instance.id
    name = data.ibm_resource_instance.cos_instance.name
    guid = data.ibm_resource_instance.cos_instance.guid
  }
}
