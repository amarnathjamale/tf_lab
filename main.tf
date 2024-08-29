locals {
  common_tags = {
    environment = var.environment
    project     = "webapp"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "websubnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "not-a-websubnet"
  }
}

resource "aws_subnet" "dbsubnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_internet_gateway" "not-a-igway" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "not-a-igateway"
  }
}

#Create Route Table - attached with subnet
resource "aws_route_table" "not-a-rt" {
  vpc_id = aws_vpc.main.id
}
#Create Route in Route Table for Internet Access
resource "aws_route" "not-a-route" {
  route_table_id         = aws_route_table.not-a-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.not-a-igway.id
}

#Associate Route Table with Subnet
resource "aws_route_table_association" "not-a-rt-assoc" {
  route_table_id = aws_route_table.not-a-rt.id
  subnet_id      = aws_subnet.websubnet.id
}

resource "aws_security_group" "web_sg" {
  vpc_id      = aws_vpc.main.id
  description = "Dev web server traffic allowed ssh & http"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["122.13.0.55/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "web_server" {
  source                 = "./modules/ec2"
  instance_type          = local.instance_type[terraform.workspace]
  subnet_id              = aws_subnet.websubnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "aws_s3_bucket" "appdev_buckets" {
  count  = length(var.bucket_names)
  bucket = "appdev-${element(var.bucket_names, count.index)}"
}

variable "bucket_names" {
  type    = list(string)
  default = ["bucket69", "bucket70"]
}
