import requests
url = "https://www.fast2sms.com/dev/bulk"
payload = "sender_id=FSTSMS&message=this is automated py sms developer-Siddhant&language=english&route=p&numbers=8865838380,8198000795"
headers = {
'authorization': "ihmQZ7dAnYgsazHFRLGWVSuEqByw5vD6C3efJxtjN1p9IkM8O2NOv1wqeomWytXKGU0Pks8FiB7uZY65",
'Content-Type': "application/x-www-form-urlencoded",
'Cache-Control': "no-cache",
}
response = requests.request("POST", url, data=payload, headers=headers)
print(response.text)