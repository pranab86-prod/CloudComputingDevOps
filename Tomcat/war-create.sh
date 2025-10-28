mkdir sample-tomcat-app/
 cd sample-tomcat-app/
 mkdir WEB-INF/
 touch index.html
 touch WEB-INF/web.xml

cd /tmp/sample-tomcat-app/
jar cvf sample-tomcat-app.war *
sudo cp sample-tomcat-app.war /opt/tomcat/latest/webapps/
sudo chown tomcat:tomcat /opt/tomcat/latest/webapps/sample-tomcat-app.war


sudo systemctl restart tomcat
sudo tail -f /opt/tomcat/latest/logs/catalina.out


cd /opt/tomcat/latest/webapps/
http://<EC2_PUBLIC_IP>:8080/sample-tomcat-app/
================

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Registration Form</title>
    <style>
        /* Basic CSS for styling the form */
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
        }
        .container {
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
        }
        h2 {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="date"],
        select,
        textarea {
            width: calc(100% - 22px);
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        input[type="radio"],
        input[type="checkbox"] {
            margin-right: 5px;
        }
        .gender-options label {
            display: inline-block;
            margin-right: 15px;
            font-weight: normal;
        }
        button {
            background-color: #007bff;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            width: 100%;
            font-size: 16px;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Student Registration</h2>
        <form action="#" method="post">
            <div class="form-group">
                <label for="fullName">Full Name:</label>
                <input type="text" id="fullName" name="fullName" required>
            </div>

            <div class="form-group">
                <label for="email">Email Address:</label>
                <input type="email" id="email" name="email" required>
            </div>

            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="form-group">
                <label for="dob">Date of Birth:</label>
                <input type="date" id="dob" name="dob" required>
            </div>

            <div class="form-group">
                <label>Gender:</label>
                <div class="gender-options">
                    <input type="radio" id="male" name="gender" value="male" required>
                    <label for="male">Male</label>
                    <input type="radio" id="female" name="gender" value="female">
                    <label for="female">Female</label>
                    <input type="radio" id="other" name="gender" value="other">
                    <label for="other">Other</label>
                </div>
            </div>

            <div class="form-group">
                <label for="course">Select Course:</label>
                <select id="course" name="course" required>
                    <option value="">--Select a Course--</option>
                    <option value="computerScience">Computer Science</option>
                    <option value="businessAdmin">Business Administration</option>
                    <option value="engineering">Engineering</option>
                    <option value="arts">Arts</option>
                </select>
            </div>

            <div class="form-group">
                <label for="address">Address:</label>
                <textarea id="address" name="address" rows="4" required></textarea>
            </div>

            <button type="submit">Register</button>
        </form>
    </div>
</body>
</html>



==========================

<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                             http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
  <display-name>SampleTomcatApp</display-name>
</web-app>

