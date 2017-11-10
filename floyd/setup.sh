#!/bin/bash

tar -xvf dist/object_detection-0.1.tar.gz
pushd object_detection-0.1
  python setup.py install
popd

tar -xvf dist/slim-0.1.tar.gz
pushd slim-0.1
  python setup.py install
popd
