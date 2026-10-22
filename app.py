import csv
from pathlib import Path

from flask import Flask, render_template

app = Flask(__name__)
STUDENTS_CSV = Path(__file__).parent / "database" / "students.csv"

SKILLS = (
    ("skill_programming", "Programming"),
    ("skill_data_stats", "Data and stats"),
    ("skill_frontend_design", "Frontend design"),
    ("skill_business_pitch", "Business pitch"),
)


def load_students():
    with STUDENTS_CSV.open(newline="", encoding="utf-8") as file:
        return list(csv.DictReader(file))


def student_names(students):
    return sorted(student["full_name"] for student in students)


def skill_averages(students):
    count = len(students)
    averages = []
    for column, label in SKILLS:
        total = sum(int(student[column]) for student in students)
        averages.append({"label": label, "average": total / count})
    return averages


@app.get("/")
def index():
    students = load_students()
    return render_template(
        "index.html",
        names=student_names(students),
        skill_averages=skill_averages(students),
    )
