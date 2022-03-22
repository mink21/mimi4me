from flask import Flask

app = Flask(__name__)

@app.route('/', methods=['POST'])
def root():
    return "HELLO FLASK"

if __name__ == '__main__':
    app.run()