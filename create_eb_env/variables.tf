variable "region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnets" {
  default = {
    public_2a  = { cidr_block = "10.0.1.0/24", availability_zone = "us-west-2a" }
    private_2a = { cidr_block = "10.0.2.0/24", availability_zone = "us-west-2a" }
    db_2a      = { cidr_block = "10.0.3.0/24", availability_zone = "us-west-2a" }
    public_2b  = { cidr_block = "10.0.4.0/24", availability_zone = "us-west-2b" }
    private_2b = { cidr_block = "10.0.5.0/24", availability_zone = "us-west-2b" }
    db_2b      = { cidr_block = "10.0.6.0/24", availability_zone = "us-west-2b" }
  }
}

variable "eb_app_name" {
  description = "The name of the Elastic Beanstalk app"
  type        = string
  default     = "best-vulpy"
}

variable "tmp_eb_policy_arn" {
  description = "ARN of initial IAM policy for EB EC2 instances"
  type = string
  default = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}