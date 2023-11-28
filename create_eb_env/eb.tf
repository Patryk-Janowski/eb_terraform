resource "aws_elastic_beanstalk_application" "best-vulpy-app" {
  name = local.app_name # The name of your existing Elastic Beanstalk application
}

data "external" "latest_python_stack" {
  program = ["./get_latest_solution_stack.sh"]
}

resource "aws_elastic_beanstalk_environment" "best-vulpy-env" {
  name                = "${local.app_name}-env" # The name of your existing Elastic Beanstalk environment
  application         = aws_elastic_beanstalk_application.best-vulpy-app.name
  solution_stack_name = data.external.latest_python_stack.result["latest_solution_stack_name"]

  # The state provides several settings under "all_settings"
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DB_HOST"
    value     = aws_rds_cluster.aurora_cluster_eb.endpoint
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DB_PORT"
    value     = aws_rds_cluster.aurora_cluster_eb.port
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_DB_SECRET_NAME"
    value     = data.aws_secretsmanager_secret.aurora_db_credentials.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = var.region
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.eb_vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", local.private_subnets_list)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.eb_ec2_sg.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", local.public_subnets_list)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/api/health"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Endpoint"
    value     = "patryk_janowski@icloud.com"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "arn:aws:iam::758538809139:role/aws-elasticbeanstalk-service-role"
  }

  # setting {
  #   namespace = "aws:elasticbeanstalk:xray"
  #   name      = "XRayEnabled"
  #   value     = "true"
  # }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = "SAT:00:00"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = "minor"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

 setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }

 setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Protocol"
    value     = "email"
  }

 setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = "true"
  }

}
