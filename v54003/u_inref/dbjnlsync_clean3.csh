#!/usr/local/bin/tcsh -f
#
# cleanterm3:  Clean database termination but (jfh->eov_tn < db->curr_tn)	

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

#TEST BEGINS#

BEGIN "Create mumps.dat database with journaling enabled"
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

# take copy of mumps.dat and mumps.mjl to mumps.dat_bkup and mumps.mjl_bkup respectively
cp mumps.dat mumps.dat_bkup
cp mumps.mjl mumps.mjl_bkup

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

BEGIN "Database contains data"
	$gtm_dist/mumps -direct << GTM_EOF
	write "Access to ^x(100000) should be successful"
	write "write ^x(100000)"
	write ^x(100000)
GTM_EOF
END

BEGIN "Recover the database somewhere before current state"
	echo "$MUPIP journal -recover -backward -verbose -since=$since -before=$before * >&! RECOVER.log"
	$MUPIP journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" "*" >&! RECOVER.log
END

BEGIN "Get the eov from journal file header"
	$MUPIP journal -show=header -backward mumps.mjl >&! jnlheader.txt
	set eov_tn = `$grep "End Transaction" jnlheader.txt | $tst_awk -F '[' '{print $2}' | $tst_awk -F ']' '{print $1}'`
END

#resotre mumps.dat_bkup to mumps.dat which will cause jfh->eov_tn > db->curr_tn
cp mumps.dat_bkup mumps.dat

BEGIN "get jnl_eovtn and curr_tn from database file header"
	$DSE dump -file -all >&! dbheader.txt
	$grep "jnl solid tn" dbheader.txt >&! jnlepochtn.txt
	set jnl_eovtn = `cat jnlepochtn.txt | $tst_awk '{print $8}'`
	$grep "Current transaction" dbheader.txt >&! currtn.txt
	set curr_tn = `cat currtn.txt | $tst_awk '{print $3}'`
END

BEGIN "Recovery should fail as jfh->eov_tn < db->curr_tn"
	echo curr_tn = $curr_tn	
	echo eov_tn = $eov_tn	
	echo jnl_eovtn = $jnl_eovtn	
	echo "$MUPIP journal -recover -backward -verbose -since=$since -before=$before *"
	$MUPIP journal -recover -backward -verbose -since=\"$since\" -before=\"$before\" "*" 
END
