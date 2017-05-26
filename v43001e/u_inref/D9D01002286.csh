#!/usr/local/bin/tcsh -f

#	test to verify that SET $ZRO does not cause "File Syntax error" during $ZRO load/search.

$GTM << GTM_EOF
	do lab^setzro(1000)
	do lab^setzro(10000)
	do lab^setzro(50000)
GTM_EOF
