#!/usr/local/bin/tcsh -f

cat >> badcomp.m << EOF
badcomp	;
	goto xxxx
	write "hello"!
	do abc(1)
	set fl "banana"
	do xyz
	do lmn("x",3,"aaa")
	quit
abc	;
	quit
xyz(count)
	quit
lmn(name)
	quit
EOF
echo "# Try to list/compile file with errors"
$gtm_exe/mumps -list badcomp.m

