#!/bin/bash

SOURCE_DIR=$1
TARGET_DIR=$2
VERSION=$3
UVERSION=$(echo ${VERSION} | sed 's/\./_/g')
GIT_COMMITTER_DATE=$4

pushd ${SOURCE_DIR}
git checkout twitter4r_${UVERSION}
popd

pushd ${TARGET_DIR}
git checkout clean
git branch v${VERSION}
git checkout v${VERSION}
popd

cp -r ${SOURCE_DIR}/* ${TARGET_DIR}
rm -rf ${TARGET_DIR}/{web,marketing} ${TARGET_DIR}/config/twitter.yml

pushd ${TARGET_DIR}
git add .
git commit -m "Added v ${VERSION} snapshot."
git tag -s twitter4r-v${VERSION} -m "Tagged version ${VERSION}"
git checkout utilities
popd
