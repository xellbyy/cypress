
import sqlite3
import subprocess
import hashlib
import pickle
from flask import Flask, request

app = Flask(__name__)

# 1. SQL Injection
@app.route("/user")
def get_user():
    user_id = request.args.get("id", "")
    conn = sqlite3.connect("test.db")
    query = "SELECT * FROM users WHERE id = '" + user_id + "'"
    return str(conn.execute(query).fetchall())


# 2. Command Injection
@app.route("/ping")
def ping():
    host = request.args.get("host", "localhost")
    result = subprocess.run(
        "ping -c 1 " + host,
        shell=True,
        capture_output=True,
        text=True
    )
    return result.stdout


# 3. Использование слабого хеширования MD5
@app.route("/hash")
def make_hash():
    value = request.args.get("value", "")
    return hashlib.md5(value.encode()).hexdigest()


# 4. Небезопасная десериализация
@app.route("/load")
def load_data():
    data = request.args.get("data", "")
    import base64
    decoded = base64.b64decode(data)
    obj = pickle.loads(decoded)
    return str(obj)


# 5. Отсутствие проверки входных данных
@app.route("/redirect")
def redirect_user():
    from flask import redirect
    url = request.args.get("url", "/")
    return redirect(url)
