# copyright mark mcintyre, 2025-

# IAM users and roles for meteor cameras, radio detector, weather sat receiver etc

resource "aws_iam_user" "radiometeor" {
  name = "radiometeor"
  tags = {
    "billingtag" = "MarksWebsite"
  }
}

resource "aws_iam_user_policy" "radiopolicy" {
  name        = "ukmdaAccessForRadio"
  user = aws_iam_user.radiometeor.name
  policy      = data.template_file.radiometeor_iamtempl.rendered
}

data "template_file" "radiometeor_iamtempl" {
  template = file("files/policies/radiometeor-policy.json")
}

