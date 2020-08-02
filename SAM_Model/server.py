import subprocess
from subprocess import Popen, PIPE
from subprocess import check_output
from flask import Flask


# def get_shell_script_output_using_communicate():
#     session = subprocess.Popen(
#         ['/Users/siddhanttiwari/Desktop/work/onlinecode_facer/shell.sh'],  stdout=PIPE, stderr=PIPE)
#         # ['shell.sh'], stdout = PIPE, stderr = PIPE)
#     stdout, stderr = session.communicate()
#     if stderr:
#         raise Exception("Error "+str(stderr))
#     return stdout.decode('utf-8')


def get_shell_script_output_using_check_output(mentor_id,batch,branch):
    stdout = check_output(
        ['/Users/siddhanttiwari/Desktop/work/onlinecode_facer/shell.sh',mentor_id,batch,branch]).decode('utf-8')
        # ['shell.sh']).decode('utf-8')
    return stdout


app = Flask(__name__)


@app.route('/<mentor_id>/<batch>/<branch>', methods=['POST', 'GET'])
def home(mentor_id,batch,branch):
    return '<pre>'+get_shell_script_output_using_check_output(mentor_id,batch,branch)+'</pre>'


app.run(debug=True)
