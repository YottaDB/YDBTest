BEGIN	{ FS="\\"; count = 0}
	{
		split($NF, array, "=");
		split(array[2], array1, "\"");
		if (array[1] == gbl)
		{
			if (count != array1[2])
			{
				printf "Error at Line %d : Actual %s=%d : Expected %s=%d\n",
					  NR, array[1], array1[2], array[1], count; 
				count = $9; # $9 is null. Do we need to set it to null?
			}
			count++;
		}
		if (array[1] == gbl2)
		{
			fncount = array1[2];
		}
	}
END	{ if (fncount != count -1) printf "final value of %s : %d, value of %s : %d\n", gbl, count -1, gbl2, fncount; }
