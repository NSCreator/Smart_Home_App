import threading
import time
from datetime import datetime,timedelta
# Telegram
import telepot
from telepot.loop import MessageLoop

# RealTime DataBase (FireBase)
import pyrebase

#Firestore DataBase
from firebase_admin import firestore
from firebase_admin import credentials
import firebase_admin
# Raspberry pi setuping.......
dicOfPinNumbers = {
    "switch 1":12,
    "switch 2":14
}
try:
    import RPi.GPIO as GPIO
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    GPIO.setup(18, GPIO.OUT)
    isRPI = True
except:
    print("GPIO pins are not working.....")
    isRPI = False
credPath = {
  "type": "service_account",
  "project_id": "smarthomeapp-71479",
  "private_key_id": "28ab485972724626b024c0e93864ec4e66c2a75b",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDRJh/lxj7EzRB6\n10ishEZRl58wSn7pXDpofprE+RWIrhXrS5qYiarYnJDDFVbZr95NDJyWFSlmDr4m\n8ZmBLSsHBV+2S6uSO+NzbFFt6A99fVIFliGDbF2/7pIc7cA60XpEJY1n2NHvpoWy\n8y1WFH51VaUyrGCVjtrHTtjL2plq0B9xiffxfiKb65wf+Ey9sy/duL9CElY7feD9\n5cchGVWVKqALnts8HyQNaBZBG70P55LBPavFwyTU+PGnSZk+tFDX6i1lV944vj4T\nLUyWqnGGvWLEDx+dYDbEC4HjPA3d5mOfeEZi68cYLGGDfjqHvRveS9F0wIyR+FLM\nFQMWLBfZAgMBAAECggEABSB4nrLN3hgiw8gcNXJmoOBlHBNvafwDSIV1+MccUoXl\n7qcjSoLxZ67q04Vl5B8uBVh+TCWHpsNMwPqiJyr6x4jHsFnJgmOqby1kD5wlKQ/V\n32IvPx/8alSIS2I+mJKC+0GqZjXH66Z614ijf10wPmMTkhrsoS3nygPyR4j7wsT8\n7Zj4+TTRR9howuAjhI1/3Zdwaumc8/FWOGVt7fErE706DKzonxMJBc9AkF05gv+o\n0pe7OWO2yyTzU0/K80LEQaoyfWQAZTi2DYOe18IhDK/LLuu0AWtwFyXyQoTjhmGh\n+17h2p0PofVJEwrollxb0H+ItuXUqNDzKbSG1ez5aQKBgQDxXmecQoXj1uMSW/xD\nst7HW63F3k4uz1nPB3PPwv02bS9vqcSPg997v3iTKqyMW+YNR2cBZakIio7Vc7Dp\n/ToLsxf+9hOIjGmdtyj0L0Sz6AF2pGjriyt75Q7tkCmPEW5YM/UG4OyQKFJjMoba\nGr2NZd4GYLycf2fR9LOeKCDKtQKBgQDd07pKIE2APNYWB7mulETDzXKhsJG9hhG3\n+JKU6H32DtWx85ZdQE+Txc39DbQhSj+JvP8//P6Xz8D2UELU2r2DnvjhInXZBhva\naFbVRqep48I8zTPMyoGdsh9+BUjT2Zcj4UvB8EhRd1B3iAZ+lIa9Q2N7LHgEXddW\nv14e+0z7FQKBgQCoglofk6naCRn6pVGXCffSgsTtEWjP8V8n1HIcKGuTZeLqOEHM\nWCrcQC6zv+U7EKWpu6HELe820VUq3Fw03994b45fJ/k3KaBKxabH44A5gc4TwHCn\nkT/IfYBQhocdJPQ+i/eS19EQS7ZJHutatbSEVQwOs9a6A5C92fLUhftuyQKBgCRB\n7zkefoxvZS7EpHz8jyDR++Kh0bCAsXS4lHzyY2RMmHE1t2YWlOs6cajjDIZEdI42\n7iGvYI2/z3JzO/k+p6tT2Kozz79hWDwiwc6qdc03BRCbGdRnZTg5XRxkELtP3Xxn\n3tIcTDXEospm2WjnLf7RfPktE5DjJcdwEBpQSQzhAoGBAJ8peCPPS2XFg3KneAo2\nHVLF/tVTKjOhUrehK1qlDLJImEYbbHGuI03RaCak3eKyYewRVRwpOjlEUheMqr7r\n0uh/5JC3E9WGN8OQgbVLqhBuVKU4P6/1ChPU7nYK3A3pency2GwIovU7gkTKjVb0\n36uuMO5AV6wTeUFXBKSzi6aY\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-o8qx4@smarthomeapp-71479.iam.gserviceaccount.com",
  "client_id": "112834860736166157460",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-o8qx4%40smarthomeapp-71479.iam.gserviceaccount.com"
}

