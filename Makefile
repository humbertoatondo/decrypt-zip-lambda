ifneq (,$(wildcard ./.env))
    include .env
    export
endif

docker-build:
	@docker build --build-arg AWS_ACCESS_KEY=${AWS_ACCESS_KEY} \
	--build-arg AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
	--build-arg AWS_REGION=${AWS_REGION} \
	-t decrypt-zip .

docker-run:
	@docker run -d --name decrypt-zip decrypt-zip