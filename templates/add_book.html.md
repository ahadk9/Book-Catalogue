# add_book.html Documentation

This file is a Jinja2 HTML template for the form to add a new book to the catalogue. It uses Bootstrap for styling and displays validation errors using flash messages.

---

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Book</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
<div class="container mt-4">
    <h1>Add Book</h1>
    <form method="post">
        <div class="mb-3">
            <label for="title" class="form-label">Title *</label>
            <input type="text" class="form-control" id="title" name="title" required>
        </div>
        <div class="mb-3">
            <label for="author" class="form-label">Author *</label>
            <input type="text" class="form-control" id="author" name="author" required>
        </div>
        <div class="mb-3">
            <label for="isbn" class="form-label">ISBN</label>
            <input type="text" class="form-control" id="isbn" name="isbn">
        </div>
        <div class="mb-3">
            <label for="publication_year" class="form-label">Publication Year</label>
            <input type="number" class="form-control" id="publication_year" name="publication_year">
        </div>
        <div class="mb-3">
            <label for="genre" class="form-label">Genre</label>
            <input type="text" class="form-control" id="genre" name="genre">
        </div>
        <button type="submit" class="btn btn-success">Add Book</button>
        <a href="{{ url_for('views.list_books') }}" class="btn btn-secondary">Cancel</a>
    </form>
    {% with messages = get_flashed_messages() %}
      {% if messages %}
        <div class="alert alert-warning mt-3">{{ messages[0] }}</div>
      {% endif %}
    {% endwith %}
</div>
</body>
</html>
```

- **HTML Structure:**
  - Uses Bootstrap for styling.
  - Displays a heading and a form for entering book details.
  - Fields: Title (required), Author (required), ISBN, Publication Year, Genre.
  - Shows flash messages for validation errors.
  - Provides buttons to submit the form or cancel and return to the book list.

---

**Summary:**
- This template provides a clear and user-friendly form for adding new books, with validation feedback.
