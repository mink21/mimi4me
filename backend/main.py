from flask import Flask, jsonify, json, request
import os;
import librosa
import librosa.display
import numpy as np
from tensorflow import keras
from tensorflow.keras.utils import to_categorical 

model = keras.models.load_model('C:\\Users\\khale\\Documents\\GitHub\\mimi4me\\backend\\')
path = 'save.mp4'

causes = ['AC', 'Carn Horn', 'Kids Playing', 'Dog Bark', 'Drilling', 'Engine Idling', 'Gun Shot', 'Jackhammer', 'Siren', 'Street Music']
decibels = ""
response = ""

def process():
    global decibels
    X, sample_rate = librosa.load(path, res_type='kaiser_fast')
    decibels = f'{np.average(librosa.amplitude_to_db(X))}'
    return np.mean(librosa.feature.melspectrogram(y=X, sr=sample_rate).T,axis=0).reshape((1,16,8,1))     



app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def respond():
    global response
    global causes
    if(request.method == 'POST'):
        #getting and saving file
        f = request.files.get('audio')
        f.save(path)
        #processing file
        data = process()
        prediction = np.argmax(model.predict(data))
        response = f'{causes[prediction]}'
        os.remove(path)
        return " "
    else:
        return jsonify({'cause' : response, "decibels" : decibels})

if __name__ == '__main__':
    app.run()