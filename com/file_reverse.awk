BEGIN	{ count = 0; }
	{
		array[count++] = $0;
	}
END	{
		for (i = --count; i >= 0; i--)
			print array[i];
	}
