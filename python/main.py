import pyrebase
from time import sleep
import threading

config = {
    "apiKey": "AIzaSyBNihIxMa32d8lngyL7Lubz7sPiIm0-rLg",
    "authDomain": "smarthomeapp-71479.firebaseapp.com",
    "databaseURL": "https://smarthomeapp-71479-default-rtdb.firebaseio.com",
    "projectId": "smarthomeapp-71479",
    "storageBucket": "smarthomeapp-71479.appspot.com",
    "messagingSenderId": "765744534122",
    "appId": "1:765744534122:web:f98d257e1b97bd1f213013",
    "measurementId": "G-F0CLY7XZVM"
}

firebase = pyrebase.initialize_app(config)
database = firebase.database()


def Switch1():
    print("hello")
    # try:
    #     if switch1 == True:
    #         switch1Timer = database.child("switch1Timer").get().val()
    #         if switch1Timer > 0:
    #             pass
    #         else:
    #             switch1Timer = 1
    #         sleep(switch1Timer)
    # finally:
    #     pass


def thread_function():
    global switch1, switch2, switch3, switch4, switch5, switch6, switch7, switch8
    while True:
        if database.child("change").get().val():

            switch1 = database.child("switch1").get().val()
            if switch1:
                threading.Thread(target=Switch1).start()
            switch2 = database.child("switch2").get().val()
            if switch2:
                threading.Thread(target=Switch1).start()
            switch3 = database.child("switch3").get().val()
            if switch3:
                threading.Thread(target=Switch1).start()
            switch4 = database.child("switch4").get().val()
            if switch4:
                threading.Thread(target=Switch1).start()
            switch5 = database.child("switch5").get().val()
            if switch5:
                threading.Thread(target=Switch1).start()
            switch6 = database.child("switch6").get().val()
            if switch6:
                threading.Thread(target=Switch1).start()
            switch7 = database.child("switch7").get().val()
            if switch7:
                threading.Thread(target=Switch1).start()
            switch8 = database.child("switch8").get().val()
            if switch8:
                threading.Thread(target=Switch1).start()
        else:
            print("delay")
            sleep(10)


threading.Thread(target=thread_function).start()
