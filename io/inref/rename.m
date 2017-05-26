rename; Test the deviceparameter RENAME
        set file="rename.txt"
        set filed="renamed.txt"
        set s1=$ZSEARCH(file)
        set sd1=$ZSEARCH(filed)
        open file:(NEWVERSION)
        use file
        write "BLAH",!
        set s2=$ZSEARCH(file)
        set sd2=$ZSEARCH(filed)
	; on unix first try to rename file to itself to force the exception.  The exception then changes tfile to filed which
        ; will succeed.
	; on OpenVMS there are rename and file permission issues described in GTM-7036 so the exception is 
	; not forced there currently.
	if $ZVERSION'["VMS" do
	. set tfile=file
	. close file:(RENAME=tfile:EXCEPTION="use $p write ""expect this message in attempt to rename to self then a PASS"",! set tfile=filed use file")
	else  close file:(RENAME=filed)
        use $PRINCIPAL
        set s3=$ZSEARCH(file)
        set sd3=$ZSEARCH(filed)
	set pass=0
	if ""=s1,""=s3,""'=s2 set pass=1
	if ""=sd1,""'=sd3,""=sd2 set pass=1
	if 1=pass write "PASS",!
        else  write "FAIL",! zwr
	open filed
	use filed
	do readfile^filop(filed,0)
        q

