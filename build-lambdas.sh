#!/bin/bash

set -eu

echo "x"
lambdaZipFolder="terraform/lambda-functions/zipped-lambdas"

rm -rf $lambdaZipFolder
mkdir -p $lambdaZipFolder

zip_lambda() {
    local folder=$lambda
    local name=$(basename $folder)
    zip --junk-paths --quiet --recurse-paths $lambdaZipFolder/$name.zip $folder/*

    echo "Zipped $name"
}

pids=""
for lambda in functions/*; do
    zip_lambda $lambda &
    pids+=" $!" 
done

for pid in $pids; do
    wait $pid || exit $?
done

echo ""
echo "Done"
