import math
from pathlib import Path

import keras
import librosa
import librosa.display
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

import tensorflow as tf
from tensorflow.keras.layers import Conv2D, Dense, Dropout, Flatten, MaxPool2D
from tensorflow.keras.models import Sequential
from tensorflow.keras.utils import to_categorical

pd.plotting.register_matplotlib_converters()

SAMPLING_RATE = 11025 # this is used everywhere
AUDIO_LENGTH = (4 * SAMPLING_RATE)
N1 = 87 # this was 16 before but the new numbers of Spectrograminator makes it 87. Do not know or want to know why
N2 = 8 # This was 8 already

# def fn(timeSeries):
#     # return tf.convert_to_tensor(shape(meanT(mel(timeSeries))))
#     useful = timeSeries.numpy()
#     # print(useful[22000])
#     res = tf.convert_to_tensor(
#         np.mean(librosa.feature.melspectrogram(y=useful, sr=SAMPLING_RATE).T, axis=0)
#     )
#     return res
#
#
# def fn_func(timeSeries):
#     return tf.py_function(fn, [timeSeries], tf.float32)

# 8732
class Spectrograminator(keras.layers.Layer):
    def __init__(
        self,
        frame_length=1024,
        frame_step=512,
        fft_length=None,
        sampling_rate=SAMPLING_RATE,
        num_mel_channels=8,
        freq_min=125,
        freq_max=3800,
        **kwargs,
    ):
        super().__init__(**kwargs)
        # self.output_dim = output_dim
        self.frame_length = frame_length
        self.frame_step = frame_step
        self.fft_length = fft_length
        self.sampling_rate = sampling_rate
        self.num_mel_channels = num_mel_channels
        self.freq_min = freq_min
        self.freq_max = freq_max
        self.mel_filterbank = tf.signal.linear_to_mel_weight_matrix(
            num_mel_bins=self.num_mel_channels,
            num_spectrogram_bins=self.frame_length // 2 + 1,
            sample_rate=self.sampling_rate,
            lower_edge_hertz=self.freq_min,
            upper_edge_hertz=self.freq_max,
        )

    def call(self, input_shape):
        # print(input_shape.shape)
        # Taking the Short Time Fourier Transform. Ensure that the audio is padded.
        # In the paper, the STFT output is padded using the 'REFLECT' strategy.
        stft = tf.signal.stft(
            input_shape,
            # tf.squeeze(input_shape, -1),
            self.frame_length,
            self.frame_step,
            self.fft_length,
            pad_end=True,
        )

        # Taking the magnitude of the STFT output
        magnitude = tf.abs(stft)

        # Multiplying the Mel-filterbank with the magnitude and scaling it using the db scale
        res = tf.matmul(tf.square(magnitude), self.mel_filterbank)
        # res = tfio.audio.dbscale(mel, top_db=80)
        res = tf.reshape(res, (tf.shape(res)[0], N1, N2, 1))
        return res

    # def build(self, input_shape):
    #     self.add_weight(name = 'idk', trainable = False)
    #     super(Spectrograminator, self).build(input_shape)


def main():
    df = pd.read_csv("UrbanSound8K.csv")
    n_samples = 8732

    df.head()

    feature = []
    label = []
    # 8732
    def parser(df):
        for i in range(n_samples):
            file_name = "fold" + str(df["fold"][i]) + "/" + df["slice_file_name"][i]
            if not (Path() / file_name).exists():
                continue
            X, sample_rate = librosa.load(file_name, res_type="kaiser_fast", sr=SAMPLING_RATE)
            # X = np.resize(X, (AUDIO_LENGTH,))
            if len(X) > AUDIO_LENGTH:
                X = X[0:AUDIO_LENGTH]
            X = np.pad(
                X, (math.floor((AUDIO_LENGTH - len(X)) / 2), math.ceil((AUDIO_LENGTH - len(X)) / 2))
            )
            if len(X) != AUDIO_LENGTH:
                print("Wtf")
            feature.append(X)
            label.append(df["classID"][i])
        return [feature, label]


    temp = parser(df)
    n_samples = len(temp[0])
    temp = np.array(temp)
    data = temp.transpose()
    X_ = data[:, 0]
    Y = data[:, 1]
    print(X_.shape, Y.shape)
    X = np.empty([n_samples, AUDIO_LENGTH])

    for i in range(n_samples):
        X[i] = X_[i]

    Y = to_categorical(Y)
    print(X.shape)
    print(Y.shape)

    X_train, X_test, Y_train, Y_test = train_test_split(X, Y, random_state=1)
    # X_train = X_train.reshape(6549, N1, N2, 1)
    # X_test = X_test.reshape(2183, N1, N2, 1)
    print(X_train.shape)
    input_dim = (N1, N2, 1)

    model = Sequential()
    layer = Spectrograminator()
    model.add(layer)
    model.add(Conv2D(64, (3, 3), padding="same", activation="tanh", input_shape=input_dim))
    model.add(MaxPool2D(pool_size=(2, 2)))
    model.add(Conv2D(128, (3, 3), padding="same", activation="tanh"))
    model.add(MaxPool2D(pool_size=(2, 2)))
    model.add(Dropout(0.1))
    model.add(Flatten())
    model.add(Dense(1024, activation="tanh"))
    model.add(Dense(10, activation="softmax"))

    model.compile(
        run_eagerly=True,
        optimizer="adam",
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )
    model.fit(X_train, Y_train, epochs=90, batch_size=50, validation_data=(X_test, Y_test))
    model.summary()

    tf.keras.models.save_model(model, "timeSeriesModelPad")

    predictions = model.predict(X_test)
    score = model.evaluate(X_test, Y_test)
    print(score)

    preds = np.argmax(predictions, axis=1)
    result = pd.DataFrame(preds)
    result.to_csv("UrbanSound8kResults.csv")

if __name__ == "__main__":
    main()