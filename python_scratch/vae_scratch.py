# Environment setup
import glob

BASE_DIR = "gs://download.magenta.tensorflow.org/models/music_vae/colab2"

import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)


print('Importing libraries and defining some helper functions...')
import magenta.music as mm
from magenta.models.music_vae import configs
from magenta.models.music_vae.trained_model import TrainedModel
import numpy as np
import os
import tensorflow.compat.v1 as tf

tf.disable_v2_behavior()
print('Environment setup done')

print('loading vectors')
vecs = [np.random.randn(512) for _ in range(512)]

print('loading model')
mel_2bar_config = configs.CONFIG_MAP['cat-mel_2bar_big']
mel_2bar = TrainedModel(mel_2bar_config, batch_size=4, checkpoint_dir_or_path=BASE_DIR + '/checkpoints/mel_2bar_big.ckpt')

print('doing forward pass')
temperature=1.0
mel_2_samples = mel_2bar.decode(vecs, length=16, temperature=temperature)

print(mel_2_samples)

print('DONE')
