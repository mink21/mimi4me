# mimi4me
Solution Challenge 2022

# What is this?


# How to run

## Backend

### Requirements
- python 3 installed
- ngrok installed - Download from https://ngrok.com/download

### How to run(locally)
1. Go to the backend folder
``` 
cd backend
```
2. Install required libraries
```
pip install -r requirements.txt
```
3. Run the flask server
```
python main.py
```
4. Run ngrok server
```
ngrok http http://127.0.0.1:5000/
```
5. Copy https tunnel made by ngrok server 
```
Forwarding                    https://269f-2405-6581-9960-6500-3dcc-3085-257e-5d24.ngrok.io -> http://127.0.0.1:5000

In above case,
https://269f-2405-6581-9960-6500-3dcc-3085-257e-5d24.ngrok.io
```
6. Proceed to the Frontend Execution

## Frontend

### Requirements
- java version 11 installed
- darts & flutter installed (check the working version below)
- backend flask server must be working
- have finished tunneling to ngrok server

### Works in
- On local only
- Dart SDK version: 
    - 2.16.1 (stable)
- Flutter
    - 2.10.2

### How to run
1. Go to the mimi4me directory
``` 
cd mimi4me
```
2. Install required packages
```
dart pub get
```
3. Enter environmental variables [.env](/mimi4me/.env). (The apiUrl below is obtained to tunnel using ngrok server)

```
apiUrl=https://sample.ngrok.io -> local server
apiUrl=https://murmuring-hamlet-18265.herokuapp.com/ -> deployed server
```
4. Run the app on your device
```
flutter run
```
5. Click the record button and wait for few seconds
