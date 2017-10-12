provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.0"
}

provider "template" {
  version = "~> 1.0"
}

### ECS containers
#### ECS Memz container
data "template_file" "ecs_memz-backend_def" {
  template = "${file("${path.module}/memz-backend-ecs-def.tpl.json")}"

  vars {
    environment = "${var.environment}"

    secret_key_base     = "${var.secret_key_base}"
    guardian_secret_key = "${var.guardian_secret_key}"
    postgres_host       = "postgres-${var.environment}.weave.local"
    postgres_db         = "memz_${var.environment}"
    postgres_user       = "memz_${var.environment}"
    postgres_password   = "${var.postgres_password}"
    postgres_port       = "5432"

    domain = "${var.domain}"

    repository_url = "${var.repository_address}"
    version        = "${var.container_version}"

    cloudwatch_log_group = "${aws_cloudwatch_log_group.memz-backend.arn}"
    cloudwatch_region    = "${var.aws_region}"

    weave_cidr = "${var.weave_cidr}"
  }
}

resource "aws_ecs_task_definition" "memz-backend" {
  family                = "memz-backend_${var.environment}"
  container_definitions = "${data.template_file.ecs_memz-backend_def.rendered}"
}

resource "aws_ecs_service" "memz-backend" {
  name            = "memz-backend_${var.environment}"
  cluster         = "${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.memz-backend.arn}"
  desired_count   = 1

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
}

#### ECS Postgres container
data "template_file" "ecs_postgres_def" {
  template = "${file("${path.module}/postgres-def.tpl.json")}"

  vars {
    db_username = "memz_${var.environment}"
    db_password = "${var.postgres_password}"
    db_name     = "memz_${var.environment}"
    environment = "${var.environment}"
    weave_cidr  = "${var.weave_cidr}"
  }
}

resource "aws_ecs_task_definition" "postgres" {
  family                = "postgres_${var.environment}"
  container_definitions = "${data.template_file.ecs_postgres_def.rendered}"
}

resource "aws_ecs_service" "postgres" {
  name            = "memz-postgres_${var.environment}"
  cluster         = "${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.postgres.arn}"
  desired_count   = 1

  placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

#### Log group
resource "aws_cloudwatch_log_group" "memz-backend" {
  name = "${var.environment}.memz-backend-container-logs"

  retention_in_days = 7

  tags {
    Name        = "memz-backend"
    Environment = "${var.environment}"
  }
}

### Sub-domain under uvd.co.uk
data "aws_route53_zone" "organisation" {
  name = "uvd.co.uk."
}

resource "aws_route53_record" "domain" {
  zone_id = "${data.aws_route53_zone.organisation.zone_id}"
  name    = "${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["traefik.uvd.co.uk"]
}
