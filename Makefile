#****************************************************************************
#
#    GNU/       __  __       _         __ _ _      
#      /gmake  |  \/  | __ _| | _____ / _(_) | ___ 
#     /        | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
#    /BSD-2c   | |  | | (_| |   <  __/  _| | |  __/
#              |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
#
#                           SKUNKDB
#
#   FILENAME: Makefile  AUTHOR: "Brig Young" 
#   COPYRIGHT: "2016 Brig Young" LICENSE: "BSD-2c, see LICENSE"         
#   PURPOSE: "Make, Build, Test and Maintain skunkdb"               
#
#                This file probably requires GNU gmake.
#****************************************************************************
SHELL = /bin/sh
.SUFFIXES:

#****************************************************************************
#  Documentation: See 'help' target or type 'make help' 
#****************************************************************************

### First we choose a version of Sqlite3 by its directory name.
### We then include only the directory with that version
### Version number is from SQLITE_VERSION_NUMBER in sqlite3.h

#SQLITE_VERSION = sqlite311000
#SQLITE_VERSION = sqlite315001
SQLITE_VERSION = sqlite315002

### Next we setup our SQLite3 customizations
# DSQLITE_ENABLE_JSON1         https://www.sqlite.org/json1.html
# DSQLITE_ENABLE_UNLOCK_NOTIFY https://www.sqlite.org/unlock_notify.html
SQLITE3_FLAGS = \
-DSQLITE_ENABLE_JSON1 \
-DSQLITE_ENABLE_UNLOCK_NOTIFY \

### Here we configure which version of C we are using:
C_ISO11P_PSR_STD = -std=c11 --pedantic -fpcc-struct-return
C_ISO99P_PSR_STD = -std=c99 --pedantic -fpcc-struct-return
C_ANSI89P_PSR_STD = -std=c89 --ansi --pedantic -fpcc-struct-return
C_GNU11_PSR_STD = -std=gnu11 -fpcc-struct-return
C_GNU99_PSR_STD = -std=gnu99 -fpcc-struct-return
C_GNU89_PSR_STD = -std=gnu89 -fpcc-struct-return

C_STANDARD = $(C_GNU99_PSR_STD)

### Set our default compiler
CC = gcc

### Next we configure build options for the compiler:
GCC_DW_FLAGS = -g -Wall
GCC_DWCOVER_FLAGS = -g -Wall -fprofile-arcs -ftest-coverage 

GCC_FLAGS = $(GCC_DW_FLAGS)

### Build Flags for Static and Loadable
STATIC_FLAGS = -static 
SHLIB_FLAGS = -fPIC -shared

### Now we add in all of our -Ds
DEFINE_FLAGS = \
-DSTDC_HEADERS=1 \
-DHAVE_UNISTD_H=1 \

### Now we add in all of our -Is
INCLUDE_FLAGS = \
-I. \
-Ilinenoise \
-I$(SQLITE_VERSION) \

### Now we build up a default set of compiler flags 
CFLAGS = \
$(GCC_FLAGS) \
$(C_STANDARD) \
$(DEFINE_FLAGS) \
$(INCLUDE_FLAGS) \

### Then our shell customizations
#NOTE: Linenoise: We name the C file on the gcc command line, no obj.
SHELL_FLAGS = \
-DHAVE_LINENOISE \

### Finally we set up the libraries we need to link with
MATH_LIBS = -lm

LIBS =	\
-lpthread \
-ldl \
$(MATH_LIBS)

### Define any tools we are using and flag variables
RM = rm
RM_FLAGS = -f
AR = ar
AR_FLAGS = rcs

#****************************************************************************
#  Targets          _                       _       
#                __| |_ __ _ _ __ __ _  ___| |_ ___ 
#                \_  __/ _` | '__/ _` |/ _ \ __/ __|
#                  | || (_| | | | (_| |  __/ |_\__ \
#                   \__\__,_|_|  \__, |\___|\__|___/
#                              |___/              
#
#****************************************************************************

all:	shell modmemvfs 

