/*
This program is a driver to demonstrate a C main() program that calls in to YottaDB M code.

No claim of copyright is made with respect to this code. YottaDB
supplies this code to the public domain for people to copy and paste, so
that's why this code is specifically excluded from copyright. This code is
referenced from the YDBDoc project.

Compile it and run it on bash like this:
```
source `pkg-config --variable=prefix yottadb`/ydb_env_unset
export ydb_dir=$PWD/db
source `pkg-config --variable=prefix yottadb`/ydb_env_set
cc -Wall -g ydbaccess_ci.c $(pkg-config --cflags yottadb) -o ydbaccess_ci $(pkg-config --libs yottadb)
ydb_routines=". $ydb_routines" ./ydbaccess_ci
```

The expected result of running this program is as follows (the platform, YottaDB version, and pid will vary)

```
Washington, DC
England
United States
^Capital("United States")
---------------------------------
YottaDB r1.30 Linux x86_64
MLG:1,MLT:0
LOCK ^CIDemo(4810) LEVEL=1
ydbxecute2 Expected failure: [150373210,xecute+2^%ydbaccess,%YDB-E-DIVZERO, Attempt to divide by zero]
```

This program is intended to call functionality implemented in M. For access to
YottaDB global variables from C code, you should use the C API instead;
see https://docs.yottadb.com/MultiLangProgGuide/cprogram.html

*/

#include <stdio.h>  //printf, fprintf
#include <unistd.h> //readlink
#include <limits.h> //PATH_MAX
#include <libgen.h> //dirname
#include "libyottadb.h" //All ydb* functions

int main() {
  char exe_file[PATH_MAX + 1], ci_file[PATH_MAX + 1];
  char *exe_path;
  uintptr_t ci_tab_handle_new, ci_tab_handle_old;
  int status, i, exe_file_len, ci_file_len;
  ydb_string_t p_value;
  char xecute_error[YDB_MAX_ERRORMSG], zstatus[YDB_MAX_ERRORMSG], value[YDB_MAX_STR];

  /* Ensure required environment variables are set.
     PLEASE NOTE - This is only a demonstration program.  You will almost certainly want
     other environment variables to be defined in a production environment.
  */
  if ((NULL == getenv("ydb_dist")) || (NULL == getenv("ydb_gbldir")) || (NULL == getenv("ydb_routines"))) {
	  fprintf(stderr, "Either $ydb_dist, $ydb_gbldir, $ydb_routines is not appropriately set");
	  return 1;
  }

  /* Open call-in table in the program's directory */

  /* All of the next block is to get the current working directory, and then get the path of the call-in table */
  /* Note that the next call only works on Linux */
  exe_file_len = readlink("/proc/self/exe", exe_file, sizeof(exe_file));
  if ((-1 == exe_file_len) || (exe_file_len >= sizeof(exe_file))) {
	  fprintf(stderr, "Error in readlink(/proc/self/exe) call");
	  return 1;
  }
  exe_file[exe_file_len] = '\0'; // readlink() doesn't add a null terminator per man page
  exe_path = dirname(exe_file);
  if (NULL == exe_path) {
	  fprintf(stderr, "Problem with exe_path");
	  return 1;
  }
  ci_file_len = snprintf(ci_file, sizeof(ci_file), "%s/ydbaccess.ci", exe_path);
  if ((int)sizeof(ci_file) <= ci_file_len) {
	  fprintf(stderr, "snprintf issue");
	  return 1;
  }

  /* Open and switch to the call-in table */
  status = ydb_ci_tab_open(ci_file, &ci_tab_handle_new);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of ydb_ci_tab_open with error: %s\n", zstatus);
	  return status;
  }
  status = ydb_ci_tab_switch(ci_tab_handle_new, &ci_tab_handle_old);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of ydb_ci_tab_switch with error: %s\n", zstatus);
	  return status;
  }

  /* Initialization - string constants */
  char washington[] = "Washington, DC";
  char london[] = "London";

  /* Set a node - note that value can be an arbitrary blob, not just a null terminated string */
  p_value.address = (char *) &washington;
  p_value.length = strlen(washington);
  status = ydb_ci("set", "^Capital(\"United States\")", &p_value);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of set1 with error: %s\n", zstatus);
	  return status;
  }

  /* Set another node */
  p_value.address = (char *) &london;
  p_value.length = strlen(london);
  status = ydb_ci("set", "^Capital(\"England\")", &p_value);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of set2 with error: %s\n", zstatus);
	  return status;
  }

  /* Get the node first set & print it */
  p_value.address = (char *) &value;
  p_value.length = YDB_MAX_STR;
  status = ydb_ci("get", "^Capital(\"United States\")", &p_value);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of get with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "%.*s\n", (int)p_value.length, p_value.address);

  /* Ordering through subscripts - first subscript */
  p_value.address = (char *) &value;
  p_value.length = YDB_MAX_STR;
  status = ydb_ci("order", "^Capital(\"\")", &p_value);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of order1 with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "%.*s\n", (int)p_value.length, p_value.address);

  /* Ordering through subscripts - next subscript */
  p_value.address = (char *) &value;
  p_value.length = YDB_MAX_STR;
  status = ydb_ci("order", "^Capital(\"England\")", &p_value);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of order2 with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "%.*s\n", (int)p_value.length, p_value.address);

  /* Ordering through nodes - next node */
  p_value.address = (char *) &value;
  p_value.length = YDB_MAX_STR;
  status = ydb_ci("query", "^Capital(\"England\")", &p_value);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of query with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "%.*s\n", (int)p_value.length, p_value.address);

  /* Kill a (sub)tree */
  status = ydb_ci("kill", "^Capital");
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of kill with error: %s\n", zstatus);
	  return status;
  }

  /* Lock a node */
  status = ydb_ci("lock", "+^CIDemo($Job)");
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of lock with error: %s\n", zstatus);
	  return status;
  }


  /* Xecute a string */
  fprintf(stdout, "---------------------------------\n");
  status = ydb_ci("xecute", "write $zyrelease,! zshow \"l\"", &xecute_error );
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of xecute1 with error: %s\n", zstatus);
	  return status;
  }
  if (0 != strlen( xecute_error )) {
	  fprintf( stdout, "xecute1 failure: [%s]\n", xecute_error);
  }

  /* force an error in Xecute*/
  status = ydb_ci("xecute", "write 1/0", &xecute_error );
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of xecute2 with error: %s\n", zstatus);
	  return status;
  }
  if (0 != strlen( xecute_error ))
	  fprintf( stdout, "xecute2 Expected failure: [%s]\n", xecute_error);

  return 0;
}
