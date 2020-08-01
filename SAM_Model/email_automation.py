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

exit()