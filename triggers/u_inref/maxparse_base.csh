#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test throws the maximum values for the individual components
# of a trigger at the trigger parsing commands.  Three DB sizes
# are used, the default, a "medium" size which takes half the size
# of maximum values and a "large" db size that takes the maximum
# of all relevant size values.
#
# Relevant sizes are:
# Key size
# Record size
# Block size (which is always > Key Size + Record Size)
#
# 8. MAXIMUMS
# numers and lettering are left overs from the original trigger testplan
# you can safely ignore these inscrutable items

cp $gtm_tst/$tst/outref/longline_mutrigfile.txt longline_mutrigfile.txt

cat > maxrtn.m << MPROG
maxrtn
	zshow "s"
MPROG
$convert_to_gtm_chset maxrtn.m
$echoline

# a. 31 subscripts
cat > thirtyonesubs.m << FILE
thirtyonesubs
	write "Testing triggers with 31 and more subscripts",!
	; this test creates two test cases
	;  1. trigger with 31 subscripts which passes
	;  2. trigger with 32 subscripts with does not pass
	;
	; expect PASS
	for i=1:1:31 set \$piece(subs,",",i)=":"
	set file="maxsubs.trg"
	open file:newversion
	use file
	write "+^bmaxcolon("_subs_") -commands=set -xecute=""do ^maxrtn"" ",!
	close file
	use \$p
	if \$ztrigger("item","+^bmaxcolon("_subs_") -commands=set -xecute=""do ^maxrtn"" ")  write "PASS",!
	set x=\$ztrigger("item","-^bmaxcolon("_subs_") -commands=set -xecute=""do ^maxrtn"" ")
	;
	; expect ztrigger to fail, PASS on failure
	set \$piece(subs,",",32)=":"
	set file="overmaxsubs.trg"
	open file:newversion
	use file
	write "+^bovermaxcolon("_subs_") -commands=set -xecute=""do ^maxrtn"" ",!
	close file
	use \$p
	if '\$ztrigger("item","+^bovermaxcolon("_subs_") -commands=set -xecute=""do ^maxrtn"" ")  write "PASS",!
	quit
FILE
$convert_to_gtm_chset thirtyonesubs.m
$gtm_exe/mumps -run thirtyonesubs
$echoline

# b. 8k worth of subscripts
$gtm_exe/mumps -run maxsubslen
$echoline

# c. 32k for the entire trigger line
# d. max # of pieces - the max length for the pieces string is 32k, same as the line limit
echo "Testing LONG lines"
$gtm_exe/mumps -run longline
$gtm_exe/mumps -run script^longline
chmod u+x ztrig.csh

echo "Load with mupip trigger and ztrigger by file"
$gtm_exe/mupip trigger -trig=longline.trg >&! mll.logx
diff mll.logx longline_mutrigfile.txt | $grep -E '^(<|>)' | cut -b 1-120
$echoline
$gtm_exe/mumps -run %XCMD 'set x=$ztrigger("file","longline.trg")' >&! zll.logx
diff mll.logx zll.logx | $grep -E '^(<|>)' | cut -b 1-120
$echoline
echo "Load with ztrigger in one big M program and individual M programs"
# there should be no unexpected result in the logx files
ztrig.csh >&! ztrind.logx
$grep 'Unexpected result' ztrind.logx
$gtm_exe/mumps -run item^longline >&! ztraio.logx
$grep 'Unexpected result' ztraio.logx
diff ztrind.logx ztraio.logx | $grep -E '^(<|>)' | cut -b 1-120
$echoline

