#-------------------
# 既存VPC取得
#-------------------

data "aws_vpc" "orion_01" {
  filter {
    name   = "tag:Name"
    values = ["orion-vpc"]
  }
}

#-------------------
# 既存IGW取得
#-------------------

data "aws_internet_gateway" "orion_01" {
  filter {
    name   = "tag:Name"
    values = ["orion-igw-01"]
  }
}

#----------------------------
# 既存サブネット取得
#----------------------------

data "aws_subnet" "public-1a" {
  filter {
    name   = "tag:Name"
    values = ["public-1a"]
  }
}

data "aws_subnet" "public-1c" {
  filter {
    name   = "tag:Name"
    values = ["public-1c"]
  }
}

data "aws_subnet" "private-1a" {
  filter {
    name   = "tag:Name"
    values = ["private-1a"]
  }
}

data "aws_subnet" "private-1c" {
  filter {
    name   = "tag:Name"
    values = ["private-1c"]
  }
}

#---------------------------
# 既存 RouteTable取得
#---------------------------

data "aws_route_table" "public-route-table" {
  filter {
    name   = "tag:Name"
    values = ["OrionPublicRouteTable"]
  }
}

data "aws_route_table" "private-route-table" {
  filter {
    name   = "tag:Name"
    values = ["OrionPrivateRouteTable"]
  }
}

#--------------------------
# NAT Gateway用 EIP作成
#--------------------------

resource "aws_eip" "nat_gateway" {
  depends_on = [data.aws_internet_gateway.orion_01]

  tags = {
    Name              = "${var.project}-${var.env}-natgateway-eip-01"
    "amazon-side-asn" = "64512"
  }
}

#--------------------------
# NAT Gateway作成
#--------------------------

resource "aws_nat_gateway" "public-1a" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = data.aws_subnet.public-1a.id
  depends_on    = [data.aws_internet_gateway.orion_01]

  tags = {
    Name = "${var.project}-${var.env}-natgateway-public-1a"
  }

}

#--------------------------
# Routing
#--------------------------

resource "aws_route" "private" {
  route_table_id         = data.aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.public-1a.id
  destination_cidr_block = "0.0.0.0/0"
}