login = credentials.Certificate(credPath)
firebase_admin.initialize_app(login)
db = firestore.client()

config = {
    "apiKey": "AIzaSyBNihIxMa32d8lngyL7Lubz7sPiIm0-rLg",
    "authDomain": "smarthomeapp-71479.firebaseapp.com",
    'databaseURL': "https://smarthomeapp-71479-default-rtdb.firebaseio.com",
    'projectId': "smarthomeapp-71479",
    'storageBucket': "smarthomeapp-71479.appspot.com",
    'messagingSenderId': "765744534122",
    'appId': "1:765744534122:web:824a3f3ee2086c52213013",
    'measurementId': "G-LFYMB88ZRM",
}

firebase = pyrebase.initialize_app(config)
database = firebase.database()

def getStatus():
    try:
        status = db.collection("status").stream()
        List = []
        for x in status:
            List.append(x.to_dict()['id'])
        return List
    except:
        print("error with getting status")


def updateRemainingTimeForSwitch(docID, inputTime,switchName):
    end = datetime.now() + timedelta(minutes=inputTime)
    db.collection("status").document(docID).update({
        "endTime": end
    })
    pinNumber = dicOfPinNumbers[""]
    if isRPI:
        GPIO.output(pinNumber, GPIO.HIGH)
    while True:
        start = datetime.now()
        duration = end - start
        remainingTime = str(duration)

        try:
            db.collection("status").document(docID).update({
               "remaining": remainingTime[:-7]
            })
            db.collection("switches").document(docID).update({
                "isOn": 0
            })
        except:
            print("error with update Firebase Status")

        if duration.total_seconds() < 1:
            if isRPI:
                GPIO.output(pinNumber, GPIO.LOW)
            print("LED OFF")
            db.collection("status").document(docID).delete()
            break


def deleteSwitches():
    statusListID = []
    switchesListID = []
    try:
        collectionOfStatus = db.collection("status").stream()
        collectionOfSwitches = db.collection("switches").stream()
        for x in collectionOfSwitches:
            switchesListID.append(x.to_dict()['id'])
        for x in collectionOfStatus:
            statusListID.append(x.to_dict()['id'])
        for x in collectionOfSwitches:
            for y in collectionOfStatus:
                if x != y:
                    db.collection("status").document(y).delete()
    except:
        print("")
def updateSwitches():
    try:
        collection = db.collection("switches").stream()
        for x in collection:
            if x.to_dict()['isOn'] > 0:
                current_time = datetime.now()
                a = current_time.time().strftime('%H:%M:%S').split(":")
                if int(a[0]) > 12:
                    currentTime = f"{int(a[0]) - 12}:{a[1]} PM"
                else:
                    currentTime = f"{a[0]}:{a[1]} AM"
                try:
                    db.collection("status").document(x.to_dict()['id']).set({
                        "id": x.to_dict()['id'],
                        'name': x.to_dict()['name'],
                        "remaining": f"{x.to_dict()['isOn']}",
                        "symbol": x.to_dict()['symbol'],
                        "time": currentTime
                    })
                    threading.Thread(target=updateRemainingTimeForSwitch(x.to_dict()['id'], x.to_dict()['isOn'], x.to_dict()['name'])).start()
                except:
                    print("error with update Firebase Status")

    except:
        print("error")
    finally:
        database.child("status").set(False)




def isChange():
    while True:
        try:
            mode = database.child("status").get().val()
        finally:
            if mode:
                threading.Thread(target=updateSwitches).start()
        time.sleep(5)

def updateSensorData(mode =False):
    while True:
        try:
            temp = database.child("temp").get().val()
            humi = database.child("humi").get().val()
            current_time = datetime.now()
            db.collection("sensors").document("0bibOg0vHAWWJsOqjBRW").update({
                "temp": temp,
                "humi": humi,
                "time": f"{current_time.strftime('%d/%m/%Y, %H:%M:%S')}"
            })
            if mode:
                return temp, humi
            time.sleep(15)

        except:
            print("Error with reading dht11 Data")

def errorUpdate():
    current_time = datetime.now()
    a = current_time.time().strftime('%H:%M:%S').split(":")
    if int(a[0]) > 12:
        currentTime = f"{int(a[0]) - 12}:{a[1]} PM"
    else:
        currentTime = f"{a[0]}:{a[1]} AM"
    db.collection("errorUpdate").document(f"errorUpdate{current_time.strftime('%m%d%Y%H%M%S')}").set({
        "id": f"motionDetected{current_time.strftime('%m%d%Y%H%M%S')}",
        "time": f"{current_time.strftime('%d/%m/%Y::')}{currentTime}"
    })

