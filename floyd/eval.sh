#!/bin/sh

python -m object_detection.eval \
  --logtostderr \
  --pipeline_config_path=/data/ssd_mobilenet_v1_sushi.floyd.config \
  --checkpoint_dir=/output/train \
  --eval_dir=/output/eval
