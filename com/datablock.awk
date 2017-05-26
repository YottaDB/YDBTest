# Extract the Block numbers for GVT Data Blocks
FILENAME {
		if ( "" == $0) next;
		if ( $0 ~ /Level 0/)
		{
			grab="yes"
			blk=$2;
			next;
		}
		if ( "yes" == grab )
		{
			if ( $0 !~ /Ptr/ ) tot=tot" "blk;
			grab=""
		}
}
END{
	print tot;
}