# e. max global variable name 31 chars
cat > maxgvnlen.m << FILE
	write "Testing triggers with GVN 28,31 characters and longer",!
	;
	; create the long GVNs
	set gvn=""
	for i=1:1:28 set gvn=gvn_\$char(65+(i#26))
	set gvn28=gvn
	for i=29:1:31 set gvn=gvn_\$char(65+(i#26))
	set gvn31=gvn
	set gvn32="o"_gvn
	for i=32:1:40 set gvn=gvn_\$char(65+(i#26))
	set gvn40="o"_gvn
	;
	; write the lengths that are under the 31 char limit
	; its worth noting that 31 char GVNs are truncated to 28 char trigger names
	set file="maxgvnlength.trg"
	open file:newversion
	use file
	write "+^"_gvn28_" -command=S -xecute=""do ^maxrtn""",!
	write "+^"_gvn31_" -command=S -xecute=""do ^maxrtn""",!
	close file
	;
	; write the lengths that exceed the max GVN length. these PASS, but get silently truncated
	set file="overmaxgvnlength.trg"
	open file:newversion
	use file
	write "+^"_gvn32_" -command=S -xecute=""do ^maxrtn""",!
	write "+^"_gvn40_" -command=S -xecute=""do ^maxrtn""",!
	close file
	use \$p
	write "28 and 31 character GVNs which overlap to the same trigger name",!
	if \$ztrigger("item","+^"_gvn28_" -command=S -xecute=""do ^maxrtn""") write "PASS",!
	if \$ztrigger("item","+^"_gvn31_" -command=S -xecute=""do ^maxrtn""") write "PASS",!
	set x=\$ztrigger("select")
	write !,"32+ character GVNs which overlap to the same trigger name",!
	if \$ztrigger("item","+^"_gvn32_" -command=S -xecute=""do ^maxrtn""") write "PASS",!
	if \$ztrigger("item","+^"_gvn40_" -command=S -xecute=""do ^maxrtn""") write "PASS",!
	set x=\$ztrigger("select")
	write !
FILE
$convert_to_gtm_chset maxgvnlen.m
$gtm_exe/mumps -run maxgvnlen
$echoline


# f. max delim length 1022
cat > maxdelim.m << FILE
maxdelim
	; build the delimiter string once
	set delimiter=\$translate(\$justify("",1023)," ","x")
	;
	; truncate the delimiter string down to 1022 for the test
	set delim=\$char(34)_\$extract(delimiter,1,1022)_\$char(34)
	set file="maxdelim.trg" open file:newversion use file
	write "+^cmaxdelim -commands=set -xecute=""do ^maxrtn"" -piece=1 -delim="_delim,!
	close file
	;
	;
	; use the 1023 delimiter string which should fail
	set delim=\$char(34)_delimiter_\$char(34)
	set file="overmaxdelim.trg" open file:newversion use file
	write "+^cmaxdelimover -commands=set -xecute=""do ^maxrtn"" -piece=1 -delim="_delim,!
	close file
	quit
ztr
	; build the delimiter string once
	set delimiter=\$translate(\$justify("",1026)," ","x")
	;
	write "Run the max delimiter test with ztrigger",!
	for i=1000:1:1026 do
	.	set delim=\$char(34)_\$extract(delimiter,1,i)_\$char(34)
	.	write "For delimiter of length ",(\$length(delim)-2),\$char(9)
	.	if \$ztrigger("item","+^cmaxdelim -commands=set -xecute=""do ^maxrtn"" -piece=1 -delim="_delim) write "PASS",!
	.	else  write "FAIL",!
	quit
FILE
$convert_to_gtm_chset maxdelim.m
$gtm_exe/mumps -run maxdelim


# h. max trigger name length is 28 characters
cat > maxname.trg << TFILE
; 28 char name	write "^a -command=S -xecute=""do ^maxrtn"" -name=" for i=1:1:28 write \$char(65)
+^a -command=S -xecute="do ^maxrtn" -name=AAAAAAAAAAAAAAAAAAAAAAAAAAAA
TFILE
$convert_to_gtm_chset maxname.trg

cat > overmaxname.trg << TFILE
; 29 char name	write "+^b -command=S -xecute=""do ^maxrtn"" -name=" for i=1:1:29 write \$char(65)
+^b -command=S -xecute="do ^maxrtn" -name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAA

; 100 char name	write "^c -command=S -xecute=""do ^maxrtn"" -name=" for i=1:1:100 write \$char(65)
+^c -command=S -xecute="do ^maxrtn" -name=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
TFILE
$convert_to_gtm_chset overmaxname.trg

# i. max triggers on a GVN is 1 million minus 1
# see maxnames

# a. 31 subscripts
echo ""
echo "Test maximum number of subscripts"
$load maxsubs.trg PASS
$load overmaxsubs.trg FAIL
$tail -n 1 overmaxsubs.trg.trigout
echo ""
$echoline

# b. 8k worth of subscripts (minus quotes is 8190)
# These fail after parsing
echo "Test maximum length of subscripts"
echo "ztrigger first"
$gtm_exe/mumps -run ztrmain^maxsubslen

$gtm_exe/mumps -run ztrvalidate^maxsubslen
# you can reproduce the above test by hand with
# $head -n2 ztrtest.trg | $tail -n 1 | wc -c
# $head -n6 ztrtest.select | $tail -n 1 | wc -c

$drop
echo "now mupip trigger"
$load maxsubslen.trg PASS
$load overmaxsubslen.trg FAIL
$head -n 1 overmaxsubslen.trg.trigout
echo ""
$echoline

# e. max global variable name 31 chars
echo "Test maximum gvn length"
$load maxgvnlength.trg PASS
$load overmaxgvnlength.trg PASS
$grep "Warning" overmaxgvnlength.trg.trigout
$show | cut -b 1-80
echo ""
$echoline

# f. max delim length 1024 (minus quotes is 1022)
echo "Test maximum delimiter length"
$load maxdelim.trg PASS
$load overmaxdelim.trg FAIL
$head -n 1 overmaxdelim.trg.trigout
$echoline
echo "Run the ztr^maxdelim test twice because that produced a core once upon a time"

$gtm_exe/mumps -run ztr^maxdelim >&! ztrmaxdelim_r1.logx
$grep 'max record size' ztrmaxdelim_r1.logx
$grep 'rigger ' ztrmaxdelim_r1.logx
echo "Number of 'Entry too large to properly index' errors `$grep -c 'Entry too large to properly index' ztrmaxdelim_r1.logx`"
$grep 'Delimiter too long' ztrmaxdelim_r1.logx
$echoline

$gtm_exe/mumps -run ztr^maxdelim >&! ztrmaxdelim_r2.logx
$grep 'max record size' ztrmaxdelim_r2.logx
$grep added ztrmaxdelim_r2.logx
echo "Number of 'Entry too large to properly index' errors `$grep -c 'Entry too large to properly index' ztrmaxdelim_r2.logx`"
$grep 'Delimiter too long' ztrmaxdelim_r2.logx
$echoline
echo ""
$echoline

# h. max trigger name length is 28 characters
echo "Test maximum trigger name length"
$load maxname.trg PASS
$load overmaxname.trg FAIL
$head -n 4 overmaxname.trg.trigout
echo ""
$echoline

# c. 32k for the entire trigger line
# d. max # of pieces : whatever the line can hold, but the max # is 32k
echo "Test maximum trigger lines"
$gtm_exe/mumps $gtm_tst/$tst/inref/maxline.m
$gtm_exe/mumps -run maxline >&! maxline.out
cut -b 1-120 maxline.out
$echoline

$load maxline.trg PASS
$head -n1 maxline.trg.trigout
$load maxline32.trg PASS
$head -n1 maxline32.trg.trigout
$load maxline64.trg FAIL
$head -n1 maxline64.trg.trigout | cut -b 1-120

echo ""
$echoline

echo "Reload Test"
$show show_all.trg
sed 's/^+/-/' show_all.trg > show_allm.trg
$load show_allm.trg
$tail -n 5 show_allm.trg.trigout
$echoline
