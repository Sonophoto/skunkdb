# skunkdb

This is a Database test system for SQLite3

Essentially we are screwing around with concurrency and VFS plugins in SQLite3 

Inspired by a gist from @danielrmeyer

LockFree Concurrent Priority Queue: http://www.non-blocking.com/download/SunT03_PQueue_TR.pdf

C11 Atomics w/ Links to Papers: https://gcc.gnu.org/wiki/Atomic

Not clear yet if glibc has C11 threads yet: https://github.com/jtsiomb/c11threads

So glibc says they "conform" but the important parts of the C11 are all optional (?!?)

There is also the musl library which provided this comparrison:http://www.etalabs.net/compare_libcs.html

#Security:

Notes on possibly of SQL Injection attacks on loadable SQL modules: https://www.invincealabs.com/blog/2016/11/sqlite-shell-script/

