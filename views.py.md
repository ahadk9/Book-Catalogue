# views.py Documentation

This file contains the Flask Blueprint for the frontend views of the Book Catalogue application. It handles rendering HTML pages and processing form submissions for listing, adding, editing, and deleting books.

---

```
from flask import Blueprint, render_template, redirect, url_for, request, flash
```
- **Imports Flask modules:**
  - `Blueprint`: Allows modular organization of Flask routes.
  - `render_template`: Renders HTML templates using Jinja2.
  - `redirect`: Redirects the user to a different route.
  - `url_for`: Generates URLs for routes by function name.
  - `request`: Accesses incoming request data (form data, etc.).
  - `flash`: Displays one-time messages to the user (e.g., errors).

```
from models import db, Book
```
- **Imports:**
  - `db`: The SQLAlchemy database instance.
  - `Book`: The Book model class representing the books table.

```
views = Blueprint('views', __name__)
```
- **Creates a Blueprint** named 'views' for organizing frontend routes.

---

## Route: `/books` (List Books)

```
@views.route('/books')
def list_books():
    books = Book.query.all()
    return render_template('list_books.html', books=books)
```
- **Purpose:** Displays a list of all books.
- **How it works:**
  - Fetches all Book records from the database.
  - Renders the `list_books.html` template, passing the list of books.

---

## Route: `/books/new` (Add Book)

```
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
```
- **Purpose:** Handles displaying and processing the form to add a new book.
- **How it works:**
  - **GET request:** Renders the empty add book form.
  - **POST request:**
    - Retrieves form data for all book fields.
    - Validates that title and author are provided.
    - Checks if ISBN is unique (if provided).
    - If validation fails, flashes an error and re-renders the form.
    - If valid, creates a new Book object, adds it to the database, and redirects to the book list.

---

## Route: `/books/edit/<int:book_id>` (Edit Book)

```
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
```
- **Purpose:** Handles displaying and processing the form to edit an existing book.
- **How it works:**
  - Fetches the book by `book_id` (404s if not found).
  - **GET request:** Renders the edit form pre-filled with the book's data.
  - **POST request:**
    - Retrieves updated form data.
    - Validates required fields and unique ISBN.
    - Updates the book in the database and redirects to the book list.

---

## Route: `/books/delete/<int:book_id>` (Delete Book)

```
@views.route('/books/delete/<int:book_id>', methods=['POST'])
def delete_book(book_id):
    book = Book.query.get_or_404(book_id)
    db.session.delete(book)
    db.session.commit()
    return redirect(url_for('views.list_books'))
```
- **Purpose:** Handles deleting a book.
- **How it works:**
  - Fetches the book by `book_id` (404s if not found).
  - Deletes the book from the database.
  - Redirects to the book list page.

---

**Summary:**
- This file manages all user-facing book operations (list, add, edit, delete) and ensures data validation and user feedback via flash messages.
