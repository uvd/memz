GIT_VERSION = $(shell git describe --always)
DOMAIN ?= testing.memz.uvd.co.uk
ENV ?= testing
AWS_DEFAULT_REGION ?= eu-west-1

install:
	docker run --rm -v ${CURDIR}/memz:/app -w /app node:8 yarn install
	docker run --rm -v ${CURDIR}/memz:/app -w /app node:8 node_modules/.bin/elm-install

serve:
	docker run --rm -it -v ${CURDIR}/memz:/app -p 4200:4200 -w /app node:8 /bin/sh -c 'npm rebuild node-sass; ./node_modules/.bin/webpack-dev-server --host 0.0.0.0 --port 4200 --colors'

mockApi:
	cd memz/mock-api && node api.js

build: install
	docker run --rm \
    --volume ${CURDIR}/memz:/app \
    --workdir /app \
	--env NODE_ENV=${ENV} \
    node:8 \
    sh -c "node_modules/.bin/webpack"

terraform-init:
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	hashicorp/terraform:0.10.7 \
	init

plan: terraform-init
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	hashicorp/terraform:0.10.7 \
	plan


deploy: build plan
	# Create Cloudfront dist via Terraform
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/infrastructure/environments/${ENV} \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	--env TF_VAR_version=${GIT_VERSION} \
	hashicorp/terraform:0.10.7 \
	apply

	# Upload static site to S3
	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/memz/ \
	--env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
	--env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--env AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
	anigeo/awscli:latest \
	s3 cp dist/. s3://${DOMAIN} --acl public-read --recursive --cache-control max-age=120
