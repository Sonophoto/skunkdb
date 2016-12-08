# skunkdb

This is a harness for testing threading and VFS plugin development for SQLite3

This is software for POSIX/Unix/Linux/BSD terminals not Windows GUIs.

Inspired by a gist from @danielrmeyer

####Skunkdb is sponsored in part by http://modulemaster.com/rebuilds/about-us/

### Usage: 
#### 1 Clone this repo
#### 2 type `make help` in the root of the project.

-----

#### Status:
(07-Dec-2016 EoD): **Added spmemvfs from @spsoft with a BSD-2c license"

(29-Now-2016    ): **sqlite3 is available in 3 versions. Ubuntu's 3.11.0, and 3.15.1 and 3.15.2**
                   The Rationale is that we can test with latest stable and Ubuntu's always outdated system version."

(27-Nov-2016 EoD): **Added Unit Testing Macros from Sput by Alex Linke, http://www.use-strict.de/sput-unit-testing/**

(23-Nov-2016 Eod): **sqlite3 is built with PRAGMAs JSON and ENABLE_UNLOCK_NOTIFY**

(23-Nov-2016 EoD): **cli-sqlite3 is built with Linenoise, https://github.com/antirez/linenoise**

(18-Nov-2016 EoD): **BUILDS AND RUNS**

-----

#### Technical Notes:

##### SQLite3 Configurations Used:

SQLITE_ENABLE_UNLOCK_NOTIFY: https://www.sqlite.org/unlock_notify.html

##### Lock and Thread DSs and Algos

LockFree Concurrent Priority Queue: http://www.non-blocking.com/download/SunT03_PQueue_TR.pdf

C11 Atomics w/ Links to Papers: https://gcc.gnu.org/wiki/Atomic

##### Multi-Thread debugging / profiling tools and research

From github user: @blucia0a
Paper on Thread Communication Traps using Provenance Analysis of Last Writer Slices: https://github.com/blucia0a/CTraps-gcc/blob/master/paper.pdf
Repo for the CTraps-gcc thread instrumentation plugin for GNU gcc: https://github.com/blucia0a/CTraps-gcc

-----

#### Security Notes:

Notes on possibility of SQL injection attacks on loadable Sqlite3 modules: https://www.invincealabs.com/blog/2016/11/sqlite-shell-script/ 

SQLite3 Docs on Extensions: https://www.sqlite.org/c3ref/load_extension.html

-----

