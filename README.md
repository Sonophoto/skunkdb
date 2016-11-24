# skunkdb

####Skunkdb is sponsored in part by http://modulemaster.com/rebuilds/about-us/



####Status 
(23-Nov-2016 Eod): **sqlite3 is built with JSON and ENABLE_UNLOCK_NOTIFY**

(23-Nov-2016 EoD): **cli-sqlite3 is built with antirez/linenoise**

(18-Nov-2016 EoD): **BUILDS AND RUNS**
-----

Essentially we are testing concurrency and VFS plugins in SQLite3 

Inspired by a gist from @danielrmeyer

-----

####Technical Notes

SQLITE_ENABLE_UNLOCK_NOTIFY: https://www.sqlite.org/unlock_notify.html

LockFree Concurrent Priority Queue: http://www.non-blocking.com/download/SunT03_PQueue_TR.pdf

C11 Atomics w/ Links to Papers: https://gcc.gnu.org/wiki/Atomic

Not clear yet if glibc has C11 threads yet: https://github.com/jtsiomb/c11threads

So glibc says they "conform" but the important parts of the C11 are all optional (?!?)

There is also the musl library which provided this comparrison:http://www.etalabs.net/compare_libcs.html

-----

####Security Notes:

Notes on possibly of SQL Injection attacks on loadable SQL modules: https://www.invincealabs.com/blog/2016/11/sqlite-shell-script/ SQLite3 Docs on Extensions: https://www.sqlite.org/c3ref/load_extension.html



