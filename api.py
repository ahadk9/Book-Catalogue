from flask import Blueprint, request, jsonify, abort
from models import db, Book

api = Blueprint('api', __name__, url_prefix='/api/books')

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

@api.route('', methods=['GET'])
def get_books():
    books = Book.query.all()
    return jsonify([b.to_dict() for b in books]), 200

@api.route('/<int:book_id>', methods=['GET'])
def get_book(book_id):
    book = Book.query.get(book_id)
    if not book:
        abort(404)
    return jsonify(book.to_dict()), 200

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

@api.route('/<int:book_id>', methods=['DELETE'])
def delete_book(book_id):
    book = Book.query.get(book_id)
    if not book:
        abort(404)
    db.session.delete(book)
    db.session.commit()
    return '', 204
