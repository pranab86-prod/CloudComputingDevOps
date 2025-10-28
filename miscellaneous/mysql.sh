sudo docker run --name my_postgres \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 \
  -d postgres


psql -h localhost -p 5432 -U myuser -d mydb



 
sudo docker run --name my_mysql \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=myuser \
  -e MYSQL_PASSWORD=mypassword \
  -p 3306:3306 \
  -d mysql

mysql -h 127.0.0.1 -P 3306 -u myuser -p

mysql -h localhost -P 3306 -u myuser -p
