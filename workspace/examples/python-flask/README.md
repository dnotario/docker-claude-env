# Flask API Starter

Simple Flask REST API starter template.

## Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Run

```bash
python app.py
```

## Test

```bash
# In another terminal
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/hello/world
curl -X POST http://localhost:5000/echo -H "Content-Type: application/json" -d '{"test": "data"}'
```

## Features

- Flask 3.x
- JSON responses
- Basic routing
- Health check endpoint
- POST endpoint example

## Next Steps

- Add database (SQLAlchemy with PostgreSQL/MySQL)
- Add authentication (Flask-JWT-Extended)
- Add validation (marshmallow)
- Add tests (pytest)
- Add configuration management
- Add CORS support (flask-cors)
