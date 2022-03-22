from flask import Flask
from flask import jsonify
from flask import abort
from flask import render_template
import json


app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False
app.config['JSON_AS_ASCII'] = False
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = True
# 名刺一覧を作る

@app.route('/')
def root():
    # index.htmlはtemplatesディレクトリに置く
    return "HELLO FLASK"

if __name__ == '__main__':
    # Flaskはポート番号5000で起動
    app.run(host='127.0.0.1', port=5000, debug=True)