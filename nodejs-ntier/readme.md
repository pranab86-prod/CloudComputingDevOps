CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  roll_no VARCHAR(50),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  father_name VARCHAR(100),
  dob VARCHAR(20),
  age INT,
  mobile VARCHAR(15),
  email VARCHAR(100),
  password VARCHAR(100),
  gender VARCHAR(10),
  department VARCHAR(100),
  course VARCHAR(100)
);


kubectl exec -it student-backend-7f6984b794-xz9fx -- nslookup mysql

kubectl exec -it mysql -- nslookup mysql

mysql -u user -p

userpass

kubectl exec -it mysql-7d55d98784-xrjcn -- /bin/bash

===================================================================================
USE appdb;

INSERT INTO students (
  roll_no, first_name, last_name, father_name, dob, age, mobile, email, password, gender, department, course
) VALUES
('R001', 'John', 'Doe', 'Michael Doe', '2000-01-15', 24, '9876543210', 'john.doe@example.com', 'pass123', 'Male', 'Computer Science', 'B.Tech'),
('R002', 'Jane', 'Smith', 'Robert Smith', '1999-07-20', 25, '9123456780', 'jane.smith@example.com', 'pass456', 'Female', 'Electronics', 'B.E'),
('R003', 'Amit', 'Kumar', 'Rajesh Kumar', '2001-03-05', 23, '9012345678', 'amit.k@example.com', 'pass789', 'Male', 'Mechanical', 'B.Tech');


===================================================================

POST http://aa54f2049b69d4c739f03cb73b2446a2-1859996237.us-west-2.elb.amazonaws.com/submit
Content-Type: application/json
Body:
{
  "roll_no": "R004",
  "first_name": "Neha",
  "last_name": "Verma",
  "father_name": "Raj Verma",
  "dob": "2002-10-12",
  "age": 22,
  "mobile": "9988776655",
  "email": "neha@example.com",
  "password": "securepass",
  "gender": "Female",
  "department": "IT",
  "course": "B.Sc"
}
