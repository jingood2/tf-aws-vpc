################################################################################
# Endpoint(s)
################################################################################

locals {
  endpoints = { for k, v in var.endpoints : k =>  v if var.create && try(v.create, true) }
}

#Interface Endpoint Only
data "aws_vpc_endpoint_service" "this" {
  for_each = locals.endpoints

  service = lookup(each.value, "service", null)
  service_name = lookup(each.value, "service_name", null)

  filter {
    name = "service-type"
    values = [lookup(each.value, "service_type", "Interface")]
  }
}

resource "aws_vpc_endpoint" "this" {

  for_each = local.endpoints

  vpc_id = var.vpc_id
  service_name = data.aws_vpc_endpoint_service.this[each.key].service_name

  vpc_endpoint_type = lookup(each.value, "service_type", "Interface")
  auto_accept = lookup(each.value, "auto_accept", null)

  #(Optional) The ID of one or more subnets in which to create a network interface for the endpoint GWLB, Interface
  security_group_ids =  lookup(each.value, "service_type", "Interface") == "Interface" ? length(distinct(concat(var.security_group_ids, lookup(each.value, "security_group_ids", [])))) > 0 ? distinct(concat(var.security_group_ids, lookup(each.value, "security_group_ids", []))) : null : null
  #(Optional) The ID of one or more security groups to associate with the network interface. Applicable for endpoints of type Interface
  subnet_ids          = lookup(each.value, "service_type", "Interface") == "Interface" ? distinct(concat(var.subnet_ids, lookup(each.value, "subnet_ids", []))) : null
  #(Optional) One or more route table IDs. Applicable for endpoints of type Gateway
  route_table_ids = lookup(each.value, "service_type", "Interface") == "Gateway" ? lookup(each.value, "route_table_ids", null) : null
  #(Optional) A policy to attach to the endpoint that controls access to the service. This is a JSON formatted string. Defaults to full access. All Gateway and some Interface endpoints support policies
  policy = lookup(each.value, "policy", null)
  private_dns_enabled = lookup(each.value, "service_type", "Interface") == "Interface" ? lookup(each.value, "private_dns_enabled", null) : null

  timeouts {
    create = lookup(var.timeouts, "create", "10m")
    update = lookup(var.timeouts, "update", "10m")
    delete = lookup(var.timeouts, "delete", "10m")
  }

  tags = merge(var.tags, lookup(each.value, "tags", {} ))
  
}