def isMotionDetected():
    while True:
        motion = database.child("motion").get().val()
        print(motion)
        try:
            if motion:
                current_time = datetime.now()
                a = current_time.time().strftime('%H:%M:%S').split(":")
                if int(a[0]) > 12:
                    currentTime = f"{int(a[0]) - 12}:{a[1]} PM"
                else:
                    currentTime = f"{a[0]}:{a[1]} AM"
                db.collection("motion detected").document(f"motionDetected{current_time.strftime('%m%d%Y%H%M%S')}").set({
                   "id" : f"motionDetected{current_time.strftime('%m%d%Y%H%M%S')}",
                    "time": f"{current_time.strftime('%d/%m/%Y::')}{currentTime}"
                })
                database.child("motion").set(False)
            else:
                time.sleep(1)

        except:
            print("Error with Motion Detection")


threading.Thread(target=isMotionDetected).start()
threading.Thread(target=updateSensorData).start()
threading.Thread(target=isChange).start()


def updateTelegramBotDataInFireBase(mode="",chatId=""):
    collectionOfStatus = db.collection("telegramData").stream()
    print(mode)
    print(type(chatId))
    if mode == "endOfDay":
        try:
            for x in collectionOfStatus:
                if str(x.to_dict()['chatId']) == chatId:
                    if x.to_dict()['today']:
                        db.collection("telegramData").document(x.to_dict()['id']).update({
                            "today": False,
                            'countedDays': x.to_dict()['countedDays']+1,
                        })
                        print("Updated Counted Days")
        except:
            print("error")
    elif mode == "today":
        try:
            for x in collectionOfStatus:
                if str(x.to_dict()['chatId']) == chatId:
                    db.collection("telegramData").document(x.to_dict()['id']).update({
                        "today": True,
                    })
                    print("Updated Today")
        except:
            print("error")


def sendTelegramTextMessage(msg):
    listOfChat_Ids = ["1314922309"]
    chat_id = msg['chat']['id']
    command = msg['text']

    if str(chat_id) in listOfChat_Ids:
        if command == '/hi':
            telegram_bot.sendMessage(chat_id, str("Hi sir/mam! \n I am RU-Smart Home \n some commands\n    /status\n    /temp"))
        elif command == '/status':
            try:
                telegram_bot.sendMessage(chat_id, str("Getting status updates....."))
                status = db.collection("status").stream()
                List = []
                for x in status:
                    List.append(x.to_dict()['id'])
                    print(List)
                    telegram_bot.sendMessage(chat_id,f"{x.to_dict()['name']} \nStarting time : {x.to_dict()['time']} \nEnding Time : {x.to_dict()['endTime']}\n Remaining Time : {x.to_dict()['remaining']}" )
            except:
                print("error with getting status")
        elif command == '/temp' or command == '/humi':
            status = db.collection("sensors").stream()
            for x in status:
                telegram_bot.sendMessage(chat_id,f"Temperature : {x.to_dict()['temp']}\nHumidity : {x.to_dict()['humi']} \nlast Updated : {x.to_dict()['time']}")
        elif command == '/Motion_Detected'or "/md":
            try:
                telegram_bot.sendMessage(chat_id, str("Getting Motion Detection Updates....."))
                status = db.collection("motion detected").stream()
                for x in status:
                    TimeDateOut = x.to_dict()['time'].split()
                    dateOut = TimeDateOut[0]
                    date = dateOut.split()
                    nowDate = datetime.now().strftime('%d/%m/%Y').split("/")
                    telegram_bot.sendMessage(chat_id,f"Time : {x.to_dict()['time']}")

            except:
                print("error with getting status")


        elif command == '/file':

            telegram_bot.sendDocument(chat_id, document=open('/home/pi/Aisha.py'))
            telegram_bot.sendPhoto(chat_id, photo="https://i.pinimg.com/avatars/circuitdigest_1464122100_280.jpg")

        elif command == '/audio':

            telegram_bot.sendAudio(chat_id, audio=open('/home/pi/test.mp3'))
        threading.Thread(target=updateTelegramBotDataInFireBase("today",str(chat_id))).start()
    else:
        telegram_bot.sendMessage(chat_id, str("You are not owner"))

telegram_bot = telepot.Bot('5905910533:AAHFNBWBCmuiOh3-htlhhVZB03hsZqSXzYo')
print(telegram_bot.getMe())
MessageLoop(telegram_bot, sendTelegramTextMessage).run_as_thread()
print('Up and Running....')


while 1:
    time.sleep(10)


