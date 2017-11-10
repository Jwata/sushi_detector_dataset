#!/bin/sh

ln -s /tensorflow/data /data

cd /tensorflow

./floyd/setup.sh

python -m object_detection.eval \
  --logtostderr \
  --pipeline_config_path=/tensorflow/data/ssd_mobilenet_v1_sushi.floyd.config \
  --checkpoint_dir=/data/train \
  --eval_dir=/data/eval
