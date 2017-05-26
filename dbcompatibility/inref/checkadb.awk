# The awk script checks for global data in a particular database.
# This script checks for "A" database globals on two counts.
# 1. Only globals beginning with "A" should exist.Else should error out.
# 2. Long global names & their values previously set should be correct.Else should error out.
BEGIN   {}
        {
        if ((NR>2) && (/^\^[^aA]/))
        {
                recorda++;
        }
        if ((NR>2)&& ($0 == "\^A234567A9\=\"IamA9\"") || ($0 == "\^A234567ALongname18\=\"Iam18\"") || ($0 == "\^A234567A9MoreLongNameNow26\=\"Iam26\""))
        {
                lines++;
        }
}
END     {
        if ( 0 != recorda)
        {
                print "TEST-E-INCORRECT GLOBAL-DATAFILE MAPPING for AREG"
        }
	else
	{
		print "CORRECT GLOBAL-DATAFILE MAPPING for AREG"
	}
        if ( 3 == lines )
        {
                print "CORRECT 9CHAR GLOBAL-DATAFILE MAPPING"
        }
        else
        {
                print "TEST-E-INCORRECT 9CHAR GLOBAL MAPPING"
        }
}
