# SAM Server Side : Developed by IIIT Technocrats, IIIT Sonepat
# SAM Server Side : Developed by IIIT Technocrats, IIIT Sonepat
import sys
import cv2
import numpy as np
import face_recognition
import os
from datetime import datetime
from time import sleep
import time
import time

print('Initiating SAM...')
print('Communicating with the server')


mentor_id=sys.argv[1]
batch=sys.argv[2]
branch=sys.argv[3]


# strike=int(input())
# if strike==1:
#     print('Fetching Data from SAM UI...')
#     mentor_id='Mentor 1'
#     batch='2019'
#     branch='IT'
#
# else:
#     print('Lacking Physical Server, Connection issues...\nPlease enter details: ')
#     print('Enter Mentor ID')
#     mentor_id = str(input())
#     print('Enter Batch')
#     batch = str(input())
#     print('Enter Branch')
#     branch = str(input())


# counter=0
timeout = time.time() + 10   # 30 sec from now

path = 'ImagesAttendance'
images = []
classNames = []
myList = os.listdir(path)
print(myList)
for cl in myList:
    curImg = cv2.imread(f'{path}/{cl}')
    images.append(curImg)
    classNames.append(os.path.splitext(cl)[0])
    # for multiple dataset training write like : Siddhant Tiwari_1.jpg and so on
    # cl=cl.split('_')[0]
    # classNames.append(cl)
print(classNames)


def findEncodings(images):
    encodeList = []
    for img in images:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        encode = face_recognition.face_encodings(img)[0]
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




#### FOR CAPTURING SCREEN RATHER THAN WEBCAM
# def captureScreen(bbox=(300,300,690+300,530+300)):
#     capScr = np.array(ImageGrab.grab(bbox))
#     capScr = cv2.cvtColor(capScr, cv2.COLOR_RGB2BGR)# hello siddhant

#     return capScr

encodeListKnown = findEncodings(images)
print('Encoding Complete')

cap = cv2.VideoCapture(0)

while True:
    success, img = cap.read()
    # img = captureScreen()
    imgS = cv2.resize(img, (0, 0), None, 0.25, 0.25)
    imgS = cv2.cvtColor(imgS, cv2.COLOR_BGR2RGB)

    facesCurFrame = face_recognition.face_locations(imgS)
    encodesCurFrame = face_recognition.face_encodings(imgS, facesCurFrame)

    for encodeFace, faceLoc in zip(encodesCurFrame, facesCurFrame):
        matches = face_recognition.compare_faces(encodeListKnown, encodeFace) #give third parameter for tolerence default= 0.6

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

    if time.time() > timeout:
        break

print('Recognition Complete, Comparing and Splitting data...')


#################### Main Program Ends ######################
#################### csvcomp.py ######################



import csv
import datetime
import pandas as pd

f1=pd.read_csv('Attendance.csv')
f2=pd.read_csv('new.csv')
r=(f2[f2.name.isin(f1.name)])
df=pd.DataFrame(r)
# print(r)


# with open('Attendance.csv', 'r') as t1, open('new.csv', 'r') as t2:
#     fileone = t1.readlines()
#     filetwo = t2.readlines()

x=datetime.date.today()
x2='datewise/' + str(x)+'.csv'
with open(x2, 'w') as outFile:
    df.to_csv(x2, index=False)



#################for database of absentee

print('Creating absentee dataset...')


f1=pd.read_csv('Attendance.csv')
f2=pd.read_csv('new.csv')
r=(f2[~f2.name.isin(f1.name)])
df=pd.DataFrame(r)
# print(r)


# with open('Attendance.csv', 'r') as t1, open('new.csv', 'r') as t2:
#     fileone = t1.readlines()
#     filetwo = t2.readlines()

x=datetime.date.today()
x2='datewise_absent/' + str(x)+'.csv'
with open(x2, 'w') as outFile:
    df.to_csv(x2, index=False)



print('Updating Semesterwise Metrics...')

# save only roll no. to datewise_metrics
dataset=pd.read_csv(x2)
datasetroll=dataset.iloc[:,1]

from csv import writer

y= 'rolldb_sem.csv'
with open(y, 'a+') as write_obj:
    csv_writer=writer(write_obj)
    csv_writer.writerow(datasetroll)



print('Complete, Communicating with SAM UI : Uploading Data...')

#################### firebaselink.py ###########################



import csv
import firebase_admin
import google.cloud
from firebase_admin import credentials, firestore
import datetime



x = str(datetime.date.today())
datetoday=x



cred = credentials.Certificate("./ServiceAcountKey.json")
app = firebase_admin.initialize_app(cred)

store = firestore.client()

file_path = 'datewise/'+ x + ".csv"
collection_name = "Attendance/"+batch+"/"+branch+"/"+ mentor_id + '/' + x


def batch_data(iterable, n=1):
    l = len(iterable)
    for ndx in range(0, l, n):
        yield iterable[ndx:min(ndx + n, l)]


data = []
headers = []
with open(file_path) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            for header in row:
                headers.append(header)
            line_count += 1
        else:
            obj = {}
            for idx, item in enumerate(row):
                obj[headers[idx]] = item
            data.append(obj)
            line_count += 1
    print(f'Processed {line_count} lines.')

uid_list=[]
for uid_count in range(len(data)):
    uid_list.append(data[uid_count]['uid'])


uidc=0
for batched_data in batch_data(data, 499):
    batch = store.batch()


    for data_item in batched_data:
        # print(data)
        doc_ref = store.collection(collection_name).document(uid_list[uidc])
        batch.set(doc_ref, data_item)
        uidc=uidc+1
    batch.commit()

print('Data Uploaded, Initializing Email Automation, Will take a while...')


############## Email Automation #########################

import smtplib
import pandas as pd
import datetime

x=datetime.date.today()
x=str(x) + '.csv'
set=pd.read_csv('datewise_absent/'+x)
setf=set.iloc[:,2]
print(setf)
for x in setf:

    smtpObj=smtplib.SMTP('smtp.gmail.com',587)
    smtpObj.ehlo()
    smtpObj.starttls()
    smtpObj.login('devhackathon@gmail.com','bwxzuaicpoklqkse')
    smtpObj.sendmail('devhackathon@gmail.com',x,'Subject: Attendance: SAM Portal\n\n\n You are marked are absent today.\n Lecture: Mentor1\n'+x+'\n\nThanks\nSAM')

print('Emails Sent, May take a while to reach')
print('Attendance complete...\nThanks\nSAM')

# SAM Server Side : Developed by IIIT Technocrats, IIIT Sonepat
# SAM Server Side : Developed by IIIT Technocrats, IIIT Sonepat 