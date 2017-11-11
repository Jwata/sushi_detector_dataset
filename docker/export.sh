#!/bin/sh

ln -s /tensorflow/data /data

cd /tensorflow

./floyd/setup.sh

python -m object_detection.export_inference_graph \
    --input_type=image_tensor \
    --pipeline_config_path=/tensorflow/data/ssd_mobilenet_v1_sushi.floyd.config \
    --trained_checkpoint_prefix=/data/train \
    --output_directory=output_inference_graph.pb

