#!/bin/bash

SOURCE_DIR=$1
TARGET_DIR=$2
VERSION=$3
UVERSION=$(echo ${VERSION} | sed 's/\./_/g')

pushd ${SOURCE_DIR}
git checkout twitter4r_${UVERSION}
popd

pushd ${TARGET_DIR}
git checkout v_${UVERSION}
popd

cp -r ${SOURCE_DIR}/* ${TARGET_DIR}
rm -rf ${TARGET_DIR}/{web,marketing} ${TARGET_DIR}/config/twitter.yml

pushd ${TARGET_DIR}
git add .
git commit -m "Added v ${VERSION} snapshot."
git tag -s twitter4r_v${UVERSION} -m "Tagged version ${VERSION}"
popd
