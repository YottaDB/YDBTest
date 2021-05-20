	; This implements a small demonstration of an API created in YottaDB that
	; can be called from a C main() program.
	;
	; No claim of copyright is made with respect to this code. YottaDB
	; supplies this code to the public domain for people to copy and paste, so
	; that's why this code is specifically excluded from copyright. This code
	; is referenced from the YDBDoc project.
	;
	; This program is only a demonstration.  Please ensure that you have a
	; correctly configured YottaDB installation.
	;
%ydbreturn	; entry points to access YottaDB
	quit
	;
long(l)	; test ydb_long_t*; double a number
	quit:$quit l*2 quit
ulong(ul) ; test ydb_ulong_t*; raise to power of 2
	quit:$quit ul**2 quit
float(f) ; test ydb_float_t* ; square root
	quit:$quit f**.5 quit
double(d) ; test ydb_double_t* ; square root
	quit:$quit d**.5 quit
char(c)	; test ydb_char_t*; concat "char"
	quit:$quit c_"char" quit
string(s) ; test ydb_string_t*; concat "string"
	quit:$quit s_"string" quit
