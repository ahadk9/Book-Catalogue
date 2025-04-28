# app.py Documentation

This file is the main entry point for the Book Catalogue Flask application. It initializes the app, configures the database, and registers all Blueprints.

---

```
from flask import Flask
```
- **Imports the Flask class** to create the web application instance.

```
from models import db
```
- **Imports the database instance** from the models module.

```
from api import api
```
- **Imports the API Blueprint** for RESTful API endpoints.

```
from views import views
```
- **Imports the frontend views Blueprint** for user-facing web pages.

```
import os
```
- **Imports the os module** for generating a random secret key.

```
app = Flask(__name__)
```
- **Creates the Flask application instance.**

```
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///books.db'
```
- **Configures the database URI** to use a local SQLite file named `books.db`.

```
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
```
- **Disables SQLAlchemy modification tracking** to save resources (recommended setting).

```
app.secret_key = os.urandom(24)
```
- **Sets a random secret key** for session management and flash messages.

```
db.init_app(app)
```
- **Initializes the database** with the Flask app.

```
app.register_blueprint(api)
```
- **Registers the API Blueprint** so API routes are available.

```
app.register_blueprint(views)
```
- **Registers the frontend views Blueprint** so user-facing routes are available.

```
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
```
- **Runs the app if this file is executed directly:**
  - Creates all database tables if they don't exist.
  - Starts the Flask development server in debug mode.

---

**Summary:**
- This file ties together all parts of the application, sets up the database, and launches the web server.
