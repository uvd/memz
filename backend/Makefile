BACKEND_BUILD = ${CURDIR}/memz.tar.gz

build_dev:
	docker build -t memz:backend-dev .

install:
	docker run --rm -it -v ${CURDIR}/memz:/app --workdir /app memz:backend-dev mix deps.get

fmt:
	docker run --rm -v ${CURDIR}/memz:/app --workdir /app memz:backend-dev mix exfmt .

test:
	docker-compose -f docker-compose.test.yml up --abort-on-container-exit

build:
	@echo "Building backend release"

	docker run --rm \
	--volume ${CURDIR}:/app \
	--workdir /app/memz \
	elixir:latest \
	sh -c "mix local.hex --force; mix local.rebar --force; MIX_ENV=prod mix do compile, phx.digest, release --env=prod"

	rm -f ${BACKEND_BUILD}

	cp ${CURDIR}/memz/_build/prod/rel/memz/releases/0.0.1/memz.tar.gz \
	${BACKEND_BUILD}

	docker build \
	-f Dockerfile.release \
	-t memz:latest \
	.