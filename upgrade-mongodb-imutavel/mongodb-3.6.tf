variable "envtype" {}
variable "instid" {}
variable "role_arn" {
  type = "map"
  default = {
    "PRD" = "arn:aws:iam::123456789012:role/infra-dba-automation"
    "HLG" = "arn:aws:iam::777777777777:role/infra-dba-automation"
    "POC" = "arn:aws:iam::888888888888:role/infra-dba-automation"
    "DEV" = "arn:aws:iam::987654321098:role/infra-dba-automation"
  }
}
variable "region" {
  type = "map"
  default = {
    "PRD" = "sa-east-1"
    "HLG" = "us-east-1"
    "POC" = "us-east-1"
    "DEV" = "us-east-1"
  }
}
variable "zone_id" {
  type = "map"
  default = {
    "PRD" = "Z3XXXXXXXXXXXX"
    "DEV" = "Z4XXXXXXXXXXXX"
    "POC" = "Z2XXXXXXXXXXXX"
    "HLG" = "Z1XXXXXXXXXXXX"
  }
}


provider "aws" {
  region      = "${lookup(var.region,var.envtype)}"
  assume_role {
    role_arn     = "${lookup(var.role_arn,var.envtype)}"
  }
}


data "aws_ami" "mongo" {

  most_recent = true
  owners = ["11223344556677"] # Conta que criou a imagem

  filter {
    name   = "name"
    values = ["mongodb-3.6*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_ebs_volume" "ebs_data" {
  filter {
    name   = "tag:Function"
    values = ["data"]
  }
  filter {
    name   = "attachment.instance-id"
    values = ["${data.aws_instance.mongodb_old.id}"]
  }
}

data "aws_ebs_volume" "ebs_swap" {
  filter {
    name   = "tag:Function"
    values = ["swap"]
  }
  filter {
    name   = "attachment.instance-id"
    values = ["${data.aws_instance.mongodb_old.id}"]
  }
}


data "aws_instance" "mongodb_old" {
  instance_id = "${var.instid}"

}

resource "aws_volume_attachment" "ebs_data" {
  device_name = "/dev/sdb"
  force_detach = true
  volume_id   = "${data.aws_ebs_volume.ebs_data.volume_id}"
  instance_id = "${aws_instance.mongodb.id}"
}

resource "aws_volume_attachment" "ebs_swap" {
  device_name = "/dev/sdc"
  force_detach = true
  volume_id   = "${data.aws_ebs_volume.ebs_swap.volume_id}"
  instance_id = "${aws_instance.mongodb.id}"
}

resource "aws_instance" "mongodb" {
#  ami               = "${var.ami_id}"
  ami               = "${data.aws_ami.mongo.id}"
  instance_type     = "${data.aws_instance.mongodb_old.instance_type}"
  availability_zone = "${data.aws_instance.mongodb_old.availability_zone}"
  subnet_id         = "${data.aws_instance.mongodb_old.subnet_id}"
  vpc_security_group_ids = "${data.aws_instance.mongodb_old.vpc_security_group_ids}"
  tags              = "${data.aws_instance.mongodb_old.tags}"
  key_name          = "${data.aws_instance.mongodb_old.key_name}"
  user_data   = "${file("user-data.sh")}" 

  provisioner "local-exec" {
    command = "./update_dns ${data.aws_instance.mongodb_old.private_ip} ${aws_instance.mongodb.private_ip} ${var.envtype} ${lookup(var.zone_id,var.envtype)}"
  }

}

