resource "aws_iam_role" "eb_ec2_role" {
  name = "eb-ec2-role-${local.app_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "eb-instance-profile-${local.app_name}"
  role = aws_iam_role.eb_ec2_role.name
}

resource "aws_iam_policy" "secret_policy" {
  name        = "DB-Secret-Policy${local.app_name}"
  description = "Policy to allow KMS encrypt and decrypt actions"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": data.aws_secretsmanager_secret.aurora_db_credentials.arn
        }
    ]
})
}

resource "aws_iam_policy" "kms_policy" {
  name        = "KMS_Encrypt_Decrypt_Policy-${local.app_name}"
  description = "Policy to allow KMS encrypt and decrypt actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt"
        ],
        Resource = aws_kms_key.eb_key.arn,
        Effect   = "Allow",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "smm_attachment" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "kms_attachment" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = aws_iam_policy.kms_policy.arn
}

resource "aws_iam_role_policy_attachment" "secret_attachment" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = aws_iam_policy.secret_policy.arn
}

resource "aws_iam_role_policy_attachment" "tmp_eb_attach" {
  role       = aws_iam_role.eb_ec2_role.name
  policy_arn = var.tmp_eb_policy_arn
}
