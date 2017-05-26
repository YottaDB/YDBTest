BEGIN	{ }
{
	count = split($0, tmp, "\\");
	if (tmp[1] == "05")
		printf "%s\\%s\n", tmp[1], tmp[count]; # for SET record, print record type and data
	if (tmp[1] == "09")
		printf "%s\\%s\n", tmp[1], tmp[count]; # for TCOM record, print record type and TID
}
END	{ }
