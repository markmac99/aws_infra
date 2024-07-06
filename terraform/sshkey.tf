
# copyright mark mciontyre, 2024-

# ssh keys
resource "aws_key_pair" "marks_key2" {
  key_name = "marks_key2"
  public_key = file("./files/ssh-keys/markskey.pub")
  tags = {
    "billingtag" = "Management"
  }
}

# ssh keys
resource "aws_key_pair" "marks_key" {
  key_name = "markskey"
  public_key = file("./files/ssh-keys/markskey.pub")
  tags = {
    "billingtag" = "Management"
  }
}