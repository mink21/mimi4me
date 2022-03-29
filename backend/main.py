from flask import Flask, jsonify, json, request
import os;
import librosa
import librosa.display
import numpy as np
from tensorflow import keras

model = keras.models.load_model('C:\\Users\\khale\\Documents\\GitHub\\mimi4me\\backend\\')

path = 'C:\\Users\\khale\\Desktop\\test\\save.mp4'
#from tensorflow import keras
feature = 0
#model = keras.models.load_model('saved_model')

def parser(row):
    global feature
    X, sample_rate = librosa.load(path, res_type='kaiser_fast') 
    # We extract mfcc feature from data
    feature = np.mean(librosa.feature.melspectrogram(y=X, sr=sample_rate).T,axis=0)        
    label.append(df["classID"][i])
    return [feature, label]

response = ''

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def respond():
    global response
    if(request.method == 'POST'):
        print(request.files.keys())
        print(request.form.keys())
        f = request.files.get('audio')
        f.save(path)
        #request_data = json.loads(request_data.decode)
        #audio = request_data['audio']
        #audio = request.form['audio']
        
        response = f'Its working!!!!'
        return " "
    else:
        return jsonify({'cause' : response})

if __name__ == '__main__':
    app.run()