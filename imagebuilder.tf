#-------------------
# Component
#-------------------

resource "aws_imagebuilder_component" "build_01" {
  name     = "${var.project}-${var.env}-image-build-01"
  version  = "1.0.0"
  platform = "Linux"

  data = <<EOF
 {
  "schemaVersion": "1.0",
  "phases": [
    {
      "name": "build",
      "steps": [
        {
          "name": "MoveFiles",
          "action": "ExecuteBash",
          "inputs": {
            "commands": [
              "aws s3 cp s3://cicd-dev-s3-01 /var/tmp",
              "ls -l /var/tmp/build.html",
              "chown root:root /var/tmp/build.html",
              "mv /var/tmp/build.html /var/www/html/build.html",
              "systemctl restart httpd.service"
            ]
          }
        }
      ]
    },
    {
      "name": "validate",
      "steps": [
        {
          "name": "CheckStatus",
          "action": "ExecuteBash",
          "inputs": {
            "commands": [
              "systemctl status httpd.service"
            ]
          }
        }
      ]
    }
  ]
 }
EOF

}

#-----------------
# Image Recipe
#-----------------

#locals {
#    ami_arn = "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:image/ami-07a4ccba8d6475860"
#}

resource "aws_imagebuilder_image_recipe" "recipe_01" {
  name         = "${var.project}-${var.env}-image-recipe-01"
  version      = "1.0.0"
  parent_image = "ami-07a4ccba8d6475860"

  component {
    component_arn = aws_imagebuilder_component.build_01.arn
  }

  block_device_mapping {
    device_name = "/dev/xvda1"

    ebs {
      delete_on_termination = true
      volume_size           = 64
      volume_type           = "gp2"
      iops                  = 192
    }
  }
}

#-----------------
# Infra Settings
#-----------------

resource "aws_imagebuilder_infrastructure_configuration" "infra_01" {
  instance_profile_name = aws_iam_instance_profile.ec2_profile_01.name
  name                  = "${var.project}-${var.env}-image-infra-settings-01"
  instance_types        = ["t3.medium"]
  key_pair              = var.image-key-pair
  subnet_id             = data.aws_subnet.public-1a.id
  security_group_ids    = [aws_security_group.ec2_sg_01.id]
}


#-------------------------
# Distribution Settings
#-------------------------

resource "aws_imagebuilder_distribution_configuration" "distribution_01" {
  name = "${var.project}-${var.env}-image-dist-settings-01"

  distribution {
    region = data.aws_region.current.name
    ami_distribution_configuration {
      name = "ami-{{ imagebuilder:buildDate }}"
    }
  }
}

#-------------------------
# Image Pipeline Settings
#-------------------------

resource "aws_imagebuilder_image_pipeline" "example_pipeline" {
  name                             = "${var.project}-${var.env}-image-pipeline-01"
  image_recipe_arn                 = aws_imagebuilder_image_recipe.recipe_01.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.infra_01.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.distribution_01.arn
  status                           = "ENABLED"
}
