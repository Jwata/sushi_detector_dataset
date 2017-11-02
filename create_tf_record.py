"""
Usage:
    python create_tf_record.py --annotations_dir=`pwd`/annotations --images_dir=`pwd`/images --output_dir=`pwd`/data/ --label_map_path=`pwd`/data/sushi_label_map.pbtxt
"""


import os
import random
import logging
from lxml import etree
import tensorflow as tf

from utils import dataset_util, label_map_util

flags = tf.app.flags
flags.DEFINE_string('annotations_dir', '', 'Path to the anottations directory')
flags.DEFINE_string('images_dir', '', 'Path to the images directory')
flags.DEFINE_string('output_dir', '', 'Path to the output directory.')
flags.DEFINE_string('label_map_path', '', 'Path to label map proto')
FLAGS = flags.FLAGS

def dict_to_tf_example(example_dict, label_map_dict, images_dir):
    width = int(example_dict['size']['width'])
    height = int(example_dict['size']['height'])

    filename = example_dict['filename']
    image_path = os.path.join(images_dir, filename)

    with tf.gfile.GFile(image_path, 'rb') as fid:
        encoded_image_data = fid.read()
    image_format = b'jpeg'

    xmins = []
    xmaxs = []
    ymins = [] 
    ymaxs = []
    classes_text = []
    classes = []
    for obj in example_dict['object']:
        xmins.append(float(obj['bndbox']['xmin']) / width)
        ymins.append(float(obj['bndbox']['ymin']) / height)
        xmaxs.append(float(obj['bndbox']['xmax']) / width)
        ymaxs.append(float(obj['bndbox']['ymax']) / height)
        class_name = obj['name']
        classes_text.append(class_name.encode('utf8'))
        classes.append(label_map_dict[class_name])

    tf_example = tf.train.Example(features=tf.train.Features(feature={
        'image/height': dataset_util.int64_feature(height),
        'image/width': dataset_util.int64_feature(width),
        'image/filename': dataset_util.bytes_feature(filename.encode('utf8')),
        'image/source_id': dataset_util.bytes_feature(filename.encode('utf8')),
        'image/encoded': dataset_util.bytes_feature(encoded_image_data),
        'image/format': dataset_util.bytes_feature(image_format),
        'image/object/bbox/xmin': dataset_util.float_list_feature(xmins),
        'image/object/bbox/xmax': dataset_util.float_list_feature(xmaxs),
        'image/object/bbox/ymin': dataset_util.float_list_feature(ymins),
        'image/object/bbox/ymax': dataset_util.float_list_feature(ymaxs),
        'image/object/class/text': dataset_util.bytes_list_feature(classes_text),
        'image/object/class/label': dataset_util.int64_list_feature(classes),
    }))
    return tf_example

def create_tf_record(output_path,
                     annotations_dir,
                     images_dir,
                     label_map_dict,
                     examples):
    writer = tf.python_io.TFRecordWriter(output_path)

    for idx, example in enumerate(examples):
        xml_path = os.path.join(annotations_dir, example + '.xml')

        if not os.path.exists(xml_path):
            logging.warning('Could not find %s, ignoring example.', xml_path)
            continue

        with tf.gfile.GFile(xml_path, 'r') as fid:
            xml_str = fid.read()
        xml = etree.fromstring(xml_str)
        example_dict = dataset_util.recursive_parse_xml_to_dict(xml)['annotation']

        tf_example = dict_to_tf_example(example_dict, label_map_dict, images_dir)
        writer.write(tf_example.SerializeToString())

    writer.close()

def main(_):
    annotations_dir = FLAGS.annotations_dir
    images_dir = FLAGS.images_dir
    train_output_path = os.path.join(FLAGS.output_dir, 'sushi_train.record')
    val_output_path = os.path.join(FLAGS.output_dir, 'sushi_val.record')
    label_map_dict = label_map_util.get_label_map_dict(FLAGS.label_map_path)
    examples_path = os.path.join(FLAGS.annotations_dir, 'trainval.txt')

    examples = dataset_util.read_examples_list(examples_path)
    random.seed(42)
    random.shuffle(examples)
    num_examples = len(examples)

    num_train = int(0.7 * num_examples)
    train_examples = examples[:num_train]
    val_examples = examples[num_train:]

    create_tf_record(train_output_path, annotations_dir, images_dir, label_map_dict, train_examples)
    create_tf_record(val_output_path, annotations_dir, images_dir, label_map_dict, val_examples)

if __name__ == '__main__':
    tf.app.run();
