from flask import Flask
from models import db
from api import api
from views import views
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///books.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.secret_key = os.urandom(24)

db.init_app(app)
app.register_blueprint(api)
app.register_blueprint(views)

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
