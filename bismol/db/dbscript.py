import rethinkdb as r

database = "messagedb"
table = "messages"

connection = r.connect("localhost", 28015)

r.db_create(database).run(connection)
r.db(database).table_create(table).run(connection)

connection.close()