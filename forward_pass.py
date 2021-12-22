# Environment setup
import glob

BASE_DIR = "gs://download.magenta.tensorflow.org/models/music_vae/colab2"

print('Importing libraries and defining some helper functions...')
import json 
import magenta.music as mm
from magenta.models.music_vae import configs
from magenta.models.music_vae.trained_model import TrainedModel
import numpy as np
import os
import tensorflow.compat.v1 as tf
from google.protobuf.json_format import MessageToJson


tf.disable_v2_behavior()
print('Environment setup done...')

print('loading cellular automaton...')
reader = np.loadtxt(open("temp.csv", "rb"), delimiter=",")
vecs=[]
for row in reader: 
    vecs.append(row)

print('loading model...')
mel_2bar_config = configs.CONFIG_MAP['cat-mel_2bar_big']
mel_2bar = TrainedModel(mel_2bar_config, batch_size=4, checkpoint_dir_or_path=BASE_DIR + '/checkpoints/mel_2bar_big.ckpt')

print('doing forward pass...')
temperature=1.0
mel_2_samples = mel_2bar.decode(vecs, length=32, temperature=temperature)

print("saving midi...")

try:
    os.mkdir("midi")
except: 
    print("midi dir already exists")

for i, sample in enumerate(mel_2_samples): 
    mm.sequence_proto_to_midi_file(sample, "midi/{}.mid".format(i))

print('DONE')
