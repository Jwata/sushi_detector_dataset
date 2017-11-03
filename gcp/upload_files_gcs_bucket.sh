#!/bin/sh

sed -i -e "s|GCS_BUCKET|${GCS_BUCKET}|g" data/*.cloud.config

upload_files=(sushi_train.record sushi_val.record sushi_label_map.pbtxt model.ckpt.* *.cloud.config)

for file in ${upload_files[@]};do
  gsutil cp data/${file} gs://${GCS_BUCKET}/data/
done

gsutil ls -l 'gs://${GCS_BUCKET}/*'
