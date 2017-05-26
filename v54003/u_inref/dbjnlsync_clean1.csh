#!/usr/local/bin/tcsh -f
#
# cleanterm1: 	If database is cleanly terminated, backward recovery should continue.

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#

BEGIN "Create mumps.dat database with journaling enabled:"
	setenv gtmgbldir mumps.gld
	$gtm_dist/mumps -run GDE << GDE_EOF
	change -segment DEFAULT -file=mumps.dat
GDE_EOF
	$GDE exit
	$MUPIP create
	$MUPIP set -journal=enable,on,before,file=mumps.mjl,epoch_interval=1 -reg "*"
END

BEGIN "Fill the database with data"
	$gtm_dist/mumps -direct << GTM_EOF
	for i=1:1:100000 set ^x(i)=\$j(i,10)
GTM_EOF
END

# Get the since time from the journal extract for backward recovery. 
BEGIN "Get the timestamp of fisrt epoch written to journal:"
	$MUPIP journal -extract -noverify -detail -for -fences=none mumps.mjl
	$head mumps.mjf | $grep EPOCH | $tst_awk -F "\\" '{print $2}' >&! timestamp.txt
	set ts = `cat timestamp.txt`
	$gtm_dist/mumps -direct << GTM_EOF >&! date.txt
	write \$zd("$ts","DD-MON-YEAR 24:60:SS");
GTM_EOF
	set since = `$grep "^[0-9]" date.txt`
	set before = `$grep "^[0-9]" date.txt`
END

BEGIN "Recover the data from since to before"
	echo "MUPIP journal -recover -backward -verbose -since=$since -before=$before * >&! RECOVER.log"
	$MUPIP journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" "*" >&! RECOVER.log
	$grep '%GTM-S-JNLSUCCESS, Recover successful' RECOVER.log >&! success.log
	if (! $status ) then
		echo "Recovery is successful"
	endif
END
