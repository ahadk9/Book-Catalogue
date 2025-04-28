# api.py Documentation

This file defines the RESTful API endpoints for managing books in the Book Catalogue application. It uses a Flask Blueprint to organize API routes under `/api/books`.

---

```
from flask import Blueprint, request, jsonify, abort
```
- **Imports Flask modules:**
  - `Blueprint`: For modular route organization.
  - `request`: To access incoming JSON data.
  - `jsonify`: To return JSON responses.
  - `abort`: To send HTTP error responses (e.g., 404).

```
from models import db, Book
```
- **Imports:**
  - `db`: The SQLAlchemy database instance.
  - `Book`: The Book model class.

```
api = Blueprint('api', __name__, url_prefix='/api/books')
```
- **Creates a Blueprint** named 'api' for API routes, all prefixed with `/api/books`.

---

## Endpoint: POST `/api/books` (Create Book)

```
@api.route('', methods=['POST'])
def create_book():
    data = request.get_json()
    if not data or not data.get('title') or not data.get('author'):
        return jsonify({'error': 'Title and author are required.'}), 400
    if data.get('isbn'):
        existing = Book.query.filter_by(isbn=data['isbn']).first()
        if existing:
            return jsonify({'error': 'ISBN must be unique.'}), 400
    book = Book(
        title=data['title'],
        author=data['author'],
        isbn=data.get('isbn'),
        publication_year=data.get('publication_year'),
        genre=data.get('genre')
    )
    db.session.add(book)
    db.session.commit()
    return jsonify(book.to_dict()), 201
```
- **Purpose:** Creates a new book from JSON data.
- **How it works:**
  - Validates required fields (title, author).
  - Checks for unique ISBN if provided.
  - Adds the new book to the database and returns its data with status 201.

---

## Endpoint: GET `/api/books` (List All Books)

```
@api.route('', methods=['GET'])
def get_books():
    books = Book.query.all()
    return jsonify([b.to_dict() for b in books]), 200
```
- **Purpose:** Returns a list of all books as JSON.

---

## Endpoint: GET `/api/books/<int:book_id>` (Get Single Book)

```
@api.route('/<int:book_id>', methods=['GET'])
def get_book(book_id):
    book = Book.query.get(book_id)
    if not book:
        abort(404)
    return jsonify(book.to_dict()), 200
```
- **Purpose:** Returns a single book by ID as JSON, or 404 if not found.

---

## Endpoint: PUT `/api/books/<int:book_id>` (Update Book)

```
@api.route('/<int:book_id>', methods=['PUT'])
def update_book(book_id):
    book = Book.query.get(book_id)
    if not book:
        abort(404)
    data = request.get_json()
    if not data or not data.get('title') or not data.get('author'):
        return jsonify({'error': 'Title and author are required.'}), 400
    if data.get('isbn'):
        existing = Book.query.filter(Book.isbn == data['isbn'], Book.id != book_id).first()
        if existing:
            return jsonify({'error': 'ISBN must be unique.'}), 400
    book.title = data['title']
    book.author = data['author']
    book.isbn = data.get('isbn')
    book.publication_year = data.get('publication_year')
    book.genre = data.get('genre')
    db.session.commit()
    return jsonify(book.to_dict()), 200
```
- **Purpose:** Updates an existing book by ID with new data.
- **How it works:**
  - Validates input and unique ISBN.
  - Updates the book and returns the updated data.

---

## Endpoint: DELETE `/api/books/<int:book_id>` (Delete Book)

```
@api.route('/<int:book_id>', methods=['DELETE'])
def delete_book(book_id):
    book = Book.query.get(book_id)
    if not book:
        abort(404)
    db.session.delete(book)
    db.session.commit()
    return '', 204
```
- **Purpose:** Deletes a book by ID. Returns empty response with status 204.

---

**Summary:**
- This file provides all backend API endpoints for CRUD operations on books, with input validation and error handling.
