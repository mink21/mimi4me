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

feature = []
label = []

def parser():
    global pair
    X, sample_rate = librosa.load(path, res_type='kaiser_fast') 
    # We extract mfcc feature from data
    return np.mean(librosa.feature.melspectrogram(y=X, sr=sample_rate).T,axis=0).reshape((1,16,8,1))     

response = ''

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
        data = parser()
        #Y = data[:, 1]
        #Y = to_categorical(Y)
        prediction = np.argmax(model.predict(data))

        response = f'{causes[prediction]}'
        return " "
    else:
        return jsonify({'cause' : response})

if __name__ == '__main__':
    app.run()