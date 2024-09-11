
#---------------------------
# EFS用セキュリティグループ
#---------------------------

resource "aws_security_group" "efs_sg_01" {
  name        = "${var.project}-${var.env}-efs-sg-01"
  description = "Security group for EFS access"
  vpc_id      = data.aws_vpc.orion_01.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.private-1a.cidr_block, data.aws_subnet.private-1c.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-efs-sg-01"
  }
}

#----------------------------
# EC2用セキュリティグループ
#----------------------------

resource "aws_security_group" "ec2_sg_01" {
  name        = "${var.project}-${var.env}-ec2-sg-01"
  description = "Security group for ec2 apache access"
  vpc_id      = data.aws_vpc.orion_01.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.public-1a.cidr_block, data.aws_subnet.public-1c.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.env}-ec2-sg-01"
  }
}