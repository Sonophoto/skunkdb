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
#     TARGETS: (Default is  skunkdb)
#
#         all: Depends on skunkdb and sqlite
#     skunkdb: Builds the skunkdb plugin 
#      sqlite: Builds the sqlite library and CLI 
#        test: Builds and runs all tests with PASS|FAIL output
#       clean: Removes intermediary files leaves binaries
#   distclean: Removes intermediarries and output files
#
#****************************************************************************
# Dan's Original gcc call on the concurrency test:
# gcc -std=gnu99 test.c -o test -lsqlite3 -lpthread 

### Set our default compiler
CC = gcc


### Here we configure which version of C we are using:
C_ISO11P_PSR_STD = -std=c11 --pedantic -fpcc-struct-return
C_ISO99P_PSR_STD = -std=c99 --pedantic -fpcc-struct-return
C_ANSI89_PSR_STD = -std=c89 --ansi --pedantic -fpcc-struct-return
C_GNU11P_PSR_STD = -std=g11 -fpcc-struct-return
C_GNU99P_PSR_STD = -std=g99 -fpcc-struct-return
C_GNUANSI_PSR_STD = -std=g89 -fpcc-struct-return

C_STANDARD = $(C_ISO99P_PSR_STD)


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
-I.

### Now we build up a default set of compiler flags 
CFLAGS = \
$(GCC_FLAGS) \
$(C_STANDARD) \
$(DEFINE_FLAGS) \
$(INCLUDE_FLAGS) \

### Finally we set up the libraries we need to link with
MATH_LIBS = -lm

LIBS =	\
-lpthread \
$(MATH_LIBS)


### Define any tools we are using and flag variables
RM = rm
RM_FLAGS = -f


#****************************************************************************
#  Targets          _                       _       
#                __| |_ __ _ _ __ __ _  ___| |_ ___ 
#                \_  __/ _` | '__/ _` |/ _ \ __/ __|
#                  | || (_| | | | (_| |  __/ |_\__ \
#                   \__\__,_|_|  \__, |\___|\__|___/
#                              |___/              
#
#****************************************************************************

### TODO BUGBUG Targets are NOT correctly set-up, I'm not sure how exactly we want to build this...
all:	sqlite3 modmemvfs skunkdb threadtest

sqlite3: 
	$(CC) $(CFLAGS) $(SHLIB_FLAGS) sqlite3.c -o sqlite3.o

modmemvfs:
	$(CC) $(CFLAGS) $(SHLIB_FLAGS) modmemvfs.c sqlite3.o -o modmemvfs.so 

skunkdb: sqlite3.o
#	$(CC) $(CFLAGS) -o skunkdb $(OBJS) $(LIBS) 

threadtest: 
	$(CC) $(CFLAGS) concurrent_read.c -o concurrent_read 

clean:
	$(RM) $(RM_FLAGS) core *.bak
	$(RM) $(RM_FLAGS) concurrent_read modmemvfs.so sqlite3.o


distclean: clean
	$(RM) $(RM_FLAGS) data.sqlite3 
	$(RM) $(RM_FLAGS) *.a *.o *.so *.gcno *.gcda skunkdb tests
	$(RM) $(RM_FLAGS) # Coverage and browsing files


testing:
#	$(CC) $(CFLAGS) -o skunkdb $(OBJS) $(LIBS) 

