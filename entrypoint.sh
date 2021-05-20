#!/bin/bash

set -e

if [ "x$3" != "x" ]; then
    echo $3 > .git_credentials
    git config --global credential.helper "store --file $PWD/.git_credentials"
    git config --global "url.https://github.com/.insteadOf" "ssh://git@github.com/"
    git config --global --add "url.https://github.com/.insteadOf" "git@github.com:"
fi

if [ "x$2" != "x" ]; then
    cd $2
fi

GIT_REVISION=$(echo $GITHUB_SHA | cut -c1-7 )
GIT_BRANCH="${GITHUB_REF##*/}"

REVISION_ZIP="lambda.${GIT_BRANCH}.${GIT_REVISION}.zip"
LATEST_ZIP="lambda.${GIT_BRANCH}.latest.zip"

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
    go build -o build/output/ $file
done

echo "Packaging lambda zip"
cd build/output
zip -9yr ../artifacts/$REVISION_ZIP *
cp ../artifacts/$REVISION_ZIP ../artifacts/$LATEST_ZIP

echo "Successfully created $REVISION_ZIP and $LATEST_ZIP"