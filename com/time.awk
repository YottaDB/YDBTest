BEGIN{
	max[1]=12;max[2]=31;max[3]=24;max[4]=60;max[5]=60;
	no_op = split(ENVIRON[ "tst_options_all" ],option_names," ")
	for (ni=1;ni<=no_op;ni++)
	{
		x=option_names[ni]
		envir[x] = ENVIRON[x]
	}
	tst_general_dir = ENVIRON[ "testname" ]
	tst_ver = ENVIRON[ "tst_ver" ]
	tst_image = ENVIRON[ "tst_image" ]
	host = ENVIRON[ "HOST" ]
	gsub(/\..*/,"",host)
	bucket = ENVIRON[ "LFE" ]
}

{
	split($1,begin,".");
	split($2,final,".");
}

END {
	if (2 == begin[1])
	{
		# Process for leap year when bitten
		# Leap year calculation requires year in YYYY, which means changing $1 and $2. There are a lot of usages and I don't want to touch them all now
		max[2]=28;
	} else if (match ("04060911",begin[1]))
	{
		max[2]=30;
	}
	for (i=5;i>0;i--)
	{
		result[i] = final[i]-begin[i];
		if (result[i]<0)
		{
			result[i]+=max[i];
			final[i-1]--;
		}
		#printf i"  "final[i] ","begin[i] ":" result[i]
	}
	# will not work for more than a month timegap. But that's a large fix, not in use by the test system so far.
	for (i=2;i<5;i++) printf "%02d:",result[i] ; printf "%02d",result[5] 

	printf  " " tst_ver " " tst_image " " bucket " " tst_general_dir " " host
	for (ni=1;ni<=no_op;ni++)
	{
		x=option_names[ni]
		printf " " envir[x] ;
	}
	print " "
}
