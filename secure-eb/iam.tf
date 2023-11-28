data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "secure_eb_ec2_policy" {
  name = "secure-eb-ec2-policy-${local.app_name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListBucketAccess",
        "Action" : [
          "s3:List*",
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::elasticbeanstalk-${var.region}-${local.account_id}",
        ]
      },
      {
        "Sid" : "BucketAccess",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::elasticbeanstalk-${var.region}-${local.account_id}/*${local.app_name}*",
          "arn:aws:s3:::elasticbeanstalk-${var.region}-${local.account_id}/*${local.eb_env_id}*",
        ]
      },
      {
        "Sid" : "XRayAccess",
        "Action" : [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ]
      },
      {
        "Sid" : "CloudWatchLogsAccess",
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/elasticbeanstalk/${local.app_name}*"
        ]
      },
      {
        "Sid" : "ElasticBeanstalkHealthAccess",
        "Action" : [
          "elasticbeanstalk:PutInstanceStatistics"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:elasticbeanstalk:${var.region}:${local.account_id}:application/*${local.app_name}*",
          "arn:aws:elasticbeanstalk:${var.region}:${local.account_id}:environment/*${local.app_name}*",
          "arn:aws:elasticbeanstalk:${var.region}:${local.account_id}:environment/*${local.eb_env_id}*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secure_eb_attach" {
  role       = local.eb_role_name
  policy_arn = aws_iam_policy.secure_eb_ec2_policy.arn
  provisioner "local-exec" {
    command = "aws iam detach-role-policy --role-name ${local.eb_role_name} --policy-arn ${local.policy_to_detach_arn}"
  }
}