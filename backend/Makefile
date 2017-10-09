build_dev:
	docker build -t memz:backend-dev .


install:
	docker run --rm -it -v ${CURDIR}/memz:/app --workdir /app memz:backend-dev mix deps.get

fmt:
	docker run --rm -v ${CURDIR}/memz:/app --workdir /app memz:backend-dev mix exfmt .

test:
	docker-compose -f docker-compose.test.yml up --abort-on-container-exit
