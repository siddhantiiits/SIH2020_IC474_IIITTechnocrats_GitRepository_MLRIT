import csv
import firebase_admin
import google.cloud
from firebase_admin import credentials, firestore
import datetime

print('Enter Mentor ID')
mentor_id=str(input())


x = str(datetime.date.today())



cred = credentials.Certificate("./ServiceAcountKey.json")
app = firebase_admin.initialize_app(cred)

store = firestore.client()

file_path = 'datewise/'+ x + ".csv"
collection_name = "Attendance/2019/IT/"+ mentor_id + '/' + x


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

print('Done')