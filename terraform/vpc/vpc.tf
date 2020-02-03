/*
  naming convention
  ^vpc_(ue1|uw1|uw2|ew1|ec1|an1|an2|as1|as2|se1)_(d|t|s|p)_([a_z0_9\_]+)$
  example : vpc_us_west_2_p_web_app_stack
*/
resource "aws_vpc" "vpc_an2_d_web" {
  cidr_block           = "172.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "vpc_an2_d_web"
  }
}

/*
  naming convention
  example : route_table_vpc_an2_d_web
*/
resource "aws_default_route_table" "route_table_vpc_an2_d_web" {
  default_route_table_id = aws_vpc.vpc_an2_d_web.default_route_table_id
  tags = {
    Name = "route_table_vpc_an2_d_web"
  }
}

/*
  naming convention
  example : public_subnet_1_vpc_an2_d_web, public_subnet_2_vpc_an2_d_web
*/
resource "aws_subnet" "public_subnet_1_vpc_an2_d_web" {
  vpc_id                  = aws_vpc.vpc_an2_d_web.id
  cidr_block              = "172.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public_subnet_1_vpc_an2_d_web"
  }
}

resource "aws_subnet" "public_subnet_2_vpc_an2_d_web" {
  vpc_id                  = aws_vpc.vpc_an2_d_web.id
  cidr_block              = "172.10.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public_subnet_2_vpc_an2_d_web"
  }
}

resource "aws_subnet" "private_subnet_1_vpc_an2_d_web" {
  vpc_id                  = aws_vpc.vpc_an2_d_web.id
  cidr_block              = "172.10.10.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private_subnet_1_vpc_an2_d_web"
  }
}

resource "aws_subnet" "private_subnet_2_vpc_an2_d_web" {
  vpc_id                  = aws_vpc.vpc_an2_d_web.id
  cidr_block              = "172.10.11.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private_subnet_2_vpc_an2_d_web"
  }
}

resource "aws_internet_gateway" "igw_vpc_an2_d_web" {
  vpc_id = aws_vpc.vpc_an2_d_web.id
  tags = {
    Name = "igw_vpc_an2_d_web"
  }
}

resource "aws_route" "route_vpc_an2_d_web" {
  route_table_id         = aws_vpc.vpc_an2_d_web.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_vpc_an2_d_web.id
}

resource "aws_eip" "eip_nat_vpc_an2_d_web" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw_vpc_an2_d_web]
}

resource "aws_nat_gateway" "nat_vpc_an2_d_web" {
  allocation_id = aws_eip.eip_nat_vpc_an2_d_web.id
  subnet_id     = aws_subnet.public_subnet_1_vpc_an2_d_web.id
  depends_on    = [aws_internet_gateway.igw_vpc_an2_d_web]
}

resource "aws_route_table" "private_route_table_vpc_an2_d_web" {
  vpc_id = aws_vpc.vpc_an2_d_web.id
  tags = {
    Name = "private_route_table_vpc_an2_d_web"
  }
}

resource "aws_route" "private_route_vpc_an2_d_web" {
  route_table_id         = aws_route_table.private_route_table_vpc_an2_d_web.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_vpc_an2_d_web.id
}

resource "aws_route_table_association" "public_subnet_1_association_vpc_an2_d_web" {
  subnet_id      = aws_subnet.public_subnet_1_vpc_an2_d_web.id
  route_table_id = aws_vpc.vpc_an2_d_web.main_route_table_id
}

resource "aws_route_table_association" "public_subnet_2_association_vpc_an2_d_web" {
  subnet_id      = aws_subnet.public_subnet_2_vpc_an2_d_web.id
  route_table_id = aws_vpc.vpc_an2_d_web.main_route_table_id
}

resource "aws_route_table_association" "private_subnet_1_association_vpc_an2_d_web" {
  subnet_id      = aws_subnet.private_subnet_1_vpc_an2_d_web.id
  route_table_id = aws_route_table.private_route_table_vpc_an2_d_web.id
}

resource "aws_route_table_association" "private_subnet_2_association_vpc_an2_d_web" {
  subnet_id      = aws_subnet.private_subnet_2_vpc_an2_d_web.id
  route_table_id = aws_route_table.private_route_table_vpc_an2_d_web.id
}

// default security group
resource "aws_default_security_group" "security_group_vpc_an2_d_web" {
  vpc_id = aws_vpc.vpc_an2_d_web.id

  ingress  {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group_vpc_an2_d_web"
  }
}

