#!/bin/sh

docker run -it \
  --volume `pwd`/data:/data \
  --volume `pwd`/create_tf_record.py:/tensorflow-models/research/create_tf_record.py \
  jwata/tensorflow-object-detection \
  python create_tf_record.py \
    --annotations_dir=/data/annotations \
    --images_dir=/data/images \
    --output_dir=/data/ \
    --label_map_path=/data/sushi_label_map.pbtxt
