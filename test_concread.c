# Copyright 2016 Daniel Meyer
# BSD2c
# See LICENSE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <sqlite3.h>

#define MAX_THREADS 100


static int callback(void *NotUsed, int argc, char **argv, char **azColName){
  int i;
  for(i=0; i<argc; i++){
    printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
  }
  printf("\n");
  return 0;
}

void *longQueryDisk(void *threadid){
  sqlite3 *db;
  char *zErrMsg = 0;
  int rc;
  char sqlQuery[] = "SELECT sum(val) from test";
  
  rc = sqlite3_open("data.sqlite3", &db);
  if( rc ){
    fprintf(stderr, "Can't open database: %s\nIn countAllDisk", sqlite3_errmsg(db));
    sqlite3_close(db);
  }

  rc = sqlite3_exec(db, sqlQuery, callback, 0, &zErrMsg);
  if( rc!=SQLITE_OK ) {
    fprintf(stderr, "SQL error: %s\n", zErrMsg);
    sqlite3_free(zErrMsg);
  }
  
  sqlite3_close(db);
  pthread_exit(NULL);
}

void *longQueryMem(void *threadid){
  sqlite3 *db;
  char *zErrMsg = 0;
  int rc;
  char sqlQuery[] = "SELECT sum(val) from test";

  rc = sqlite3_open_v2("file::memory:?cache=shared", &db, SQLITE_OPEN_URI | SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX, NULL);
  if( rc ){
    fprintf(stderr, "Can't open database: %s\nIn countAllMem\n", sqlite3_errmsg(db));
    sqlite3_free(db);
  }

  rc = sqlite3_exec(db, sqlQuery, callback, 0, &zErrMsg);
  if( rc!=SQLITE_OK ) {
    fprintf(stderr, "SQL error: %s\n", zErrMsg);
    sqlite3_free(zErrMsg);
  }
  sqlite3_close(db);
  pthread_exit(NULL);
}

sqlite3 *loadData(){
  /* load data from disk db and stick it in
     the memory db and return a pointer to the
     memory db */
  sqlite3 *db;
  char *zErrMsg = 0;
  int rc;
  char create_table_stmt[] = "CREATE TABLE test (name string, val integer)";
  char populate_mem_db[] = "ATTACH DATABASE 'data.sqlite3' as data; INSERT INTO test SELECT * from data.test";


  rc = sqlite3_open_v2("file::memory:?cache=shared", &db, SQLITE_OPEN_URI | SQLITE_OPEN_READWRITE, NULL);
  if( rc ){
    fprintf(stderr, "Can't open database: %s\nIn loadData\n", sqlite3_errmsg(db));
    sqlite3_free(db);
    exit(1);
  }

  rc = sqlite3_exec(db, create_table_stmt, 0, 0, &zErrMsg);
  if( rc!=SQLITE_OK ) {
    fprintf(stderr, "SQL error: %s\n", zErrMsg);
    sqlite3_free(zErrMsg);
  }

  rc = sqlite3_exec(db, populate_mem_db, 0, 0, &zErrMsg);
  if( rc!=SQLITE_OK ) {
    fprintf(stderr, "SQL error: %s\n", zErrMsg);
    sqlite3_free(zErrMsg);
  }

  return db;
}

int main(int argc, char **argv){
  int rc;
  int num_queries;
  pthread_t threads[MAX_THREADS];
  pthread_attr_t attr;
  void *status;
  sqlite3 *db;
  /* For testType of 0 run queries against disk file.
     For testType of 1 load database into memory and query the in memory version */
  int testType = 0;
  void *func;
  
  /* Initialize our thread attribute */
  pthread_attr_init(&attr);
  pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);
  
  /* Parse our command line arguments and check
     input is valid by printing results. */
  if( argc!=3 ){
    fprintf(stderr, "Usage: %s NUM_CONCURRENT_QUERIES DISK|MEM\n", argv[0]);
    return(1);
  }
  
  /* atoi does not handle bad input nicely so printing tells us if
     we have garbage. */
  num_queries = atoi(argv[1]);
  printf("num queries is %d\n", num_queries);

  if( strcmp(argv[2], "DISK") == 0)
    testType = 0;
  else if(strcmp(argv[2], "MEM") == 0)
    testType = 1;
  else {
    fprintf(stderr, "Usage: %s NUM_CONCURRENT_QUERIES DISK|MEM\n", argv[0]);
    return(1);
  }

  if( testType == 0 ) {
    printf("Doing DISK queries\n");
    func = longQueryDisk;
  }
  else if( testType == 1) {
    printf("Doing MEM queries\n");
    func = longQueryMem;
    db = loadData();
  }

  time_t start_time;
  time_t end_time;
  int latency;
  start_time = time(NULL);
  /* create a thread for each query we wish to start */
  for(int i = 0; i < num_queries; i++){
    rc = pthread_create(&threads[i], &attr, func, (void *)i);
    if (rc){
      fprintf(stderr, "ERROR; return code from pthread_create() is %d\n", rc);
      exit(-1);
    }
  }

  /* Join each thread with the main thread */
  pthread_attr_destroy(&attr);
  for(int i=0; i<num_queries; i++){
    rc = pthread_join(threads[i], &status);
    if (rc) {
      fprintf(stderr, "ERROR; return code from pthread_join() is %d\n", rc);
      exit(-1);
    }
    printf("Main: completed join with thread %ld with status %ld\n",i,(long)status);
  }
  end_time = time(NULL);
  latency = end_time - start_time;
  printf("Took %d sec\n", latency);
  if( testType == 0 )
    printf("Done with DISK type test\n");
  else if( testType == 1) {
    printf("Done with MEM type test\n");
    sqlite3_close(db);
  }
  
  return 0;
}
