# Create python environment
```
conda env create -f environment.yml
source activate sushi_detector
```

# Create TFRecord
When you add images and annotations, you need to create TFRecord again.

```
docker run -it \
  --volume `pwd`/data:/data \
  --volume `pwd`/create_tf_record.py:/tensorflow-models/research/create_tf_record.py \
  jwata/tensorflow-object-detection \
  python create_tf_record.py \
    --annotations_dir=/data/annotations \
    --images_dir=/data/images \
    --output_dir=/data/ \
    --label_map_path=/data/sushi_label_map.pbtxt
```
or
```
./create_tf_record.sh
```

# Download pretrained model
```
pushd data
pretrained_model=ssd_mobilenet_v1_coco_11_06_2017
curl -OL http://download.tensorflow.org/models/object_detection/${ssd_mobilenet_v1_coco_11_06_2017}.tar.gz
tar -xzf ${pretrained_model}.tar.gz
rm -rf ${pretrained_model}.tar.gz ${pretrained_model}
popd
```

# Run in docker container
## Training
```
docker run -d -v `pwd`/data:/data --name sushi_detector_train jwata/tensorflow-object-detection \
  python object_detection/train.py \
  --logtostderr \
  --pipeline_config_path=/data/ssd_mobilenet_v1_sushi.docker.config \
  --train_dir=/data/train
```

## Evaluation
```
docker run -d -v `pwd`/data:/data --name sushi_detector_eval jwata/tensorflow-object-detection \
  python object_detection/eval.py \
  --logtostderr \
  --pipeline_config_path=/data/ssd_mobilenet_v1_sushi.docker.config \
  --checkpoint_dir=/data/train \
  --eval_dir=/data/eval
```

## Tensorboard
```
docker run -d -v `pwd`/data:/data -p 6006:6006 --name tensorboard jwata/tensorflow-object-detection \
  tensorboard --logdir=/data

open http://localhost:6006
```

# Run on Google Cloud
Complete the following step checking the official documents
>
1. Create a GCP project
2. Install the Google Cloud SDK
3. Enable the ML Engine APIs
4. Set up a Google Cloud Storage (GCS) bucket


- [Running on Google Cloud Platform](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/running_on_cloud.md)
- [Quick Start: Distributed Training on the Oxford-IIIT Pets Dataset on Google Cloud](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/running_pets.md)