resource "aws_default_network_acl" "network_acl_vpc_an2_d_web" {
  default_network_acl_id = aws_vpc.vpc_an2_d_web.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "network_acl_vpc_an2_d_web"
  }
}


// network acl for public subnets
resource "aws_network_acl" "public_vpc_an2_d_web" {
  vpc_id = aws_vpc.vpc_an2_d_web.id
  subnet_ids = [
    aws_subnet.public_subnet_1_vpc_an2_d_web.id,
    aws_subnet.public_subnet_2_vpc_an2_d_web.id,
  ]

  tags = {
    Name = "public_vpc_an2_d_web"
  }
}

resource "aws_network_acl_rule" "public_vpc_an2_d_web_ingress80" {
  network_acl_id = aws_network_acl.public_vpc_an2_d_web.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_vpc_an2_d_web_egress80" {
  network_acl_id = aws_network_acl.public_vpc_an2_d_web.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_vpc_an2_d_web_ingress443" {
  network_acl_id = aws_network_acl.public_vpc_an2_d_web.id
  rule_number    = 110
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_vpc_an2_d_web_egress443" {
  network_acl_id = aws_network_acl.public_vpc_an2_d_web.id
  rule_number    = 110
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_vpc_an2_d_web_ingress22" {
  network_acl_id = aws_network_acl.public_vpc_an2_d_web.id
  rule_number    = 120
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_vpc_an2_d_web_egress22" {
  network_acl_id = aws_network_acl.public_vpc_an2_d_web.id
  rule_number    = 120
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = aws_vpc.vpc_an2_d_web.cidr_block
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_vpc_an2_d_web_ingress_ephemeral" {
  network_acl_id = aws_network_acl.public_vpc_an2_d_web.id
  rule_number    = 140
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_vpc_an2_d_web_egress_ephemeral" {
  network_acl_id = aws_network_acl.public_vpc_an2_d_web.id
  rule_number    = 140
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}


// network acl for private subnets
resource "aws_network_acl" "private_vpc_an2_d_web" {
  vpc_id = aws_vpc.vpc_an2_d_web.id
  subnet_ids = [
    aws_subnet.private_subnet_1_vpc_an2_d_web.id,
    aws_subnet.private_subnet_2_vpc_an2_d_web.id
  ]

  tags = {
    Name = "private_vpc_an2_d_web"
  }
}

resource "aws_network_acl_rule" "private_vpc_an2_d_web_ingress_vpc" {
  network_acl_id = aws_network_acl.private_vpc_an2_d_web.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = false
  protocol       = -1
  cidr_block     = aws_vpc.vpc_an2_d_web.cidr_block
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_vpc_an2_d_web_egress_vpc" {
  network_acl_id = aws_network_acl.private_vpc_an2_d_web.id
  rule_number    = 100
  rule_action    = "allow"
  egress         = true
  protocol       = -1
  cidr_block     = aws_vpc.vpc_an2_d_web.cidr_block
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_vpc_an2_d_web_ingress_nat" {
  network_acl_id = aws_network_acl.private_vpc_an2_d_web.id
  rule_number    = 110
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_vpc_an2_d_web_egress80" {
  network_acl_id = aws_network_acl.private_vpc_an2_d_web.id
  rule_number    = 120
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_vpc_an2_d_web_egress443" {
  network_acl_id = aws_network_acl.private_vpc_an2_d_web.id
  rule_number    = 130
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

// Basiton Host
resource "aws_security_group" "security_group_bastion_vpc_an2_d_web" {
  name        = "bastion"
  description = "Security group for bastion instance"
  vpc_id      = aws_vpc.vpc_an2_d_web.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group_bastion_vpc_an2_d_web"
  }
}

resource "aws_instance" "bastion_vpc_an2_d_web" {
  ami               = data.aws_ami.latest_ubuntu.id
  availability_zone = aws_subnet.public_subnet_1_vpc_an2_d_web.availability_zone
  instance_type     = "t2.nano"
  key_name          = "dev-key"
  vpc_security_group_ids = [
    aws_default_security_group.security_group_vpc_an2_d_web.id,
    aws_security_group.security_group_bastion_vpc_an2_d_web.id
  ]
  subnet_id                   = aws_subnet.public_subnet_1_vpc_an2_d_web.id
  associate_public_ip_address = true

  tags = {
    Name = "bastion host"
  }
}

resource "aws_eip" "side_effect_bastion" {
  vpc        = true
  instance   = aws_instance.bastion_vpc_an2_d_web.id
  depends_on = [aws_internet_gateway.igw_vpc_an2_d_web]
}
