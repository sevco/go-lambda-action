test: build/example
	echo "Building lambda" && \
		GIT_REVISION=testsha ./entrypoint.sh "hello/hello.go" "example" "" \
		echo "Running cleanup" && ./cleanup.sh
	@echo "Making sure lambda zip was created"
	[ -f build/example/build/artifacts/lambda.master.latest.zip ] || exit 1
	[ -f build/example/build/artifacts/lambda.master.testsha.zip ] || exit 1

.PHONY:
clean:
	@rm -rf build

build/example:
	git clone https://github.com/golang/example build/example
