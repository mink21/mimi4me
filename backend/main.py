import random
#from tensorflow import kers

from paho.mqtt import client as mqtt_client
import matplotlib.pyplot as plt

broker = 'broker.emqx.io'
port = 1883
topic = "/noise"
client_id = f'python-mqtt-{random.randint(0, 1000)}'


def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT Broker!")
    else:
        print("Failed to connect, return code %d\n", rc)


def connect_mqtt() -> mqtt_client:
    client = mqtt_client.Client(client_id)
    # client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client


def on_message(client, userdata, msg):
    noise_levels = list(map(float, msg.payload.decode()[1:-1].strip().split(',')))
    for value in noise_levels:
        print(value)
    plotData(noise_levels)
    print(f"Received `{noise_levels}` from `{msg.topic}` topic")


def subscribe(client: mqtt_client):
    client.subscribe(topic)
    client.on_message = on_message


def plotData(data):
    plt.plot(data)
    plt.ylabel('db values')
    plt.show()


def run():
    client = connect_mqtt()
    subscribe(client)
    client.loop_forever()


if __name__ == '__main__':
    run()