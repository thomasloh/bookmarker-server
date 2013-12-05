# Db configurations

mode = process.env.NODE_ENV

if mode == "prod"
  db_config = {
    DB_NAME  : 'leafydb'
    DB_USER  : 'thomasloh'
    DB_PASS  : 'bookmarkmuch'
    DB_URL   : 'leafydb.cw8d91rc6nbp.us-west-2.rds.amazonaws.com'
    DB_PORT  : 5432
  }
else
  db_config = {
    DB_NAME  : if mode is "test" then "leafydb_test" else "leafydb"
    DB_USER  : 'thomasloh'
    DB_PASS  : null
    DB_URL   : 'localhost'
    DB_PORT  : 5432
  }

module.exports = db_config
