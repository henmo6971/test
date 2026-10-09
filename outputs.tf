output "vpc" {
  description = "VPC identity and CIDR block."
  value = {
    id         = aws_vpc.this.id
    cidr_block = aws_vpc.this.cidr_block
  }
}

output "subnets" {
  description = "Subnet identities, CIDR blocks, availability zones, and visibility."
  value = {
    for name, subnet in aws_subnet.this : name => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
      public            = local.subnets[name].public
    }
  }
}

output "internet_gateway_id" {
  description = "ID of the VPC Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway" {
  description = "NAT Gateway identity and public IPv4 address."
  value = {
    id        = aws_nat_gateway.this.id
    public_ip = aws_eip.nat.public_ip
  }
}

output "route_table_ids" {
  description = "IDs of the public and private route tables."
  value = {
    public  = aws_route_table.public.id
    private = aws_route_table.private.id
  }
}