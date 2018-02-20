#!/bin/bash
# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#  http://aws.amazon.com/apache2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#
set -e

PROJECT_DIR=`pwd`
cd ..

#build checksums
git clone https://github.com/awslabs/aws-checksums.git
mkdir checksums-build && cd checksums-build
cmake ../aws-checksums
make -j && make test
cd ..

#build aws-c-common
git clone https://github.com/awslabs/aws-c-common.git
mkdir common-build && cd common-build
cmake ../aws-c-common
make -j && make test
cd ..

#build aws-c-event-stream
cd $PROJECT_DIR
cppcheck --enable=all --std=c99 --language=c --suppress=unusedFunction -I include ../aws-checksums/include ../aws-c-common/include --force --error-exitcode=-1 ./
cd ..
mkdir build && cd build
cmake -Daws-checkums_DIR="../checksums-build" -Daws-c-common_DIR="../common-build" $PROJECT_DIR
make && make test