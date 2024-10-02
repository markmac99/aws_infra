# copyright mark mciontyre, 2024-

# create the batch server

resource "aws_instance" "testserver" {
  ami                    = "ami-0e8d228ad90af673b"  # ubuntu 22.04
  instance_type          = "c6a.4xlarge" # x64, 16 cpu, 32 GB 
  #ami                    = "ami-078efbc5c23916053" # Amazon Linux 3 
  #instance_type          = "c6g.4xlarge" # arm64, 16 cpu, 32 GB
  iam_instance_profile = data.aws_iam_instance_profile.s3fullaccess.name
  key_name             = aws_key_pair.marks_key.key_name
  security_groups      = [aws_security_group.ec2publicsg.name]

  root_block_device {
    tags = {
      "Name"       = "TestServerRootDisk"
      "billingtag" = "GMN"
    }
    volume_size = 40
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
    "Name"       = "testserver"
    "billingtag" = "GMN"
  }
}

resource "aws_route53_record" "testserver" {
  zone_id   = data.aws_route53_zone.mjmmwebsite.zone_id
  type      = "A"
  name      = "testserver"
  records   = [aws_instance.testserver.public_ip]
  ttl       = 300
}

