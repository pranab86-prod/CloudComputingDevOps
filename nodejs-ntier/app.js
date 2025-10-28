const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

const db = mysql.createConnection({
  host: 'mysql',
  user: 'user',
  password: 'userpass',
  database: 'appdb'
});

db.connect(err => {
  if (err) throw err;
  console.log("MySQL Connected!");
});

// POST - Register Student
app.post('/submit', (req, res) => {
  const data = req.body;
  const sql = `
    INSERT INTO students 
    (roll_no, first_name, last_name, father_name, dob, age, mobile, email, password, gender, department, course) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

  const values = [
    data.roll_no, data.first_name, data.last_name, data.father_name, data.dob, data.age,
    data.mobile, data.email, data.password, data.gender, data.department, data.course
  ];

  db.query(sql, values, (err, result) => {
    if (err) {
      console.error("Insert Error:", err);
      res.status(500).send("Error saving data");
    } else {
      res.send("Registration successful");
    }
  });
});

// GET - List All Students
app.get('/students', (req, res) => {
  db.query('SELECT * FROM students', (err, results) => {
    if (err) {
      console.error("Read Error:", err);
      res.status(500).send("Error reading data");
    } else {
      res.json(results);
    }
  });
});

app.listen(3000, () => console.log("Server started on port 3000"));

