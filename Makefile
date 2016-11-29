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

#****************************************************************************
#  Documentation 
#
#     TARGETS: (Default is all)
#
#         all: shell and modmemvfs plugin
#        libs: Builds objects sqlite3.o and linenoise.o for linking
#       shell: Builds the cli-sqlite3 command line interface
#       tests: Builds and runs all tests
#       clean: Removes intermediary files, leaves binaries
#   dataclean: Removes all database files
#   distclean: Removes all generated files
#        help: Outputs usage Information
#
#****************************************************************************

### Set our default compiler
CC = gcc
#CC = clang

### Here we configure which version of C we are using:
C_ISO11P_PSR_STD = -std=c11 --pedantic -fpcc-struct-return
C_ISO99P_PSR_STD = -std=c99 --pedantic -fpcc-struct-return
C_ANSI89P_PSR_STD = -std=c89 --ansi --pedantic -fpcc-struct-return
C_GNU11_PSR_STD = -std=gnu11 -fpcc-struct-return
C_GNU99_PSR_STD = -std=gnu99 -fpcc-struct-return
C_GNU89_PSR_STD = -std=gnu89 -fpcc-struct-return

C_STANDARD = $(C_GNU99_PSR_STD)



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


### Now we build up a default set of compiler flags 
CFLAGS = \
$(GCC_FLAGS) \
$(C_STANDARD) \
$(DEFINE_FLAGS) \
$(INCLUDE_FLAGS) \


### Next we setup our SQLite3 customizations
# DSQLITE_ENABLE_JSON1        https://www.sqlite.org/json1.html
# DSQLITE_ENABLE_UNLOCK_NOTIFY https://www.sqlite.org/unlock_notify.html
SQLITE3_FLAGS = \
-DSQLITE_ENABLE_JSON1 \
-DSQLITE_ENABLE_UNLOCK_NOTIFY \

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
ECHO_APP = @echo

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
        sqlite3.c -o sqlite3.o \
        $(LIBS)
	ar rcs sqlite3.a sqlite3.o

linenoise.o:  
	$(CC) $(CFLAGS) $(SHLIB_FLAGS) \
        linenoise/linenoise.c -o linenoise/linenoise.o \
        $(LIBS)
	ar rcs linenoise/linenoise.a linenoise/linenoise.o

shell:  
	$(CC) $(CFLAGS) $(SQLITE_FLAGS) $(SHELL_FLAGS) \
        sqlite3.c shell.c linenoise/linenoise.c -o cli-sqlite3 \
        $(LIBS)

modmemvfs: 
	$(CC) $(CFLAGS) $(SHLIB_FLAGS) modmemvfs.c -o modmemvfs.so


libs: sqlite3.o linenoise.o

clean:
	$(RM) $(RM_FLAGS) core *.bak
	$(RM) $(RM_FLAGS) concurrent_read modmemvfs.so shell cli-sqlite3
	$(RM) $(RM_FLAGS) linenoise/linenoise.o linenoise/linenoise.a sqlite3.a sqlite3.o

dataclean:
	$(RM) $(RM_FLAGS) *.sqlite3
	

distclean: clean dataclean
	$(RM) $(RM_FLAGS) *.a *.o *.so *.gcno *.gcda 
	$(RM) $(RM_FLAGS) *.gcov 


tests:
	$(CC) $(CFLAGS) concurrent_read.c sqlite3.c -o concurrent_read $(LIBS)
#	$(CC) $(CFLAGS) -o skunkdb $(OBJS) $(LIBS) 

help:
	$(ECHO_APP)
	$(ECHO_APP) SKUNDB Testing System for multithreaded SQLite3
	$(ECHO_APP)
	$(ECHO_APP) Build Targets:
	$(ECHO_APP)
	$(ECHO_APP) all: shell and modmemvfs plugin
	$(ECHO_APP) libs: sqlite3.o and linenoise.o objects for linking
	$(ECHO_APP) shell: builds the cli-sqlite3 command line interface
	$(ECHO_APP) tests: Builds and runs all tests
	$(ECHO_APP)
	$(ECHO_APP) Cleaning Targets:
	$(ECHO_APP)
	$(ECHO_APP) clean: Removes intermediary files, leaves binaries
	$(ECHO_APP) dataclean: Removes all database files
	$(ECHO_APP) distclean: Removes all generated files
	$(ECHO_APP)
	$(ECHO_APP) For more info link-to:
	$(ECHO_APP)
	$(ECHO_APP) https://github.com/Sonophoto/skunkdb
	$(ECHO_APP) https://www.sqlite.org/docs.html 
	$(ECHO_APP)
	
