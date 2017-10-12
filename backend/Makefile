GIT_VERSION = $(shell git describe --always)
DOCKER_IMAGE = 133282649214.dkr.ecr.eu-west-1.amazonaws.com/memz-backend
AWS_DEFAULT_REGION ?= eu-west-1
ENV ?= testing

build_dev:
	docker build -f Dockerfile.dev -t ${DOCKER_IMAGE}:backend-dev .

install: build_dev
	docker run --rm -it -v ${CURDIR}/memz:/app --workdir /app ${DOCKER_IMAGE}:backend-dev mix deps.get

fmt:
	docker run --rm -v ${CURDIR}/memz:/app --workdir /app ${DOCKER_IMAGE}:backend-dev mix exfmt .

test: install
	docker-compose -f docker-compose.test.yml up --abort-on-container-exit

build:
	@echo "Building backend release"

	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/memz \
	elixir:latest \
	sh -c "mix local.hex --force; mix local.rebar --force; MIX_ENV=prod mix do deps.get, compile, phx.digest, release --env=prod"

	docker build \
	-f Dockerfile.release \
	-t ${DOCKER_IMAGE}:${GIT_VERSION} \
	-t ${DOCKER_IMAGE}:latest \
	-t memz:latest \
	.

get-keys:
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	anigeo/awscli:latest \
	s3 cp s3://uvd-keys/memz-backend/${ENV}.terraform.tfvars terraform.tfvars

terraform-init:
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	hashicorp/terraform:0.10.7 \
	init

plan: get-keys terraform-init
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	--env TF_VAR_container_version=${GIT_VERSION} \
	--env TF_VAR_repository_address=${DOCKER_IMAGE} \
	hashicorp/terraform:0.10.7 \
	plan

deploy: build get-keys terraform-init plan
	# Log in to ECR registry
	$(shell	docker run --rm \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	anigeo/awscli:latest \
	ecr get-login --no-include-email)

	docker push ${DOCKER_IMAGE}:${GIT_VERSION}
	docker push ${DOCKER_IMAGE}:latest

	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	--env TF_VAR_container_version=${GIT_VERSION} \
	--env TF_VAR_repository_address=${DOCKER_IMAGE} \
	hashicorp/terraform:0.10.7 \
	apply

destroy: get-keys terraform-init
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	--env TF_VAR_container_version=${GIT_VERSION} \
	--env TF_VAR_repository_address=${DOCKER_IMAGE} \
	hashicorp/terraform:0.10.7 \
	destroy --force
