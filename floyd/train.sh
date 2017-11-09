#!/bin/sh

python -m object_detection.train \
  --logtostderr \
  --pipeline_config_path=/data/ssd_mobilenet_v1_sushi.floyd.config \
  --train_dir=/output/train
