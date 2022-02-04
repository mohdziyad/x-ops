import os

dbuser = os.environ['DB_USER']
dbhost = os.environ['DB_HOST']
dbname = os.environ['DB_NAME']
dbpwd  = os.environ['DB_PASSWORD']

DB = {
    "name": dbname,
    "user": dbuser,
    "host": dbhost,
    "pwd": dbpwd
}
