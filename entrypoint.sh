#!/bin/bash

set -e

if [ "x$3" != "x" ]; then
    echo $3 > .git_credentials
    git config --global credential.helper "store --file $PWD/.git_credentials"
    git config --global --add "url.https://github.com/.insteadOf" "ssh://git@github.com/"
    git config --global --add "url.https://github.com/.insteadOf" "git@github.com:"
fi

if [ "x$2" != "x" ]; then
    cd $2
fi

if [ -z "$GIT_REVISION" ]; then
    echo "Parsing git revision"
    GIT_REVISION=$(git rev-parse --short HEAD)
fi

if  [ -z "$GIT_BRANCH" ]; then 
    echo "Parsing git branch"
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi



export GOPATH=$PWD/go:$GOPATH
mkdir -p go

if [[ -f go.mod ]]; then
    echo "Downloading modules"
    go mod download || true
else 
    echo "Downloading deps"
    go get -d ./ || true
fi

mkdir -p build/output build/artifacts

echo "Building files"
for file in $1
do
    echo "Building $file"
    EXECUTABLE=$(basename $file .go)
    REVISION_ZIP="${EXECUTABLE}.${GIT_BRANCH}.${GIT_REVISION}.zip"
    LATEST_ZIP="${EXECUTABLE}.${GIT_BRANCH}.latest.zip"
    go build -o build/output/bootstrap $file
    echo "Packaging lambda zip"
    pushd build/output
    zip -9yr ../artifacts/$REVISION_ZIP *
    cp ../artifacts/$REVISION_ZIP ../artifacts/$LATEST_ZIP
    popd
    echo "Successfully created $REVISION_ZIP and $LATEST_ZIP"
done


