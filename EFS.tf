#-----------------
# EFS作成
#-----------------

resource "aws_efs_file_system" "orion-efs" {
  encrypted = true
  tags = {
    Name = "${var.project}-${var.env}-efs-01"
  }
  throughput_mode = "elastic"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

#-----------------------
# マウントターゲット作成
#-----------------------

resource "aws_efs_mount_target" "orion-efs-1a" {
  file_system_id  = aws_efs_file_system.orion-efs.id
  subnet_id       = data.aws_subnet.private-1a.id
  security_groups = [aws_security_group.efs_sg_01.id]
}

resource "aws_efs_mount_target" "orion-efs-1c" {
  file_system_id  = aws_efs_file_system.orion-efs.id
  subnet_id       = data.aws_subnet.private-1c.id
  security_groups = [aws_security_group.efs_sg_01.id]
}

#----------------------
# EFS Access Point
#----------------------

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.orion-efs.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/efs"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "755"
    }
  }
}