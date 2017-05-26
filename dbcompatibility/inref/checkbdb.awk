# The awk script checks for global data in a particular database.
# This script checks for "B" database globals as
# 1. Only globals beginning with "B" should exist.Else should error out.
BEGIN   {}
        {
        if ((NR>2) && (/^\^[^bB]/))
        {
                recorda++;
        }
}
END     {
        if ( 0 != recorda)
        {
                print "TEST-E-INCORRECT GLOBAL-DATAFILE MAPPING for BREG"
        }
	else
	{
		print "CORRECT GLOBAL-DATAFILE MAPPING for BREG"
	}
}
