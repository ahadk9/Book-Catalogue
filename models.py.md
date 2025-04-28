# models.py Documentation

This file defines the database model for the Book Catalogue application using Flask-SQLAlchemy.

---

```
from flask_sqlalchemy import SQLAlchemy
```
- **Imports the SQLAlchemy class** from Flask-SQLAlchemy, which is used to interact with the database using Python objects.

```
db = SQLAlchemy()
```
- **Creates a SQLAlchemy database instance** called `db`. This will be used to define models and interact with the database.

```
class Book(db.Model):
```
- **Defines the Book model** as a subclass of `db.Model`. Each instance represents a row in the `books` table.

```
    id = db.Column(db.Integer, primary_key=True)
```
- **Primary key column.**
- `id`: Integer, unique for each book, auto-incremented by the database.

```
    title = db.Column(db.String(255), nullable=False)
```
- **Title column.**
- `title`: String (max 255 characters), required (cannot be null).

```
    author = db.Column(db.String(255), nullable=False)
```
- **Author column.**
- `author`: String (max 255 characters), required.

```
    isbn = db.Column(db.String(20), unique=True, nullable=True)
```
- **ISBN column.**
- `isbn`: String (max 20 characters), optional (can be null), must be unique if provided.

```
    publication_year = db.Column(db.Integer, nullable=True)
```
- **Publication year column.**
- `publication_year`: Integer, optional.

```
    genre = db.Column(db.String(100), nullable=True)
```
- **Genre column.**
- `genre`: String (max 100 characters), optional.

```
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'author': self.author,
            'isbn': self.isbn,
            'publication_year': self.publication_year,
            'genre': self.genre
        }
```
- **to_dict method:**
- Returns a dictionary representation of the Book instance, useful for JSON responses in APIs.

---

**Summary:**
- This file defines the structure of the books table and provides a method to easily convert a Book object to a dictionary for API responses.
