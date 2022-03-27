from flask import Flask, jsonify, request
#from tensorflow import keras

#model = keras.models.load_model('saved_model')

response = ''

app = Flask(__name__)

@app.route('/', methods=['Get', 'POST'])
def respond():
    global response
    if(request.method == 'POST'):
        request_data = request.data
        request_data = json.loads(request_data.decode('utf-8'))
        audio = request_data['audio']
        response = f'Its working!!!!'
        return " "
    else:
        return jsonify({'cause' : response})

if __name__ == '__main__':
    app.run()