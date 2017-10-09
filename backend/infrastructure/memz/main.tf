provider "aws" {
  region = "${var.aws_region}"
}

data "aws_vpc" "app_cluster" {
  tags {
    cluster = "${var.cluster_name}"
  }
}

data "aws_subnet" "app_cluster" {
  vpc_id            = "${data.aws_vpc.app_cluster.id}"
  state             = "available"
  availability_zone = "${element(split(",", var.aws_availability_zones), count.index)}"

  tags {
    cluster = "${var.cluster_name}"
  }

  count = "${length(split(",", var.aws_availability_zones))}"
}

data "aws_route53_zone" "organisation" {
  name = "uvd.co.uk."
}

### ECS uvd containers
data "template_file" "ecs_uvd_def" {
  template = "${file("${path.module}/uvd-def.tpl.json")}"

  vars {
    environment      = "${var.environment}"

    domain = "${var.domain}"

    repository_url = "${var.repository_address}"
    version        = "${var.container_version}"

    weave_cidr = "${var.weave_cidr}"
  }
}

resource "aws_ecs_task_definition" "uvd" {
  family                = "startup-guide_${var.environment}"
  container_definitions = "${data.template_file.ecs_uvd_def.rendered}"
}

resource "aws_ecs_service" "uvd" {
  name            = "startup-guide_${var.environment}"
  cluster         = "${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.uvd.arn}"
  desired_count   = 1

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
}