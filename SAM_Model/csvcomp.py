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



# save only roll no. to datewise_metrics
dataset=pd.read_csv(x2)
datasetroll=dataset.iloc[:,1]

from csv import writer

y= 'rolldb_sem.csv'
with open(y, 'a+') as write_obj:
    csv_writer=writer(write_obj)
    csv_writer.writerow(datasetroll)
