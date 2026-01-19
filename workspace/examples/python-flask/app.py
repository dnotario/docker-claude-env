from flask import Flask, jsonify, request
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        'message': 'Welcome to Flask API starter!',
        'endpoints': {
            'health': '/health',
            'hello': '/hello/<name>',
            'echo': '/echo (POST)'
        }
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/hello/<name>')
def hello(name):
    return jsonify({
        'message': f'Hello, {name}!'
    })

@app.route('/echo', methods=['POST'])
def echo():
    data = request.get_json()
    return jsonify({
        'received': data,
        'timestamp': datetime.now().isoformat()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
