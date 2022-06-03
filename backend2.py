import pandas as pd
import numpy as np
import keras
import tensorflow as tf
import tensorflow_io as tfio
import math

pd.plotting.register_matplotlib_converters()
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
from sklearn.model_selection import GridSearchCV

from sklearn.preprocessing import MinMaxScaler
# Libraries for Classification and building Models

from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, Flatten, Dense, MaxPool2D, Dropout
from tensorflow.keras.utils import to_categorical 

from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
# Project Specific Libraries

import os
import librosa
import librosa.display
import glob

NUM_SAMPLES = 8732
#8732
class Spectrograminator(keras.layers.Layer):
    def __init__(self, output_dim):
        self.output_dim = output_dim
        super(Spectrograminator,self).__init__()
    def call(self, input_shape, sample_rate=22050):
        input = input_shape.numpy()
        res = np.empty((len(input),128))
        for i in range(len(input)):
            #print(signal[45000])
            mels = np.mean(librosa.feature.melspectrogram(y=input[i], sr = sample_rate).T, axis=0)
            res[i] = mels
        #print(res.shape)
        res = res.reshape((len(input), 16, 8, 1))
        return res
    def build(self, input_shape):
        self.add_weight(name = 'idk', 
        shape = (input_shape[0], self.output_dim), 
        initializer = 'normal', trainable = False)
        super(Spectrograminator, self).build(input_shape)

df = pd.read_csv("UrbanSound8K.csv")

df.head()

feature = []
label = []
#8732
def parser(row):
    for i in range(NUM_SAMPLES):
        file_name = 'fold' + str(df["fold"][i]) + '/' + df["slice_file_name"][i]
        # Here kaiser_fast is a technique used for faster extraction
        X, sample_rate = librosa.load(file_name, res_type='kaiser_fast')
        #X = np.resize(X, (89009,))
        X = np.pad(X, (math.floor((89009-len(X))/2),math.ceil((89009-len(X))/2)))
        feature.append(X)
        label.append(df["classID"][i])
    return [feature, label]

temp = parser(df)
temp = np.array(temp)
data = temp.transpose()
X_ = data[:, 0]
Y = data[:, 1]
print(X_.shape, Y.shape)
X = np.empty([NUM_SAMPLES, 89009])

for i in range(NUM_SAMPLES):
    X[i] = (X_[i])

Y = to_categorical(Y)
print(X.shape)
print(Y.shape)

X_train, X_test, Y_train, Y_test = train_test_split(X, Y, random_state = 1)
# X_train = X_train.reshape(6549, 16, 8, 1)
# X_test = X_test.reshape(2183, 16, 8, 1)
print(X_train.shape)
input_dim = (16, 8, 1)

model = Sequential()
layer = Spectrograminator(3)
model.add(layer)
model.add(Conv2D(64, (3, 3), padding = "same", activation = "tanh", input_shape = input_dim))
model.add(MaxPool2D(pool_size=(2, 2)))
model.add(Conv2D(128, (3, 3), padding = "same", activation = "tanh"))
model.add(MaxPool2D(pool_size=(2, 2)))
model.add(Dropout(0.1))
model.add(Flatten())
model.add(Dense(1024, activation = "tanh"))
model.add(Dense(10, activation = "softmax"))

model.compile(run_eagerly = True, optimizer = 'adam', loss = 'categorical_crossentropy', metrics = ['accuracy'])
model.fit(X_train, Y_train, epochs = 90, batch_size = 50, validation_data = (X_test, Y_test))
model.summary()

model.save("C:\\Users\\khale\\Desktop\\timeSeriesModelPad")

predictions = model.predict(X_test)
score = model.evaluate(X_test, Y_test)
print(score)

preds = np.argmax(predictions, axis = 1)
result = pd.DataFrame(preds)
result.to_csv("UrbanSound8kResults.csv")