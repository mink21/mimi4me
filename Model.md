# Mimi4me model
## Input: 

Single array of size [   1  44100]. Contains time series of audio clip in question. Model was trained on 4 second clips with sample rate of 11025 so suggested to be used on similar input

## Output: 

Single array of size [   1   10]. Contains the chances of each cause. Mapped as follows:


| Index | Cause |
| --- | --- |
| 0 | air_conditioner |
| 1 | car_horn |
| 2 | children_playing |
| 3 | dog_bark |
| 4 | drilling |
| 5 | engine_idling |
| 6 | gun_shot |
| 7 | jackhammer |
| 8 | siren |
| 9 | street_music |

## Model layers:

1-	Custom layer to convert time series to mel spectrogram using tf.stft and matrix manipulation. Also reshapes output to [     1    87   8     1] from [   1   44100]

2-	2D convolution. 64 output filters. (3,3) kernel size. Same padding. Tanh activation. (input shape is [   87   8     1]

3-	MaxPool2D. (2,2) pool size

4-	2D convolution. 128 output filters. (3,3) kernel size. Same padding. Tanh activation

5-	MaxPool2D. (2,2) pool size

6-	Dropout (0.1)

7-	Flatten

8-	Dense(1024, tanh)

9-	Dense(10, softmax)
