from flask import Flask, render_template_string, request, jsonify
import mysql.connector
from mysql.connector import errorcode
import os

# Flask app setup
app = Flask(__name__)

# Database connection details

db_config = {
    "host": os.getenv("DB_HOST"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_NAME")
}

# HTML template for the UI
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Database Interface</title>
</head>
<body>
    <h1>Database Interface</h1>
    <form action="/view" method="get">
        <button type="submit">View Database Content</button>
    </form>
    <form action="/post" method="post">
        <input type="text" name="data" placeholder="Enter data to post" required>
        <button type="submit">Post to Database</button>
    </form>
</body>
</html>
'''

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE)

@app.route('/view', methods=['GET'])
def view_database():
    try:
        connection = mysql.connector.connect(**db_config)
        if connection.is_connected():
            cursor = connection.cursor()
            cursor.execute("SELECT * FROM your_table_name")  # Replace with your table name
            results = cursor.fetchall()
            cursor.close()
            return jsonify(results)
    except mysql.connector.Error as err:
        return str(err), 500
    finally:
        if 'connection' in locals() and connection.is_connected():
            connection.close()

@app.route('/post', methods=['POST'])
def post_to_database():
    data = request.form.get('data')
    if data:
        try:
            connection = mysql.connector.connect(**db_config)
            if connection.is_connected():
                cursor = connection.cursor()
                query = "INSERT INTO your_table_name (your_column_name) VALUES (%s)"  # Replace with your table and column
                cursor.execute(query, (data,))
                connection.commit()
                cursor.close()
                return f"Data '{data}' added to the database!"
        except mysql.connector.Error as err:
            return str(err), 500
        finally:
            if 'connection' in locals() and connection.is_connected():
                connection.close()
    return "No data provided!", 400

if __name__ == '__main__':
    app.run(debug=True, port=8080)
