# Data preparation
## Create TFRecord
When you add images and annotations, you need to create TFRecord again.

```
docker run -it \
  --volume `pwd`:/tensorflow \
  floydhub/tensorflow:1.4.0-py3_aws.14 \
  /tensorflow/docker/create_tf_record.sh
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
docker run -it \
  --volume `pwd`:/tensorflow \
  floydhub/tensorflow:1.4.0-py3_aws.14 \
  /tensorflow/docker/train.sh
```

## Evaluation
```
docker run -it \
  --volume `pwd`:/tensorflow \
  floydhub/tensorflow:1.4.0-py3_aws.14 \
  /tensorflow/docker/eval.sh
```

## Tensorboard
```
tensorboard --logdir=data
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
### Run from a dataset

```
# CPU
floyd run --env tensorflow-1.4 \
  --data junji/datasets/sushi_detector/1:data \
  "bash ./floyd/setup.sh && cp -R /data/* /output && sh ./floyd/train.sh"

=> junji/projects/sushi_detector/1
```

```
# GPU
floyd run --gpu --env tensorflow-1.4 \
...
```


### Stop 

```
floyd stop junji/projects/sushi_detector/1
```

### Run from the output of a past job

```
floyd run --env tensorflow-1.4 \
  --data junji/projects/sushi_detector/{job_id}/output:data \
  "bash ./floyd/setup.sh && cp -R /data/* /output && sh ./floyd/train.sh"

=> junji/projects/sushi_detector/2
```

## Evaluation

```
floyd run --env tensorflow-1.4 \
  --data junji/projects/sushi_detector/{job_id}/output:data \
  "bash ./floyd/setup.sh && cp -R /data/* /output && sh ./floyd/eval.sh"

```

## Tensorboard

```
floyd run --tensorboard \
  --data junji/projects/sushi_detector/{job_id}/output:data \
  "tensorboard --logdir=/data"
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
