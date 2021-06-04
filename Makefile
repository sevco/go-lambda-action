test: image build/lambda-go-samples
	image=$(shell docker build -q .) && \
		echo "Building lambda in container" && \
		docker run --rm -v $$PWD/build:/github/home \
			-e GIT_REVISION=testsha \
			$$image "main.go" "lambda-go-samples" "" && \
		echo "Running cleanup" && \
		docker run --rm --entrypoint /usr/local/bin/cleanup.sh -v $$PWD/build:/github/home $$image
	@echo "Making sure lambda zip  was created"
	[ -f build/lambda-go-samples/build/artifacts/lambda.master.latest.zip ] || exit 1
	[ -f build/lambda-go-samples/build/artifacts/lambda.master.testsha.zip ] || exit 1

image: 
	@docker build .	

.PHONY:
clean:
	@rm -rf build

build/lambda-go-samples:
	git clone https://github.com/aws-samples/lambda-go-samples build/lambda-go-samples