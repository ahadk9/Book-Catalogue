from flask import Blueprint, render_template, redirect, url_for, request, flash
from models import db, Book

views = Blueprint('views', __name__)

@views.route('/books')
def list_books():
    books = Book.query.all()
    return render_template('list_books.html', books=books)

@views.route('/books/new', methods=['GET', 'POST'])
def add_book():
    if request.method == 'POST':
        title = request.form.get('title')
        author = request.form.get('author')
        isbn = request.form.get('isbn')
        publication_year = request.form.get('publication_year')
        genre = request.form.get('genre')
        if not title or not author:
            flash('Title and Author are required.')
            return render_template('add_book.html')
        if isbn and Book.query.filter_by(isbn=isbn).first():
            flash('ISBN must be unique.')
            return render_template('add_book.html')
        book = Book(title=title, author=author, isbn=isbn or None, publication_year=publication_year or None, genre=genre or None)
        db.session.add(book)
        db.session.commit()
        return redirect(url_for('views.list_books'))
    return render_template('add_book.html')

@views.route('/books/edit/<int:book_id>', methods=['GET', 'POST'])
def edit_book(book_id):
    book = Book.query.get_or_404(book_id)
    if request.method == 'POST':
        title = request.form.get('title')
        author = request.form.get('author')
        isbn = request.form.get('isbn')
        publication_year = request.form.get('publication_year')
        genre = request.form.get('genre')
        if not title or not author:
            flash('Title and Author are required.')
            return render_template('edit_book.html', book=book)
        if isbn and Book.query.filter(Book.isbn == isbn, Book.id != book_id).first():
            flash('ISBN must be unique.')
            return render_template('edit_book.html', book=book)
        book.title = title
        book.author = author
        book.isbn = isbn or None
        book.publication_year = publication_year or None
        book.genre = genre or None
        db.session.commit()
        return redirect(url_for('views.list_books'))
    return render_template('edit_book.html', book=book)

@views.route('/books/delete/<int:book_id>', methods=['POST'])
def delete_book(book_id):
    book = Book.query.get_or_404(book_id)
    db.session.delete(book)
    db.session.commit()
    return redirect(url_for('views.list_books'))
