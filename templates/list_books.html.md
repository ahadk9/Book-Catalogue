# list_books.html Documentation

This file is a Jinja2 HTML template for displaying the list of all books in the catalogue. It uses Bootstrap for styling and provides options to add, edit, or delete books.

---

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Book Catalogue</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body>
<div class="container mt-4">
    <h1>Book Catalogue</h1>
    <a href="{{ url_for('views.add_book') }}" class="btn btn-primary mb-3">Add Book</a>
    {% with messages = get_flashed_messages() %}
      {% if messages %}
        <div class="alert alert-warning">{{ messages[0] }}</div>
      {% endif %}
    {% endwith %}
    <table class="table table-bordered table-striped">
        <thead>
        <tr>
            <th>Title</th>
            <th>Author</th>
            <th>ISBN</th>
            <th>Year</th>
            <th>Genre</th>
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        {% for book in books %}
            <tr>
                <td>{{ book.title }}</td>
                <td>{{ book.author }}</td>
                <td>{{ book.isbn or '' }}</td>
                <td>{{ book.publication_year or '' }}</td>
                <td>{{ book.genre or '' }}</td>
                <td>
                    <a href="{{ url_for('views.edit_book', book_id=book.id) }}" class="btn btn-sm btn-warning">Edit</a>
                    <form action="{{ url_for('views.delete_book', book_id=book.id) }}" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure?')">Delete</button>
                    </form>
                </td>
            </tr>
        {% endfor %}
        </tbody>
    </table>
</div>
</body>
</html>
```

- **HTML Structure:**
  - Uses Bootstrap for styling.
  - Displays a heading and a button to add a new book.
  - Shows flash messages if any (e.g., errors or notifications).
  - Displays a table of all books with columns for Title, Author, ISBN, Year, Genre, and Actions.
  - For each book, provides Edit and Delete buttons.
  - The Delete button uses a confirmation dialog to prevent accidental deletions.

---

**Summary:**
- This template provides a user-friendly interface for viewing and managing the book catalogue.
