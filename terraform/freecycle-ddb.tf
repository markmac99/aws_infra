resource "aws_dynamodb_table" "freecycle_table" {
  name         = "freecycle"
  billing_mode = "PAY_PER_REQUEST"
  provider     = aws.euw1-prov

  hash_key  = "uniqueid"
  range_key = "recType"

  attribute {
    name = "uniqueid"
    type = "S"
  }
  attribute {
    name = "recType"
    type = "S"
  }
  attribute {
    name = "Item"
    type = "S"
  }
  
  global_secondary_index {
    name               = "recType-item-index"
    hash_key           = "recType"
    range_key          = "Item"
    projection_type    = "ALL"
    non_key_attributes = []
    read_capacity      = 0
    write_capacity     = 0
  }
  ttl {
    attribute_name = "expirydate"
    enabled        = true
  }
  tags = {
    Name       = "freecycle"
    billingtag = "freecycle"
  }
}

resource "aws_dynamodb_table" "toycycle_table" {
  name         = "toycycle"
  billing_mode = "PAY_PER_REQUEST"
  provider     = aws.euw1-prov

  hash_key  = "uniqueid"
  range_key = "recType"

  attribute {
    name = "uniqueid"
    type = "S"
  }
  attribute {
    name = "recType"
    type = "S"
  }
  attribute {
    name = "Item"
    type = "S"
  }
  
  global_secondary_index {
    name               = "recType-item-index"
    hash_key           = "recType"
    range_key          = "Item"
    projection_type    = "ALL"
    non_key_attributes = []
    read_capacity      = 0
    write_capacity     = 0
  }
  ttl {
    attribute_name = "expirydate"
    enabled        = true
  }
  tags = {
    Name       = "freecycle"
    billingtag = "freecycle"
  }
}