sqlite3.o:  
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) $(SHLIB_FLAGS) \
        $(SQLITE_VERSION)/sqlite3.c -o $(SQLITE_VERSION)/sqlite3.o \
        $(LIBS)
	$(AR) $(AR_FLAGS)$(SQLITE_VERSION)/sqlite3.a $(SQLITE_VERSION)/sqlite3.o

linenoise.o:  
	$(CC) $(CFLAGS) $(SHLIB_FLAGS) \
        linenoise/linenoise.c -o linenoise/linenoise.o \
        $(LIBS)
	$(AR) $(AR_FLAGS) linenoise/linenoise.a linenoise/linenoise.o

shell:  
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) $(SHELL_FLAGS) \
        linenoise/linenoise.c \
        $(SQLITE_VERSION)/sqlite3.c \
        $(SQLITE_VERSION)/shell.c \
        -o $(SQLITE_VERSION)/cli-sqlite3 \
        $(LIBS)

modmemvfs: 
	$(CC) $(CFLAGS) $(SHLIB_FLAGS) \
        modmemvfs.c -o modmemvfs.o
	$(AR) $(AR_FLAGS) modmemvfs.so modmemvfs.o

libs: sqlite3.o linenoise.o

clean:
	$(RM) $(RM_FLAGS) core *.bak
	$(RM) $(RM_FLAGS) concurrent_read modmemvfs.so 
	$(RM) $(RM_FLAGS) $(SQLITE_VERSION)/cli-sqlite3
	$(RM) $(RM_FLAGS) $(SQLITE_VERSION)/sqlite3.o
	$(RM) $(RM_FLAGS) $(SQLITE_VERSION)/sqlite3.a
	$(RM) $(RM_FLAGS) linenoise/linenoise.o linenoise/linenoise.a

dataclean:
	$(RM) $(RM_FLAGS) *.sqlite3
	

distclean: clean dataclean
	$(RM) $(RM_FLAGS) *.a *.o *.so *.gcno *.gcda 
	$(RM) $(RM_FLAGS) *.gcov 


tests:
	$(CC) $(CFLAGS) concurrent_read.c sqlite3.c -o concurrent_read $(LIBS)
#	$(CC) $(CFLAGS) -o skunkdb $(OBJS) $(LIBS) 

help:
	@/bin/echo -e \
\\n\
SKUNDB Testing System for multithreaded SQLite3\\n\
\\n\
Build Targets:\\n\
\\n\
      all: shell and modmemvfs plugin\\n\
     libs: sqlite3.o and linenoise.o objects for linking\\n\
    shell: builds the cli-sqlite3 command line interface\\n\
modmemvfs: builds only the modmemvfs.so plugin\\n\
    tests: Builds and runs all tests\\n\
\\n\
Cleaning Targets:\\n\
\\n\
    clean: Removes intermediary files, leaves binaries\\n\
dataclean: Removes all database files\\n\
distclean: Removes all generated files\\n\
\\n\
\\n\
Users Make Variables: \(defaults listed first\)\\n\
 these can be set on the command line e.g.:\\n\
 make SQLITE_VERSION=sqlite311000 [target]\\n\
\\n\
SQLITE_VERSION = sqlite315002 \\n\
 sqlite311000 \(ubuntu\)\\n\
 sqlite315001\\n\
\\n\
C_STANDARD = C_GNU99_PSR_STD\\n\
 C_GNU99_PSR_STD = $(C_GNU99_PSR_STD)\\n\
 C_GNU89_PSR_STD = $(C_GNU89_PSR_STD)\\n\
 C_GNU11_PSR_STD = $(C_GNU11_PSR_STD)\\n\
 C_ANSI89P_PSR_STD = $(C_ANSI89P_PSR_STD)\\n\
 C_ISO99P_PSR_STD = $(C_ISO99P_PSR_STD)\\n\
 C_ISO11P_PSR_STD = $(C_ISO11P_PSR_STD)\\n\
\\n\
For more info link-to:\\n\
 https://github.com/Sonophoto/skunkdb\\n\
 https://www.sqlite.org/docs.html\\n\
\\n

