from flask import Flask, jsonify, json, request
import pickle

path = 'C:\\Users\\khale\\Desktop\\test\\save.mp4'
#from tensorflow import keras

#model = keras.models.load_model('saved_model')

response = ''

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def respond():
    global response
    if(request.method == 'POST'):
        f = request.form.get('file')
        with open(path, 'wb') as save:
            pickle.dump(f, save)
        #request_data = json.loads(request_data.decode)
        #audio = request_data['audio']
        #audio = request.form['audio']
        
        response = f'Its working!!!!'
        return " "
    else:
        return jsonify({'cause' : response})

if __name__ == '__main__':
    app.run()