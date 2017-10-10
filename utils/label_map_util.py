import tensorflow as tf
from google.protobuf import text_format
from protos import string_int_label_map_pb2

def load_labelmap(path):
    with tf.gfile.GFile(path, 'r') as fid:
      label_map_string = fid.read()
      label_map = string_int_label_map_pb2.StringIntLabelMap()
      try:
        text_format.Merge(label_map_string, label_map)
      except text_format.ParseError:
        label_map.ParseFromString(label_map_string)
    return label_map


def get_label_map_dict(label_map_path):
  label_map = load_labelmap(label_map_path)
  label_map_dict = {}
  for item in label_map.item:
    label_map_dict[item.name] = item.id
  return label_map_dict

