# Create the VPC — the isolated private network all your AWS resources will live in
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr  # The IP address range for the entire VPC (e.g. 10.0.0.0/16)
  enable_dns_support   = true          # Allows AWS to resolve DNS names inside the VPC
  enable_dns_hostnames = true          # Gives EC2 instances public DNS hostnames automatically

  tags = {
    Name = var.name
  }
}

# Create one public subnet per entry in var.public_subnet_cidrs.
# "count" is how Terraform creates multiple copies of the same resource.
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)         # How many subnets to create
  vpc_id            = aws_vpc.this.id                         # Place subnets inside our VPC
  cidr_block        = var.public_subnet_cidrs[count.index]    # Each subnet gets its own CIDR slice
  availability_zone = var.availability_zones[count.index]     # Spread subnets across AZs for HA
  map_public_ip_on_launch = true                              # Auto-assign public IPs to EC2 instances

  tags = {
    # count.index starts at 0, so we add 1 to get "public-1", "public-2", etc.
    Name = "${var.name}-public-${count.index + 1}"
  }
}

# The Internet Gateway (IGW) is what connects the VPC to the public internet.
# Without this, nothing in the VPC can reach the internet (or be reached from it).
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id # Attach the IGW to our VPC

  tags = {
    Name = "${var.name}-igw"
  }
}

# A Route Table controls where network traffic is directed within the VPC.
# This one sends all internet-bound traffic (0.0.0.0/0) through the IGW.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"                  # Match all traffic that isn't destined for the VPC itself
    gateway_id = aws_internet_gateway.this.id  # Send it out through the Internet Gateway
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

# Associate each public subnet with the public route table.
# Without this link, subnets don't know which route table to use.
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)    # One association per subnet
  subnet_id      = aws_subnet.public[count.index].id  # Match subnet by index
  route_table_id = aws_route_table.public.id          # Point to our public route table
}
