#!/usr/bin/python
#
# PYTHON 2.7



import sqlite3
import os
import sys 
from itertools import cycle, product

DB_FILE = "data.sqlite3"
num_rows = 1000000 #Default, change on command line.

if len(sys.argv) > 2:
   print"Usage: ", sys.argv[0], " [num_rows]"
   sys.exit(1)

if len(sys.argv) == 2:
   num_rows = int(sys.argv[1])

if num_rows > 10000000:
   print "Warning! This operation will require ~", ((16 * num_rows)/(10 * 1024 * 1024)), " megabytes of hardrive space!"
   print "Warning! Creating ", num_rows, " records ", "will require on the order of ", (num_rows / 100000000), "gigabytes of memory!"

#else len(sys.argv) == 1:
print "Creating ", DB_FILE, " with ", num_rows, "records." 

elements = cycle(product(["name1", "name2", "name3"], [1,2,3]))

conn = sqlite3.connect(DB_FILE)
curs = conn.cursor()

curs.execute("CREATE TABLE test (name string, val integer);")
curs.executemany("INSERT INTO test (name, val) VALUES (?, ?)",
                 [next(elements) for row in range(num_rows)])
conn.commit()
curs.execute("select count(*) from test")

sys.exit(0)
