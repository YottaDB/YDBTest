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
cc -Wall -g ydbreturn_ci.c $(pkg-config --cflags yottadb) -o ydbreturn_ci $(pkg-config --libs yottadb)
ydb_routines=". $ydb_routines" ./ydbreturn_ci
```

The expected result of running this program is as follows (the platform, YottaDB version, and pid will vary)

```
long() result Expected : 10 : Actual : 10
ulong() result Expected : 25 : Actual : 25
float() result (6 digit limit) Expected : 2.23607 : Actual : 2.23607
double() result (15 digit limit) Expected : 2.23606797749979 : Actual : 2.23606797749979
char() return Expected: hello char : Actual : hello char
string() return Expected: hello string : Actual : length 12; data hello string
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
  ydb_status_t status;
  char zstatus[YDB_MAX_ERRORMSG];
  /* Open call-in table in the program's directory */

  /* All of the next block is to get the current working directory, and then get the path of the call-in table */
  /* Note that the next call only works on Linux */
  char exe_file[PATH_MAX + 1], ci_file[PATH_MAX + 1];
  char *exe_path;
  int exe_file_len, ci_file_len;
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
  ci_file_len = snprintf(ci_file, sizeof(ci_file), "%s/ydbreturn.ci", exe_path);
  if ((int)sizeof(ci_file) <= ci_file_len) {
	  fprintf(stderr, "snprintf issue");
	  return 1;
  }


  /* Open and switch to the call-in table */
  uintptr_t ci_tab_handle_new, ci_tab_handle_old;
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

  /* Run long(long i), which doubles a long number */
  ydb_long_t long_input = 5;
  ydb_long_t long_output;
  status = ydb_ci("long", &long_output, long_input);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of long with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "long() result Expected : 10 : Actual : %ld\n", long_output);

  /* Run ulong(long i), which squares a number */
  ydb_ulong_t ulong_input = 5;
  ydb_ulong_t ulong_output;
  status = ydb_ci("ulong", &ulong_output, ulong_input);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of ulong with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "ulong() result Expected : 25 : Actual : %ld\n", ulong_output);

  /* Run float(float f), which square roots a number */
  /* printf %7.5f produces 5 digits after the decimal point, 1 digit before the decimal point, total of 7 characters */
  /* YottaDB limit for C->M for floats is 6 digits. Beyond that, your data may become inaccurate. */
  /* See https://docs.yottadb.com/ProgrammersGuide/extrout.html#type-limits-for-call-ins-and-call-outs */
  ydb_float_t float_input = 5;
  ydb_float_t float_output;
  status = ydb_ci("float", &float_output, float_input);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of float with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "float() result (6 digit limit) Expected : 2.23607 : Actual : %7.5f\n", float_output);

  /* Run double(double d), which square roots a number */
  /* printf %16.14f produces 14 digits after the decimal point, 1 digit before the decimal point, total of 16 characters */
  /* YottaDB limit for C->M for double is 15 digits. Beyond that, your data may become inaccurate.*/
  /* See https://docs.yottadb.com/ProgrammersGuide/extrout.html#type-limits-for-call-ins-and-call-outs */
  ydb_double_t double_input = 5;
  ydb_double_t double_output;
  status = ydb_ci("double", &double_output, double_input);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of double with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "double() result (15 digit limit) Expected : 2.23606797749979 : Actual : %16.14f\n", double_output);

  /* Run char(ydb_char_t *c), which appends "char" to our string */
  /* Notes:
   * 1. You must pre-allocate the string before sending to YottaDB
   * 2. Allocation amount has to be greater than the expected return plus a
   * null character, with a maximum of YDB_MAX_STR + 1, which is 1MB + 1
   * 3. YDB_MAX_STR is a the max length of data that YottaDB can hold. Here, it's
   * used in malloc for illustration purposes. If you know that your return
   * value will be smaller, use that instead. In this example, most of the malloc'ed
   * space is unused. */
  ydb_char_t* char_output = ydb_malloc(YDB_MAX_STR + 1);
  status = ydb_ci("char", char_output, (ydb_char_t *)"hello ");
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of char with error: %s\n", zstatus);
	  return status;
  }
  fprintf(stdout, "char() return Expected: hello char : Actual : %s\n", char_output);
  ydb_free(char_output);

  /* Run string(ydb_string_t *s), which appends "string" to our string */
  /* Don't declare as ydb_string_t*, as we want the C runtime to put it in the stack;
   * otherwise, we have to malloc it ourselves on the heap. Something like this:
   * ydb_string_t *string_input = ydb_malloc(sizeof(ydb_string_t));*/
  ydb_string_t string_input;
  ydb_string_t string_output;

  /* ydb_string_t has a .address containing the binary blob, and a .length
   * containing the length of the data of the blob. We are intentionally omitting
   * the space for the trailing NULL in "hello ", as this data structure does not
   * use or expect that NULL.*/
  string_input.address = "hello ";
  string_input.length = 6;

  /* You must pre-allocate the string before sending to YottaDB.
   * Allocation amount has to be greater than the expected return
   * with a maximum of YDB_MAX_STR, which is 1MB. See note above on possibly
   * using a smaller length than YDB_MAX_STR.
   *
   * This part of the API is tricky. You MUST make the length larger than the
   * data you expect back. The API will change the .length down to the actual
   * length of the data returned; so that you can figure out how long your data
   * actually is. */
  string_output.address = ydb_malloc(YDB_MAX_STR);
  string_output.length = YDB_MAX_STR;

  status = ydb_ci("string", &string_output, &string_input);
  if (status != YDB_OK) {
	  ydb_zstatus(zstatus, YDB_MAX_ERRORMSG);
	  fprintf(stderr, "Failure of string with error: %s\n", zstatus);
	  return status;
  }

  fprintf(stdout, "string() return Expected: hello string : Actual : ");
  /* We cannot just print the string using %s in *printf functions, as it doesn't
   * have a null terminator; instead, we loop and print each character based on
   * the length of the data using the "%.*s" specifier */
  fprintf(stdout, "length %ld; data %.*s\n", string_output.length, (int)string_output.length, string_output.address);

  ydb_free(string_output.address);

  return 0;
}
