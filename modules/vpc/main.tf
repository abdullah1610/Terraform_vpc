#=========== VPC ==================================================

resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge({
        { Name = "${var.env}--vpc" }
    },
      var.tags
)




#============== Subnets ===========================================

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.public_subnet_cidr
    availibility_zone = var.az
    map_public_ip_on_launch = true

    tags = merge({
        { Name = "${var.env}--public-subnet"}
    },
     var.tags
)


resource "aws_subnet" "Private-subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.private_subnet_cidr
    availibility_zone = var.az
    map_public_ip_on_launch = false

    tags = merge({
        { Name = "${var.env}--private-subnet"}
    },
     var.tags
)


#=========IGW & NAT======================================================


resource "aws_internate_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "${var.env}--IGW"
    }
}


resource "aws_eip" "my-eip" {
    domain = "vpc"
}


resource "aws_nat" "my_nat_gateway" {
    allocation_id = aws_eip.my-eip.id
    subnet_id = aws_subnet.public-subnet.id

    depends_on = [aws_internate_gateway.my_igw]

    tags = {
        Name = "${var.env}--nat-instance"
    }
}


#=============Route table==========================================


resource "aws_route_table" "public" {
    vpc_id = aws_vpc.my_vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internate_gateway.my_igw.id
    }

    tags = {
        Name = "${var.env}--public-Route"
    }
}


resource "aws_route_table" "private" {
    vpc_id = aws_vpc.my_vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat.my_nat_gateway.id
    }
    
    tags = {
        Name = "${var.env}--private-route"
    }
}


#===========Route table subnet Association============================

resource "aws_route_table_association" "public_association" {
    subnet_id = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_association" {
    subnet_id = aws_subnet.Private-subnet.id
    route_table_id = aws_route_table.private.id
}


#============== Security group ============================================

resource "aws_security_group" "my_sg" {
    name = ${var.env}--my-my_sg
    vpc_id = aws_vpc.my_vpc.id


    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
    }

    tags = var.tags
}
