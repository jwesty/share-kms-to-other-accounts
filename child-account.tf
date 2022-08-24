data "aws_iam_policy_document" "allow_sdlc_key_attachment" {
  statement {
    sid    = "Allow attachment of persistent resources in external account SDLC 118759334272"
    effect = "Allow"
    actions = [
      "kms:CreateGrant", # Must be in place to update ASG service-linked Grants
      "kms:ListGrants", # Must be in place to update ASG service-linked Grants
      "kms:Delete*" # Must be in place to update ASG service-linked Grants
    ]
    principals {
      identifiers = [
        "arn:aws:iam::111111111111:root", # Parent Account
      ]
      type = "AWS"
    }
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "attach_key_to_asg_role" {
  statement {
    sid    = "Allow attachment of persistent resources in THIS account"
    effect = "Allow"
    actions = [
      "kms:CreateGrant"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::444444444444:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      ]
      type = "AWS"
    }
    resources = ["*"]
  }
}

resource "aws_kms_grant" "grant_autoscaling_access" {
  name              = "grant_autoscaling_access"
  key_id            = "arn:aws:kms:us-east-1:111111111111:key/mrk-aba987533295487881cd2fe2b0c072cf"
  grantee_principal = "arn:aws:iam::444444444444:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  operations = [
    "Encrypt",
    "Decrypt",
    "ReEncryptFrom",
    "ReEncryptTo",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "DescribeKey",
    "CreateGrant"
  ]
}
