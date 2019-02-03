install:
	cd app && ./mvnw install -DskipTests=true -Dmaven.javadoc.skip=true -B -V

test: install
	cd app && ./mvnw test -B

bake:
	packer build -var 'aws_access_key=${AWS_ACCESS_KEY}' -var 'aws_secret_key=${AWS_SECRET_KEY}' packer.json

deploy:
	cd terraform/$(ENV); \
	terraform init; \
	terraform apply -input=false -auto-approve \
	 -var 'aws_amis={eu-west-1="'$(AMIID)'"}' -var 'env="$(ENV)"'

