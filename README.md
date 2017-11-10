# Data preparation
## Create TFRecord
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

## Download pretrained model
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

# Run on Floydhub
> Platform-as-a-Service for training and deploying your DL models in the cloud
> [FloydHub - Deep Learning Platform - Cloud GPU](https://www.floydhub.com/)

## Setup
1. Create your floydhub account
2. [Install floyd cli](https://docs.floydhub.com/guides/basics/install/)
3. Create a project

  ```
  floyd init your_project_name
  ```

4. Create dataset 

  ```
  cd data
  floyd data init your_dataset_name
  floyd data upload
  ```

## Training
### Run

```
# CPU
floyd run --env tensorflow-1.3 \                           
  --data junji/datasets/sushi_detector/1:data \
  "bash ./floyd/setup.sh && sh ./floyd/train.sh"

=> junji/projects/sushi_detector/1
```

```
# GPU
floyd run --gpu --env tensorflow-1.3 \
...
```


### Stop 

```
floyd stop junji/projects/sushi_detector/1
```

### Run from the output of a past job

```
floyd run --env tensorflow-1.3 \
  --data junji/datasets/sushi_detector/1:data \
  --data junji/projects/sushi_detector/1/output:output_past \
  "bash ./floyd/setup.sh && cp -R /output_past/* /output && sh ./floyd/train.sh"

=> junji/projects/sushi_detector/2
```

## Evaluation
### Run

```
floyd run --env tensorflow-1.3 \
  --data junji/datasets/sushi_detector/1:data \
  --data junji/projects/sushi_detector/1/output:output_past \
  "bash ./floyd/setup.sh && cp -R /output_past/* /output && sh ./floyd/eval.sh"
```


# Run on Google Cloud
2017/11/07  
The following steps don't work because Google Cloud ML Engine doesn't support the latest tensorflow version 1.4. Check [this runtime version list](https://cloud.google.com/ml-engine/docs/runtime-version-list).

## Setup
Complete the following step checking the official documents
>
1. Create a GCP project
2. Install the Google Cloud SDK
3. Enable the ML Engine APIs
4. Set up a Google Cloud Storage (GCS) bucket

- [Running on Google Cloud Platform](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/running_on_cloud.md)
- [Quick Start: Distributed Training on the Oxford-IIIT Pets Dataset on Google Cloud](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/running_pets.md)

## Upload files
```
GCS_BUCKET=your_bucket_name ./gcp/upload_files_to_gcs_bucket.sh
```

We need to package the Tensorflow Object Detection code to run it on Google Cloud, but the custom docker that we are using already has [the packaged code](https://github.com/Jwata/models/blob/master/Dockerfile.object_detectoin)

```
./gcp/get_tensorflow_code_from_docker.sh
```

## Training
## Evaluation
## Tensorboard
