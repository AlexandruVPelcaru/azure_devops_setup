from flask import Flask, jsonify, render_template, request, redirect
from azure.cosmos import CosmosClient, exceptions
import os

# Initialize Flask app
app = Flask(__name__)

# Cosmos DB connection configuration
COSMOS_DB_ENDPOINT = os.environ.get('COSMOS_DB_ENDPOINT')
COSMOS_DB_KEY = os.environ.get('COSMOS_DB_KEY')
DATABASE_NAME = os.environ.get('COSMOS_DB_NAME')
COSMOS_DB_CONTAINER = os.environ.get('COSMOS_DB_CONTAINER')

# Initialize Cosmos DB client
client = CosmosClient(COSMOS_DB_ENDPOINT, COSMOS_DB_KEY)

# Route to display existing data
@app.route('/data', methods=['GET'])
def get_data():
    try:
        # Database and container reference
        database = client.get_database_client(DATABASE_NAME)
        container = database.get_container_client(COSMOS_DB_CONTAINER)
        items = list(container.read_all_items())
        return render_template('data.html', items=items)
    except exceptions.CosmosHttpResponseError as e:
        return jsonify({'error': str(e)}), 500

# Route to render UI form
@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

# Route to handle form submission
@app.route('/add', methods=['POST'])
def add_data():
    try:
        # Retrieve form data
        item_id = request.form['id']
        item_data = request.form['data']

        # Database and container reference
        database = client.get_database_client(DATABASE_NAME)
        container = database.get_container_client(COSMOS_DB_CONTAINER)

        # Add item to the database
        new_item = {'id': item_id, 'data': item_data}
        container.create_item(new_item)

        return redirect('/')
    except exceptions.CosmosHttpResponseError as e:
        return jsonify({'error': str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)