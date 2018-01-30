from flask import Flask,request,Response
import json
import dbhandler

app = Flask(__name__)

@app.route('/load')
def hello_world():
	#rt = {'info':'hello world'}
	rt = dbhandler.fetchallTasks()
	response = Response(json.dumps(rt),mimetype="application/json")
	response.headers.add('Server','python flask')
	return response

@app.route('/upload',methods=['POST'])
def my_josn():
	print('headers--> %s' % request.headers)
	print('json--> %s,type = %s\n' % (request.json,type(request.json)))
	for task in request.json:
		print('task---->%s' % task)
	dbhandler.insertAllTask(request.json)
	rt = {'info':'ok'}
	response = Response(json.dumps(rt),mimetype="application/json")
	response.headers.add('Server','python flask')
	return response

if __name__ == '__main__':
	app.run(host='0.0.0.0')