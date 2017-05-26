# The awk script checks for global data in a particular database.
# This script checks for "A234567A" database globals as
# 1. Only globals A234567A should exist with value "IamA8".Else should error out.
BEGIN   {}
        {
        if ((NR>2) && ($0 == "\^A234567A\=\"IamA8\""))
        {
                recorda++;
        }
}
END     {
        if ( 1 == recorda)
        {
                print "CORRECT MAPPING on 8CHAR global"
        }
	else
	{
		print "TEST-E-INCORRECT MAPPING on 8CHAR global"
	}
}
