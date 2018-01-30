import sqlite3 as sql

def insertTask(task,cursor):
	
	insertSql = '''replace into TASKINFO (createDate, content,finish,progress,expireDate)
	 values (?,?,?,?,?)'''
	cursor.execute(insertSql,(task['createDate'],task['content'],task['finish'],task['progress'],task['expireDate']))

def insertAllTask(tasks):
	conn = sql.connect('task.db')
	cursor = conn.cursor()
	createSql = '''create table if not exists TASKINFO (createDate INTEGER primary key,content TEXT, 
		finish INTEGER,progress INTEGER,expireDate INTEGER)'''
	cursor.execute(createSql)
	for task in tasks:
		insertTask(task,cursor)
	cursor.close()
	conn.commit()
	conn.close()

def fetchTaskWithCreateDate(createDate):
	conn = sql.connect('task.db')
	cursor = conn.cursor()
	cursor.execute('select * from TASKINFO where createDate = ?',(createDate,))
	values = cursor.fetchall()
	cursor.close()
	conn.close()
	return values

def fetchallTasks():
	conn = sql.connect('task.db')
	cursor = conn.cursor()
	cursor.execute('select * from TASKINFO')
	values = cursor.fetchall()
	tasks = []
	for value in values:
		task = {}
		task["createDate"] = value[0]
		task["content"] = value[1]
		task["finish"] = value[2]
		task['progress'] = value[3]
		task['expireDate'] = value[4]
		tasks.append(task)
	cursor.close()
	conn.close()
	return tasks

