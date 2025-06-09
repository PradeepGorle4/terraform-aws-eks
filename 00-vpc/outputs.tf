# output "azs_info" {
#     value = module.vpc.azs_info
# }

# output "subnet_info" {
#     value = module.vpc.subnet_info
# }

output "public_subnet_ids" {
    value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
    value = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
    value = module.vpc.database_subnet_ids
}