resource "aws_vpc" "apple-vpc" {
    cidr_block = var.vpc-cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = merge(var.command_tags,{

        "Name" = "APPLE-VPC"
    })
  
}

resource "aws_subnet" "publicsubnets" {
    count = length(var.public_subnets)
    vpc_id = aws_vpc.apple-vpc.id
    cidr_block = element(var.public_subnets,count.index)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.availbilityzones.names[count.index]
    tags = merge(var.command_tags,{
        "Name" = "public-subnet - ${count.index + 1}"
    })
}


resource "aws_subnet" "privatesubnets" {
    count = length(var.private_subnets)
    vpc_id = aws_vpc.apple-vpc.id
    cidr_block = element(var.private_subnets,count.index)
    availability_zone = data.aws_availability_zones.availbilityzones.names[count.index]
    tags = merge(var.command_tags,{
        "Name" = "private-subnet - ${count.index + 1}"
    })
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.apple-vpc.id
    tags = merge(var.command_tags,{
        "Name" = "Internet-Gateway"
    })
  
}

resource "aws_route_table" "publicrt" {
    
    vpc_id = aws_vpc.apple-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IGW.id
    }
    tags = merge(var.command_tags,{
        "Name" = "Public-RT"
    })
  
}

resource "aws_route_table_association" "publicrtassociate" {
    count = length(var.public_subnets)
    subnet_id = element(aws_subnet.publicsubnets[*].id,count.index)
    route_table_id = aws_route_table.publicrt.id

  
}

/////////////////Private Configuration/////////////////////


resource "aws_eip" "elastic-ip" {
    count = length(var.public_subnets)
    domain = "vpc"
    tags = merge(var.command_tags,{
    "Name" = "elastic-ip - ${count.index + 1}"
  })
}

resource "aws_nat_gateway" "natgateway" {
    count = length(var.public_subnets)
    allocation_id = element(aws_eip.elastic-ip[*].id,count.index)
    subnet_id = element(aws_subnet.publicsubnets[*].id,count.index)
    tags = merge(var.command_tags,{
        "Name" = "Nat GateWay - ${count.index + 1}"
    })

  depends_on = [ aws_internet_gateway.IGW ]
}


resource "aws_route_table" "privatert" {
    count = length(var.private_subnets)
    vpc_id = aws_vpc.apple-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = element(aws_nat_gateway.natgateway[*].id,count.index)
    }
    tags = merge(var.command_tags,{
        "Name" = "Private-RT"
    })
  
}

resource "aws_route_table_association" "priavtertassociate" {
    count = length(var.private_subnets)
    subnet_id = element(aws_subnet.privatesubnets[*].id,count.index)
    route_table_id = element(aws_route_table.privatert[*].id,count.index)

  
}