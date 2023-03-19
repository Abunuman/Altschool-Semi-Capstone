# VPC Resources
 #  * VPC
 #  * Subnets
#  * Internet Gateway
 #  * Nat Gateway
 #  * Elastic IP allocation
 #  * Route Table and Association


# /*==== The VPC ======*/

resource "aws_vpc" "deployment" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# /*==== Subnets (Public & Private)======*/

resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.deployment.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name"                            = "private-us-east-1a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/Altexam-eks-cluster"      = "owned"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.deployment.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name"                            = "private-us-east-1b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/Altkube-eks-cluster"      = "owned"
  }
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.deployment.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-us-east-1a"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/Altkube-eks-cluster" = "owned"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = aws_vpc.deployment.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-us-east-1b"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/Altkube-eks-cluster" = "owned"
  }
}

# /*==== The Internet Gateway (IGW)======*/

resource "aws_internet_gateway" "deployment-igw" {
  vpc_id = aws_vpc.deployment.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# /*==== NAT Gateway & Elastic IP Allocation (IGW)======*/

resource "aws_eip" "nat-eip" {
  vpc = true

  tags = {
    Name = "${var.env_prefix}-eip"
  }
}

resource "aws_nat_gateway" "deployment-nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "${var.env_prefix}-nat"
  }

  depends_on = [aws_internet_gateway.deployment-igw]
}

# /*==== Route Table and Route Table Association ======*/

resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.deployment.id

  route  {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.deployment-nat.id
    }
 

  tags = {
    Name = "${var.env_prefix}-private-rtb"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.deployment.id

  route {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.deployment-igw.id
    }

  tags = {
    Name = "${var.env_prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private-rtb.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.private-us-east-1b.id
  route_table_id = aws_route_table.private-rtb.id
}

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.public-us-east-1b.id
  route_table_id = aws_route_table.public-rtb.id
}



