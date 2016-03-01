#sqlite database script to generate tables to store our data
#store id, text, x coord, and y coord
import sqlite3

filename = "./database.sqlite"
table = "message_table"
url = "URL"
x = "X"
y = "Y"
text = "Text"


#connect to database
conn = sqlite3.connect(filename)
c = conn.cursor()

#table creation
#c.execute('CREATE TABLE {tn} ({nf} {ft} PRIMARY KEY)'.format(tn = table, nf = url, ft = "INTEGER"))

#added columns
#c.execute("ALTER TABLE {tn} ADD COLUMN '{cn}' {ct}".format(tn = table, cn = x, ct = "REAL", df = 0.0))
#c.execute("ALTER TABLE {tn} ADD COLUMN '{cn}' {ct}".format(tn = table, cn = y, ct = "REAL", df = 0.0))
#c.execute("ALTER TABLE {tn} ADD COLUMN '{cn}' {ct}".format(tn = table, cn = text, ct = "TEXT", df = ""))

#commit changes and close database connection
conn.commit()
conn.close()