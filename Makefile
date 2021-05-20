test: image build/lambda-go-samples
	image=$(shell docker build -q .) && \
		echo "Building lambda in container" && \
		docker run --rm -v $$PWD/build:/github/home \
			-e GITHUB_SHA=testshaabcdefg \
			-e GITHUB_REF=refs/heads/branch \
			$$image "main.go" "lambda-go-samples" "" && \
		echo "Running cleanup" && \
		docker run --rm --entrypoint /usr/local/bin/cleanup.sh -v $$PWD/build:/github/home $$image
	@echo "Making sure lambda zip  was created"
	[ -f build/lambda-go-samples/build/artifacts/lambda.branch.latest.zip ] || exit 1

image: 
	@docker build .	

.PHONY:
clean:
	@rm -rf build

build/lambda-go-samples:
	git clone https://github.com/aws-samples/lambda-go-samples build/lambda-go-samples