
## Create VPC
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_vpc
  tags = {
    Name = "My VPC"
  }
}

##  Create public and private subnets
resource "aws_subnet" "pubsub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.cidr_pubsub1_vpc
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet1"
  }
}

resource "aws_subnet" "pubsub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.cidr_pubsub2_vpc
  availability_zone       = var.az2
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet2"
  }
}

resource "aws_subnet" "prvsub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.cidr_prvsub1_vpc
  availability_zone       = var.az1
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet1"
  }
}

resource "aws_subnet" "prvsub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.cidr_prvsub2_vpc
  availability_zone       = var.az2
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet2"
  }
}

## Create Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "IGW"
  }
}

# Create public route table
resource "aws_route_table" "RTpub" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route"
  }
}


# Create Elastic IP and Nat gateways
resource "aws_eip" "nateip1" {
  domain = "vpc"
}

resource "aws_eip" "nateip2" {
  domain = "vpc"
}


resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nateip1.id
  subnet_id = aws_subnet.pubsub1.id
  tags = {
    Name = "Nat1 VPC"
  }
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nateip2.id
  subnet_id = aws_subnet.pubsub2.id
  tags = {
    Name = "Nat2 VPC"
  }
}

# Create Private route table and attach the NAt gateway route
resource "aws_route_table" "RTprv1" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }
  tags = {
    Name = "Private Route1"
  }
}

resource "aws_route_table" "RTprv2" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }
  tags = {
    Name = "Private Route2"
  }
}

## Attach the subnets to the route tables
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.pubsub1.id
  route_table_id = aws_route_table.RTpub.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.pubsub2.id
  route_table_id = aws_route_table.RTpub.id
}

resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.prvsub1.id
  route_table_id = aws_route_table.RTprv1.id
}

resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.prvsub2.id
  route_table_id = aws_route_table.RTprv2.id
}

## CReate security groups
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

## Create Key pair for instances
resource "aws_key_pair" "kp" {
  key_name = "key1"
  public_key = file("C:/Users/Vijesh/.ssh/id_rsa.pub")
}

resource "aws_lb_target_group" "tg" {
  name = "TG1"
  protocol = "HTTP"
  port = 80
  vpc_id = aws_vpc.myvpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

## Create load balancer
resource "aws_lb" "lb" {
  name = "Load-balancer1"
  internal = false
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  security_groups = [aws_security_group.webSg.id]
  subnets = [aws_subnet.pubsub1.id,aws_subnet.pubsub2.id]  
}


## Create a listener to route the traffic to the target groups
resource "aws_lb_listener" "listen" {
  load_balancer_arn = aws_lb.lb.arn
  protocol = "HTTP"
  port = 80

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tgattach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.Application1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "tgattach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id = aws_instance.Application2.id
  port = 80
}

resource "aws_instance" "Application1" {
  ami = var.us-east-ami
  instance_type = var.us-east-instance
  subnet_id = aws_subnet.prvsub1.id
  key_name = aws_key_pair.kp.key_name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  user_data = base64encode(file("appdata1.sh"))

  tags = {
    Name = "Application1"
  }
}

resource "aws_instance" "Application2" {
  ami = var.us-east-ami
  instance_type = var.us-east-instance
  subnet_id = aws_subnet.prvsub2.id
  key_name = aws_key_pair.kp.key_name
  vpc_security_group_ids = [aws_security_group.webSg.id]
  user_data = base64encode(file("appdata2.sh"))
  tags = {
    Name = "Application2"
  }
}