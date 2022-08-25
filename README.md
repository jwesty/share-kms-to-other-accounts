# share-kms-to-other-accounts

This repo applies specifically to the challenges in getting a KMS Key shared to an account, to use AWS Auto Scaling Groups where your AMI/EBS is encrypted within one account but needed elsewhere (additional accounts), and helps avoid some of the pitfalls of Terraform's missing documentation. 

There's TONS of information on the web about sharing a KMS key with another account. This requires that you NOT use the AWS Default KMS key. Here's some resources that tripped me up along the way: 
- https://docs.aws.amazon.com/autoscaling/ec2/userguide/key-policy-requirements-EBS-encryption.html
- https://docs.aws.amazon.com/kms/latest/developerguide/create-primary-keys.html
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant
- https://github.com/hashicorp/terraform-provider-aws/issues/4141

## Simplification
- Use the parent-account.tf in your main account that will hold the KMS key (the one to be shared) and modify the account numbers as needed
- Use the child-account.tf in your secondary account that will receive the KMS key. 

## Example
- The parent_account.tf has 2 values that need to be updated. Replace  `111111111111` with the account number that owns the KMS key and `444444444444` with the account you are sharing the KMS key to (child account). This terraform will get deployed to the account that owns the KMS key.
- Likewise, in the child_account.tf file, replace `111111111111` with the account number that owns the KMS key and `444444444444` with the account you are sharing the KMS key to (child account). This terraform will get deployed to the account that is RECEIVING the KMS key.
