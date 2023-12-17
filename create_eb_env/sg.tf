resource "aws_security_group" "eb_ec2_sg" {
  name        = "eb_ec2_sg"
  description = "default sg for EB EC2instances"
  vpc_id      = aws_vpc.eb_vpc.id # Replace with your VPC ID

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all IPs
  }

  tags = {
    Name = "eb_ec2_sg"
  }
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow MySQL traffic from default SG"
  vpc_id      = aws_vpc.eb_vpc.id # Replace with your VPC ID

  ingress {
    description = "MySQL access from default SG"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"] # Allow all IPs
    security_groups = [aws_security_group.eb_ec2_sg.id] # Replace with your default SG ID
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all IPs
  }

  tags = {
    Name = "allow_mysql"
  }
}

