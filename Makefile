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

#SQLITE_VERSION = sqlite306020
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
STATIC_FLAGS = -static -c
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
CLISQLITE_FLAGS = \
-DHAVE_LINENOISE \

### Finally we set up the libraries we need to link with
MATH_LIBS = -lm

# Always put EXT_LIBS before LIBS in compiler calls so MATH_LIBS is dead last.
EXT_LIBS = \
-llinenoise \
-lsqlite
 
# BE WARY of WHICH versions of these libraries you are linking against...
# We are using the system libraries on faith
LIBS =	\
-lpthread \
-ldl \
$(MATH_LIBS)


### Define any tools we are using and flag variables
RM = rm
RMFLAGS = -f
AR = ar
ARFLAGS = rcs

#****************************************************************************
#  Targets          _                       _       
#                __| |_ __ _ _ __ __ _  ___| |_ ___ 
#                \_  __/ _` | '__/ _` |/ _ \ __/ __|
#                  | || (_| | | | (_| |  __/ |_\__ \
#                   \__\__,_|_|  \__, |\___|\__|___/
#                              |___/              
#
#****************************************************************************


# These targets are laid out explicitly to ensure everything is built
# correctly and consistently.
# The goal is to test against different build options, so NO Implicit Rules
# if mods are needed on any target they should be made OBVIOUS

all:	libsqlite3.a liblinenoise.a modmemvfs.so cli-sqlite3


#****************************************************************************
# L I B R A R Y   T A R G E T S

# On these lib targets we get the *.o as a bonus.
libsqlite3.a:  
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) $(STATIC_FLAGS) \
        $(SQLITE_VERSION)/sqlite3.c -o $(SQLITE_VERSION)/sqlite3.o \
        $(LIBS) 
	$(AR) $(ARFLAGS) $(SQLITE_VERSION)/sqlite3.a $(SQLITE_VERSION)/sqlite3.o

liblinenoise.a:  
	$(CC) $(CFLAGS) $(STATIC_FLAGS) \
        linenoise/linenoise.c -o linenoise/linenoise.o \
        $(LIBS) 
	$(AR) $(ARFLAGS) linenoise/$@ linenoise/linenoise.o

modmemvfs.so: 
	$(CC) $(CFLAGS) $(SHLIB_FLAGS) \
        modmemvfs.c -o modmemvfs.o
	$(AR) $(ARFLAGS) $@ modmemvfs.o

spmemvfs.so: 
	$(CC) $(CFLAGS) $(SHLIB_FLAGS) \
        spmemvfs.c -o spmemvfs.o
	$(AR) $(ARFLAGS) $@ spmemvfs.o

libs: sqlite3.o linenoise.o


#****************************************************************************
# P L U G I N   T A R G E T S

plugins: modmemvfs.so spmemvfs.so 


#****************************************************************************
# C L I  T A R G E T S

# This target intentionally DOES NOT use precompiled objs
cli-sqlite3:  
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) $(CLISQLITE_FLAGS) \
        linenoise/linenoise.c \
        $(SQLITE_VERSION)/sqlite3.c \
        $(SQLITE_VERSION)/shell.c \
        -o $(SQLITE_VERSION)/cli-sqlite3 \
        $(LIBS)


#****************************************************************************
# T E S T I N G   T A R G E T S

tests: test_memvfs test_modmemvfs test_spmemvfs

test_memvfs:
	# TODO  Dynamic load and run memvfs plugin
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) \
	$(SQLITE_VERSION)/sqlite3.c test_memvfs.c \
        $(LIBS) \
	-o test_memvfs 
	./test_memvfs

test_modmemvfs:	
	# TODO  Load and run modmemvfs plugin 
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) \
	$(SQLITE_VERSION)/sqlite3.c test_modmemvfs.c \
        $(LIBS) \
	-o test_modmemvfs 
	./test_modmemvfs

test_spmemvfs:
	# Static load and run spmemvfs plugin
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) \
	$(SQLITE_VERSION)/sqlite3.c spmemvfs.c test_spmemvfs.c \
        $(LIBS) \
	-o test_spmemvfs 
	./test_spmemvfs

test_concread:
	# TODO Load and run Dan's concurrent read and join code.
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) \
	$(SQLITE_VERSION)/sqlite3.c test_concread.c \
        $(LIBS) \
	-o test_concread
	$(RM) $(RMFLAGS) data.sqlite
	./generate 100000 && ./test_concread


#****************************************************************************
# M A I N T E N A N C E   T A R G E T S

# These Maintenance targets are NOT .phony: as there are dependencies ;-)
clean:
	$(RM) $(RMFLAGS) core *.bak
	$(RM) $(RMFLAGS) concurrent_read modmemvfs.so 
	$(RM) $(RMFLAGS) $(SQLITE_VERSION)/cli-sqlite3
	$(RM) $(RMFLAGS) $(SQLITE_VERSION)/sqlite3.o
	$(RM) $(RMFLAGS) $(SQLITE_VERSION)/sqlite3.a
	$(RM) $(RMFLAGS) linenoise/linenoise.o linenoise/linenoise.a

dataclean:
	$(RM) $(RMFLAGS) *.sqlite3
	$(RM) $(RMFLAGS) *.db

distclean: clean dataclean
	$(RM) $(RMFLAGS) *.a *.o *.so *.gcno *.gcda 
	$(RM) $(RMFLAGS) *.gcov 



#****************************************************************************
# U S A G E  T A R G E T 

help:
	@/bin/echo -e \
\\n\
SKUNDB: Testing System for multithreaded SQLite3\\n\
\\n\
Build Targets:\\n\
\\n\
        all: libsqlite3.a liblinenoise.a modmemvfs.so cli-sqlite3\\n\
       libs: sqlite3.o linenoise.o\\n\
    plugins: modmemvfs.so spmemvfs.so\\n\
cli-sqlite3: Builds the cli-sqlite3 command line interface\\n\
      tests: TODO: Builds and runs all tests to generate report\\n\
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
SQLITE_VERSION = sqlite315002\\n\
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

