FROM jwata/tensorflow-object-detection

ENV data_dir=${TF_MODELS_RESEARCH_DIR}/data

COPY data ${data_dir}

ENV model=ssd_mobilenet_v1_sushi
ENV pretrained_model=ssd_mobilenet_v1_coco_11_06_2017

RUN sed -i -e "s|PATH_TO_BE_CONFIGURED|$data_dir|g" data/${model}.config

WORKDIR /tmp

RUN curl -OL http://download.tensorflow.org/models/object_detection/${pretrained_model}.tar.gz && \
      tar -xzf ${pretrained_model}.tar.gz && \
      cp ${pretrained_model}/* ${data_dir}

RUN rm -rf ${pretrained_model}.tar.gz ${pretrained_model}

WORKDIR ${TF_MODELS_RESEARCH_DIR}

COPY docker_command.sh .

EXPOSE 6006

CMD ["./docker_command.sh"]
