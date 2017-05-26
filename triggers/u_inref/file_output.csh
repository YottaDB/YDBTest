#!/usr/local/bin/tcsh -f

# file_output:
# Make sure that both error messages and the "normal" status
# messages from loading/deleting triggers can be written to a file, which
# ensures that $ztrigger output is user controllable.

$gtm_tst/com/dbcreate.csh mumps 1

cat  > t1.trg  <<TFILE
+^a() -command=SET -xecute="do ^twork"
+^a(^a(1)) -command=SET -xecute="do ^twork"
+^a(lvn) -command=SET -xecute="do ^twork"
+^a(@("blah")) -command=SET -xecute="do ^twork"
+^#t -command=SET -xecute="do ^twork"
TFILE

cat  > t2.trg  <<TFILE
+^a(1) -command=SET -xecute="do ^twork"
+^a(2) -command=SET -xecute="do ^twork"
+^a(3) -command=SET -xecute="do ^twork"
+^a(4) -command=SET -xecute="do ^twork"
+^b -command=SET -xecute="do ^twork"
TFILE

$GTM << EOF
	set sd0="t0.out"
	set sd1="t1.out"
	set sd2="t2.out"
	open sd0:newversion
	open sd1:newversion
	open sd2:newversion
	use sd0
	set a=\$ztrigger("file","/dev/null")
	set b=\$ztrigger("file","xyzzy")
	close sd0
	use sd1
	set c=\$ztrigger("file","t1.trg")
	close sd1
	use sd2
	set d=\$ztrigger("file","t2.trg")
	close sd2
	write !,a,b,c,d
EOF

echo "----------------------------------------------"
cat t2.out
echo "----------------------------------------------"
cat t1.out
echo "----------------------------------------------"
cat t0.out
echo "----------------------------------------------"

$gtm_tst/com/dbcheck.csh -extract
