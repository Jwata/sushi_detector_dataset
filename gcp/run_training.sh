#!/bin/sh

gcloud ml-engine jobs submit training sushi_object_detection_`date +%s` \
    --job-dir=gs://${GCS_BUCKET}/train \
    --packages dist/object_detection-0.1.tar.gz,slim/dist/slim-0.1.tar.gz \
    --module-name object_detection.train \
    --region us-central1 \
    --config gcp/cloud.yml \
    -- \
    --train_dir=gs://${GCS_BUCKET}/train \
    --pipeline_config_path=gs://${GCS_BUCKET}/data/ssd_mobilenet_v1_sushi.cloud.config
