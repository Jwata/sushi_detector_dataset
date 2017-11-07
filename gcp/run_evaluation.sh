#!/bin/sh

gcloud ml-engine jobs submit training sushi_object_detection_eval_`date +%s` \
    --job-dir=gs://${GCS_BUCKET}/train \
    --packages dist/object_detection-0.1.tar.gz,dist/slim-0.1.tar.gz \
    --module-name object_detection.eval \
    --region us-central1 \
    --scale-tier BASIC_GPU \
    -- \
    --checkpoint_dir=gs://${GCS_BUCKET}/train \
    --eval_dir=gs://${GCS_BUCKET}/eval \
    --pipeline_config_path=gs://${GCS_BUCKET}/data/ssd_mobilenet_v1_sushi.cloud.config
