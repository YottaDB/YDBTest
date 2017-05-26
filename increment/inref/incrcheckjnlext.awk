# verifies that after every KILL record the value of ^x starts from 1 and increases by 1 until next KILL
BEGIN	{ FS="\\"; count = 1}
	{
		if ($1 == "04")	# KILL record 
			count = 1;
		else if ($1 == "05")
		{
			split($NF, array, "=");
			split(array[2], array1, "\"");
			if (count != array1[2])
			{
				printf "Error at Line %d : Actual %s=%d : Expected %s=%d\n", 
					  NR, array[1], array1[2], array[1], count; 
				count = $9;
			}
			count++;
		}
	}
END	{}
