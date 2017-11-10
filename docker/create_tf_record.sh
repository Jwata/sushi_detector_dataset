#!/bin/sh

cd /tensorflow

./floyd/setup.sh

python create_tf_record.py \
  --annotations_dir=/tensorflow/data/annotations \
  --images_dir=/tensorflow/data/images \
  --output_dir=/tensorflow/data/ \
  --label_map_path=/tensorflow/data/sushi_label_map.pbtxt
