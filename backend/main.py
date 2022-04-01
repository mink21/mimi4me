from flask import Flask, jsonify, request
import os
import librosa
import librosa.display
import numpy as np
from tensorflow import keras

import warnings
warnings.filterwarnings('ignore')

MODEL = keras.models.load_model("./")
PATH = 'save.mp4'

CAUSES = ['AC', 'Car Honks', 'Kids Playing', 'Dog Bark', 'Drilling',
          'Engine Idling', 'Gun Shot', 'Jackhammer', 'Siren', 'Street Music']
DECIBELS = 0
CAUSE = ""


def process():

    global DECIBELS, CAUSES, CAUSE, PATH

    x, sample_rate = librosa.load(PATH, res_type='kaiser_fast')
    second = []
    for s in range(0, len(x), sample_rate):
        second.append(np.abs(x[s:s+sample_rate]).mean())
    noise_max = int(max(librosa.amplitude_to_db(x)) + 100)
    noise_min = int(min(librosa.amplitude_to_db(x)) + 100)
    noise_mean = int(np.mean(librosa.amplitude_to_db(x)) + 100)
    data = np.mean(librosa.feature.melspectrogram(
        y=x, sr=sample_rate).T, axis=0
    ).reshape((1, 16, 8, 1))

    if noise_min == 0 or noise_mean*2 < noise_max:
        noise = noise_max - noise_mean
    else:
        noise = noise_mean
    if noise_max > 80:
        noise = noise_max

    DECIBELS = int(noise)

    prediction = np.argmax(MODEL.predict(data))
    CAUSE = f'{CAUSES[prediction]}'


app = Flask(__name__)


@app.route('/', methods=['GET', 'POST'])
def respond():

    global DECIBELS, CAUSES, CAUSE, PATH

    if(request.method == 'POST'):
        f = request.files.get('audio')
        f.save(PATH)
        process()
        os.remove(PATH)
        return ""
    else:
        return jsonify({'cause': CAUSE, "decibels": DECIBELS})


if __name__ == '__main__':
    app.run()
