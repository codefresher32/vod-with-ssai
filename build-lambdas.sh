#!/bin/bash

set -eu

echo "x"
rm -f terraform/source-uploader/function/source-uploader.zip
zip --junk-paths --quiet --recurse-paths terraform/source-uploader/function/source-uploader.zip terraform/source-uploader/function/*