variable "ami_shared_accounts" {
  type = list(string)
  default = [
    "arn:aws:iam::111111111111:root",                # Parent Account
    "arn:aws:iam::444444444444:root",                # Dev Account
  ]
  description = "Account ARNs to share AMIs with."
}

resource "aws_kms_key" "ami-shared" {
  description             = "Used for shared encrypted AMI builds"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  multi_region            = true
  policy                  = data.aws_iam_policy_document.shared-kms-key.json
}

resource "aws_kms_replica_key" "ami-replica" {
  provider                = aws.us-east-2
  description             = "Multi-Region replica for AMI shared key"
  deletion_window_in_days = 10
  primary_key_arn         = aws_kms_key.ami-shared.arn
  policy                  = data.aws_iam_policy_document.shared-kms-key.json
}


resource "aws_kms_alias" "ami-shared" {
  name          = "alias/shared/ami"
  target_key_id = aws_kms_key.ami-shared.key_id
}

resource "aws_kms_alias" "ami-shared-us-east-2" {
  provider      = aws.us-east-2
  name          = "alias/shared/ami"
  target_key_id = aws_kms_replica_key.ami-replica.key_id
}


data "aws_iam_policy_document" "shared-kms-key" {
  statement {
    sid       = "Allow an external account to use this KMS key"
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant", # Must be in place to update ASG service-linked Grants
      "kms:ListGrants", # Must be in place to update ASG service-linked Grants
      "kms:RevokeGrant" # Must be in place to update ASG service-linked Grants
    ]
    principals {
      type        = "AWS"
      identifiers = var.ami_shared_accounts
    }
  }
  statement {
    sid       = "Allow us to manage this KMS key"
    resources = ["*"]
    effect    = "Allow"
    actions = [
      "kms:*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}
