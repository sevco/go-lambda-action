test: image build/example
	image=$(shell docker build -q .) && \
		echo "Building lambda in container" && \
		docker run --rm -v $$PWD/build:/github/home \
			-e GIT_REVISION=testsha \
			$$image "hello/hello.go" "example" "" && \
		echo "Running cleanup" && \
		docker run --rm --entrypoint /usr/local/bin/cleanup.sh -v $$PWD/build:/github/home $$image
	@echo "Making sure lambda zip  was created"
	[ -f build/example/build/artifacts/lambda.master.latest.zip ] || exit 1
	[ -f build/example/build/artifacts/lambda.master.testsha.zip ] || exit 1

image: 
	@docker build .	

.PHONY:
clean:
	@rm -rf build

build/example:
	git clone https://github.com/golang/example build/example