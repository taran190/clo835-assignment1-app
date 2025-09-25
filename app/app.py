# app.py
from flask import Flask, jsonify, render_template_string
import os
import pymysql
import time

app = Flask(__name__)

APP_COLOR = os.getenv('APP_COLOR', 'blue')
DBHOST = os.getenv('DBHOST', 'mysql')
DBPORT = int(os.getenv('DBPORT', 3306))
DBUSER = os.getenv('DBUSER', 'root')
DBPWD = os.getenv('DBPWD', 'pw')
DATABASE = os.getenv('DATABASE', 'employees')

TEMPLATE = """
<!doctype html>
<html>
  <head><title>Simple App - {{color}}</title></head>
  <body style="font-family: sans-serif; background: #f4f6f8;">
    <h1 style="color: {{color}};">Hello from the {{color}} app!</h1>
    <p>DB host: {{dbhost}} | DB status: {{db_status}}</p>
  </body>
</html>
"""

def check_db():
    try:
        conn = pymysql.connect(host=DBHOST, port=DBPORT, user=DBUSER, password=DBPWD,
                               database=DATABASE, connect_timeout=3)
        conn.close()
        return "OK"
    except Exception as e:
        return f"ERROR: {e}"

@app.route('/')
def index():
    db_status = check_db()
    return render_template_string(TEMPLATE, color=APP_COLOR, dbhost=DBHOST, db_status=db_status)

if __name__ == '__main__':
    # listen on 0.0.0.0:8080
    app.run(host='0.0.0.0', port=8080)

