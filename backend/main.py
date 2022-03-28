from flask import Flask, jsonify, json, request
#from tensorflow import keras

#model = keras.models.load_model('saved_model')

response = ''

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def respond():
    global response
    if(request.method == 'POST'):
        request_data = request.data
        print(request_data)
        print(request.form.get('name'))
        print(request.form.get('audio'))
        #request_data = json.loads(request_data.decode)
        #audio = request_data['audio']
        #audio = request.form['audio']
        
        response = f'Its working!!!!'
        return " "
    else:
        return jsonify({'cause' : response})

if __name__ == '__main__':
    app.run()