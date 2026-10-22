import csv
from pathlib import Path

from flask import Flask, render_template

app = Flask(__name__)
STUDENTS_CSV = Path(__file__).parent / "database" / "students.csv"


def student_names():
    with STUDENTS_CSV.open(newline="", encoding="utf-8") as file:
        rows = csv.DictReader(file)
        return sorted(row["full_name"] for row in rows)


@app.get("/")
def index():
    return render_template("index.html", names=student_names())
