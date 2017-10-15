#!/bin/bash

nohup python object_detection/train.py \
    --logtostderr \
    --pipeline_config_path=${data_dir}/ssd_mobilenet_v1_sushi.config \
    --train_dir=${data_dir}/train &

nohup python object_detection/eval.py \
    --logtostderr \
    --pipeline_config_path=${data_dir}/ssd_mobilenet_v1_sushi.config \
    --checkpoint_dir=${data_dir}/train \
    --eval_dir=${data_dir}/eval &

tensorboard --logdir=.
