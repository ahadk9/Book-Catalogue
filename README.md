# Book Catalogue Web Application

A simple Flask web application to manage a collection of books. Users can view, add, edit, and delete books via a web interface.

## Features
- View all books
- Add a new book
- Edit existing books
- Delete books
- RESTful API for CRUD operations

## Technology Stack
- Python (Flask)
- Flask-SQLAlchemy
- SQLite
- Jinja2 templates
- Bootstrap (for UI)

## Setup Instructions

1. **Install dependencies:**
   ```powershell
   pip install -r requirements.txt
   ```
2. **Run the application:**
   ```powershell
   python app.py
   ```
3. **Access the app:**
   Open your browser and go to [http://127.0.0.1:5000/books](http://127.0.0.1:5000/books)

## Project Structure
- `app.py` - Main application entry point
- `models.py` - Database models
- `api.py` - RESTful API endpoints
- `views.py` - Frontend routes and views
- `templates/` - Jinja2 HTML templates
- `requirements.txt` - Python dependencies

## Notes
- No authentication is implemented.
- Data is stored in `books.db` (SQLite).
- For development use only.
