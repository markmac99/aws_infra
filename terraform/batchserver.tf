# copyright mark mciontyre, 2024-

# create the batch server

data "aws_kms_key" "container_key" {
    key_id = "arn:aws:kms:eu-west-2:317976261112:key/e9b72945-eaac-4452-9708-93963b09976d"
}

resource "aws_instance" "batchserver2026" {
  ami                  = "ami-05a11327df75a9840" # "ami-0fe87e3ed54a170ce"
  instance_type        = "t4g.small"
  iam_instance_profile = data.aws_iam_instance_profile.s3fullaccess.name
  key_name             = aws_key_pair.marks_key.key_name
  security_groups      = [aws_security_group.ec2publicsg.name]
  # associate_public_ip_address = false # cant do this in a public subnet

  root_block_device {
    tags = {
      "Name"       = "Batcherver2026RootDisk"
      "billingtag" = "Management"
    }
    volume_size = 30
    volume_type = "gp3"
    throughput = 125
    iops = 3000
    encrypted = true
    kms_key_id = data.aws_kms_key.container_key.arn
  }
  private_dns_name_options {
     hostname_type  = "resource-name"
  }

    metadata_options {
        http_tokens = "required"
        instance_metadata_tags = "enabled"
    }

  tags = {
    "Name"       = "batchserver2026"
    "billingtag" = "Management"
    "Route53FQDN" = "batchserver.markmcintyreastro.co.uk"
    "DNSRecordType" = "A"
  }
}

resource "aws_network_interface" "batchserver_nic" {
  subnet_id   = aws_subnet.ec2Subnet.id
  ipv6_address_count = 1
  ipv6_address_list_enabled = false
  private_ip_list_enabled   = false
  attachment {
    instance = aws_instance.batchserver2026.id
    device_index = 0
  }
  tags = {
    billingtag = "Management"
  }
}

resource "aws_security_group" "ec2publicsg" {
  name        = "ec2PublicSG"
  description = "Public SG used by EC2"
  vpc_id      = aws_vpc.main_vpc.id
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "SSH for Admin"
      from_port        = 22
      protocol         = "tcp"
      to_port          = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      cidr_blocks      = ["194.0.0.0/8"]
      description      = "MariaDB"
      from_port        = 3306
      protocol         = "tcp"
      to_port          = 3306
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      cidr_blocks      = []
      description      = "NFS"
      from_port        = 2049
      protocol         = "tcp"
      to_port          = 2049
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "IMAPS"
      from_port        = 993
      protocol         = "tcp"
      to_port          = 993
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      cidr_blocks      = [
         "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 3389
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 3389
    },
    {
      cidr_blocks      = []
      description      = "ssh ipv6"
      from_port        = 22
      ipv6_cidr_blocks = ["::/0",]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "icmp"
      from_port        = -1
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "icmp"
      security_groups  = []
      self             = false
      to_port          = -1
    }, 
          {
              cidr_blocks      = ["0.0.0.0/0"]
              description = "mariadb"
              from_port        = 3306
              ipv6_cidr_blocks = []
              prefix_list_ids  = []
              protocol         = "tcp"
              security_groups  = []
              self             = false
              to_port          = 3306
            },    

  ]
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  tags = {
    billingtag = "Management"
  }
}

