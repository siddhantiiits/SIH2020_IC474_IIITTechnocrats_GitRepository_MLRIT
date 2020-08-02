import cv2
import numpy as np
import face_recognition
import os
from datetime import datetime
from time import sleep
import time
import time

import PIL

counter=0
   # 5 minutes from now

path = 'ImagesAttendance'
images = []
classNames = []
myList = os.listdir(path)
print(myList)
for cl in myList:
    curImg = cv2.imread(f'{path}/{cl}')
    images.append(curImg)
    classNames.append(os.path.splitext(cl)[0])
    # # for multiple dataset training write like : Siddhant Tiwari_1.jpg and so on and comment above line.
    # cl=cl.split('_')[0]
    # classNames.append(cl)
print(classNames)


def findEncodings(images):
    encodeList = []
    for img in images:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        encode = face_recognition.face_encodings(img)[0]   #num_jitters=100 for better accuracy
        encodeList.append(encode)
    return encodeList

#
with open('Attendance.csv','w+') as f:
    f.writelines(f'name,time')


def markAttendance(name):
    with open('Attendance.csv', 'r+') as f:
        namelist=[]

        myDataList = f.readlines()
        for line in myDataList:
            entry=line.split(',')
            namelist.append(entry[0])

        if name not in namelist:
            now=datetime.now()
            dtstring=now.strftime('%H:%M:%S')
            f.writelines(f'\n{name},{dtstring}')




# ### FOR CAPTURING SCREEN RATHER THAN WEBCAM
# def captureScreen(bbox=(300,300,690+300,530+300)):
#     capScr = np.array(ImageGrab.grab(bbox))
#     capScr = cv2.cvtColor(capScr, cv2.COLOR_RGB2BGR)# hello siddhant
#
#     return capScr

encodeListKnown = findEncodings(images)
print('Encoding Complete')

cap = cv2.VideoCapture(0)
timeout = time.time() + 10
while True:
    success, img = cap.read()
    # img = captureScreen()
    # img=cv2.imread("pictest1.JPG")
    imgS = cv2.resize(img, (0, 0), None, 0.25, 0.25)
    imgS = cv2.cvtColor(imgS, cv2.COLOR_BGR2RGB)

    # facesCurFrame = face_recognition.face_locations(imgS)
    facesCurFrame = face_recognition.face_locations(imgS, number_of_times_to_upsample=2)
    encodesCurFrame = face_recognition.face_encodings(imgS, facesCurFrame)

    for encodeFace, faceLoc in zip(encodesCurFrame, facesCurFrame):
        matches = face_recognition.compare_faces(encodeListKnown, encodeFace, 0.5)  #give third parameter for tolerence default= 0.6

        faceDis = face_recognition.face_distance(encodeListKnown, encodeFace)
        print(faceDis)
        counter=counter+1





        matchIndex=np.argmin(faceDis)
        print(matchIndex)



        if matches[matchIndex]:
            name=classNames[matchIndex]
            # markAttendance(name)
            y1,x2,y2,x1=faceLoc
            y1, x2, y2, x1=y1*4,x2*4,y2*4,x1*4
            cv2.rectangle(img,(x1,y1),(x2,y2),(255,255,0),2)
            cv2.putText(img,name,(x1+6,y2-6),cv2.FONT_HERSHEY_COMPLEX,1,(255,255,255),2)
            markAttendance(name)

        else:
            print('unknown person found')
            y1, x2, y2, x1 = faceLoc
            y1, x2, y2, x1 = y1 * 4, x2 * 4, y2 * 4, x1 * 4
            cv2.rectangle(img, (x1, y1), (x2, y2), (255, 255, 0), 2)
            cv2.putText(img, 'Unknown', (x1 + 6, y2 - 6), cv2.FONT_HERSHEY_COMPLEX, 1, (255, 0, 255), 2)

    cv2.imshow('webcam',img)
    cv2.waitKey(1)

    # if time.time() > timeout:
    #     break

print(counter)
