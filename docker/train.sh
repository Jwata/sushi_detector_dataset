#!/bin/sh

ln -s /tensorflow/data /data

cd /tensorflow

./floyd/setup.sh

python -m object_detection.train \
  --logtostderr \
  --pipeline_config_path=/tensorflow/data/ssd_mobilenet_v1_sushi.floyd.config \
  --train_dir=/data/train
