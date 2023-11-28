resource "aws_kms_key" "eb_key" {
  description             = "KMS key for Elastic Beanstalk"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "kms_eb_alias" {
  name          = "alias/eb-${local.app_name}"
  target_key_id = aws_kms_key.eb_key.key_id
}
