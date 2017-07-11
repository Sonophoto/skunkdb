# skunkdb

Test harness for multi-thread and VFS plugin development with SQLite3

### STATUS Notice: This is a BSD licensed dump of dayjob work (with full permission) without some updates or the final results. However, the conclusion was, that for dayjob's purposes, an in memory R/W sqlite3 instance was not sufficiently performant when compared with the economic reality of a significant increase in hardware cost required to fully exploit the faster access to the data.

### Sqlite3 is very fast anyway - and we use it with storage based DB files.

### To Be Sure: Our conclusion at dayjob may not be true in your use case, and it is our hope that this project dump might give you a head-start in doing whatever testing you may need to do.

This is software for POSIX/Unix/Linux/BSD terminals and is controlled via a conventional (possibly gnu) make file.

Inspired by a gist from @danielrmeyer https://gist.github.com/danielrmeyer/fae54d5993f2800626c616e72782b5eb

Skunkdb is sponsored in part by http://modulemaster.com/rebuilds/about-us/

### Usage: 
#### 1 Clone this repo
#### 2 type `make help` in the root of the project.

-----

#### Status:
(23-Dec-2016    ): **Added aditional documentaion links for POSIX interface to Multi-Processing and pthreads.h**
                   Sorting out fine details of exactly #How to implement our skunk ...and keeping notes!

(07-Dec-2016 EoD): **Added spmemvfs from @spsoft with a BSD-2c license**

(29-Now-2016    ): **sqlite3 is available in 3 versions. Ubuntu's 3.11.0, and 3.15.1 and 3.15.2**
                   The Rationale is that we can test with latest stable and Ubuntu's always outdated system version.

(27-Nov-2016 EoD): **Added Unit Testing Macros from Sput by Alex Linke, http://www.use-strict.de/sput-unit-testing/**

(23-Nov-2016 Eod): **sqlite3 is built with PRAGMAs JSON and ENABLE_UNLOCK_NOTIFY**

(23-Nov-2016 EoD): **cli-sqlite3 is built with Linenoise, https://github.com/antirez/linenoise**

(18-Nov-2016 EoD): **BUILDS AND RUNS**

-----

#### Technical Notes:

-----

##### SQLite3 Configurations Used:

SQLITE_ENABLE_UNLOCK_NOTIFY: https://www.sqlite.org/unlock_notify.html

-----

##### Lock and Thread DSs and Algos

LockFree Concurrent Priority Queue: http://www.non-blocking.com/download/SunT03_PQueue_TR.pdf

C11 Atomics w/ Links to Papers: https://gcc.gnu.org/wiki/Atomic

-----

##### Multi-Thread debugging / profiling tools and research

From github user: @blucia0a
Paper on Thread Communication Traps using Provenance Analysis of Last Writer Slices: https://github.com/blucia0a/CTraps-gcc/blob/master/paper.pdf

Repo for the CTraps-gcc thread instrumentation plugin for GNU gcc: https://github.com/blucia0a/CTraps-gcc

-----

##### Multi-Processing debugging / profiling tools and research

POSIX Specification: http://pubs.opengroup.org/onlinepubs/7908799/index.html

1) sys/mman.h: http://pubs.opengroup.org/onlinepubs/009695399/basedefs/sys/mman.h.html

2) semaphore.h: http://pubs.opengroup.org/onlinepubs/007908799/xsh/sem_init.html

3) pthreads.h: http://pubs.opengroup.org/onlinepubs/7908799/xsh/pthread.h.html

4) mutexes: http://pubs.opengroup.org/onlinepubs/007908799/xsh/pthread_mutex_lock.html

5) mqueue.h: http://pubs.opengroup.org/onlinepubs/7908799/xsh/mqueue.h.html

6) signal.h: http://pubs.opengroup.org/onlinepubs/7908799/xsh/signal.h.html

POSIX Message Queues: http://www.man7.org/tlpi/download/TLPI-52-POSIX_Message_Queues.pdf

-----

#####Comparative Documentation:

Message Queues in POSIX / SysV / SGI's IRIX: http://menehune.opt.wfu.edu/Kokua/More_SGI/007-2478-008/sgi_html/ch06.html

Mutexes in POSIX / SysV / SGI's IRIX: http://menehune.opt.wfu.edu/Kokua/More_SGI/007-2478-008/sgi_html/ch04.html

-----

#### Security Notes:

Notes on possibility of SQL injection attacks on loadable Sqlite3 modules: https://www.invincealabs.com/blog/2016/11/sqlite-shell-script/ 

SQLite3 Docs on Extensions: https://www.sqlite.org/c3ref/load_extension.html

-----

