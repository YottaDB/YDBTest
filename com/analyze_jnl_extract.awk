BEGIN {	error = -1;
	fieldname = "seqno";
	if (""!=tn)
	{
		fieldname = "tn";
		sf = 3;	# tn is 3rd field in default journal extract
	}
      }
{
	if ("" ==tn)
		sf = 6; # seqno (actually token_seq) is 6th field in default journal extract
	split($0, array, FS);
	if ("05" == array[1]) # only checks SET records
	{
		if (-1 == error)
			error = 0;
		checkfield = $sf; #seqno or tn
		seen[checkfield] = 1;
		printf $1 " " checkfield " " $NF;
		if ((checkfield < ll) || (checkfield > ul))
		{
			print "<-- TEST-E-ERROR "fieldname " " checkfield " not within range " ll " to " ul
			error = 1;
		} else
			printf "\n";
	}
}
END {
    	if (-1 == error)
	{
		if (ul || ll)
			printf "TEST-E-ERROR "
		print "lost transaction file empty"
		exit;
	}
	for (i = ll; i <= ul; i++)
	{
		if (!seen[i])
		{
			error = 1;
			print "TEST-E-ERROR seqno " i " not seen in file"
		}
	}
	if (! error)
		print "PASS from lost transaction analysis"
	else
		print "TEST-E-ERROR from lost transaction analysis"
    }
