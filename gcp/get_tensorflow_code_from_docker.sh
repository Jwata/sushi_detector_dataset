#!/bin/bash

docker run --name tf-object-detection jwata/tensorflow-object-detection /bin/true
docker cp tf-object-detection:/tensorflow-models/research/dist/object_detection-0.1.tar.gz dist
docker cp tf-object-detection:/tensorflow-models/research/slim/dist/slim-0.1.tar.gz dist
docker rm tf-object-detection
