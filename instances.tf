#EBS Volume format and mount
data "template_file" "alias_nvme" {
  template = file("${path.module}/templates/ebs_alias.sh.tpl")
}

data "template_file" "attach_nvme" {
  template = file("${path.module}/templates/ebs_mount.sh.tpl")

  vars = {
    volume_name = var.ebs_device_name
    mount_point = var.ebs_mount_point
    file_system = var.ebs_file_system
  }
}

# Script to install TFE
data "template_file" "tfe_config" {
  template = file("${path.module}/templates/tfe_config.sh.tpl")
  vars = {
    admin_password  = var.admin_password
    rel_seq         = var.rel_seq
    lb_fqdn         = aws_route53_record.alias_record.fqdn
    tfe_mount_point = var.ebs_mount_point
  }
}

data "template_cloudinit_config" "final_config" {

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.alias_nvme.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.attach_nvme.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.tfe_config.rendered
  }

}

# Instance configuration
module "tfe_instance" {
  source                      = "github.com/flamarion/terraform-aws-ec2?ref=v0.0.7"
  ami                         = "ami-0ca5b487ed9f8209f"
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnets_id[0]
  instance_type               = "m5.large"
  key_name                    = aws_key_pair.tfe_key.key_name
  user_data                   = data.template_cloudinit_config.final_config.rendered
  vpc_security_group_ids      = [module.sg.sg_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.tfe_profile.name
  root_volume_size            = 100
  add_ebs                     = true
  size                        = 100
  type                        = "gp2"
  ec2_tags = {
    Name = "${var.owner}-tfe-md-instance"
  }
  ebs_tags = {
    Name = "${var.owner}-tfe-md-ebs"
  }
}

# IAM Role, Policy and Instance Profile 
resource "aws_iam_role" "tfe_role" {
  name               = "${var.owner}_tfe_md_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "tfe_profile" {
  name = "${var.owner}_tfe_md_profile"
  role = aws_iam_role.tfe_role.name
}

resource "aws_iam_policy" "tfe_cloudwatch" {
  name   = "${var.owner}_tfe_md_cloudwatch_policy"
  path   = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.tfe_role.name
  policy_arn = aws_iam_policy.tfe_cloudwatch.arn
}
