# Copyright (C) 2018- Mark McIntyre

# Terraform to create the Security Groups in my account

# __generated__ by Terraform from "sg-fb720192"
resource "aws_security_group" "default" {
  description = "default VPC security group"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "http in"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
    }, {
    cidr_blocks      = ["86.0.0.0/8"]
    description      = "SSH for Admin"
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    }, {
    cidr_blocks      = []
    description      = "echo from sg8115c"
    from_port        = 8
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "icmp"
    security_groups  = [ aws_security_group.launch-wizard-4.id ] #"sg-0839c64ae44d8115c"]
    self             = false
    to_port          = -1
    }, {
    cidr_blocks      = []
    description      = "traffic from sg20192"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = true
    to_port          = 0
  }]
  name                   = "default"
  name_prefix            = null
  region                 = var.region
  revoke_rules_on_delete = null
  tags = {
    billingtag = "Management"
  }
  tags_all = {
    billingtag = "Management"
  }
  vpc_id = aws_vpc.main_vpc.id
}

# __generated__ by Terraform from "sg-0839c64ae44d8115c"
resource "aws_security_group" "launch-wizard-4" {
  description = "launch-wizard-4 created 2020-02-10T21:59:13.598+00:00"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "SSH for Admin"
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    }, {
    cidr_blocks      = []
    description      = "IPv6 SSH for Admin"
    from_port        = 22
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    }, {
    cidr_blocks      = []
    description      = "NFS"
    from_port        = 2049
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = true
    to_port          = 2049
  }]
  name                   = "launch-wizard-4"
  name_prefix            = null
  region                 = var.region
  revoke_rules_on_delete = null
  tags = {
    billingtag = "Management"
  }
  tags_all = {
    billingtag = "Management"
  }
  vpc_id = aws_vpc.main_vpc.id 
}

