# only a subset of subtests were submitted, modify outstream.cmp accordingly
{	if ("PASS" == $1)
	{
		if (! status)
		{
			status = 1;
			no=split(gtm_test_st_list,subtests,",");
			for (i=1;i<=no;i++)
				print "PASS from "subtests[i]
		}
	} 
	else 
		print
}
