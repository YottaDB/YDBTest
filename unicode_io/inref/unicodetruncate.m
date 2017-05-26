unicodetruncate(encoding) 
	;Test the deviceparameter TRUNCATE
	SET $ZTRAP="GOTO errorAndCont^errorAndCont"
        set file=encoding_"unicodetruncate.txt"
	write "TRUNCATE with OPEN on a non-existent file",!
	do open^io(file,"TRUNCATE:BIGRECORD:RECORDSIZE=1048576",encoding)
	use file:(WIDTH=1048576)
	write "Start,1,ｈｉｊｋｌｍｎｏ-v1",!
	write "俭倥偠傞僟儣兪,2,ｈｉｊｋｌｍｎｏ-v1",!
	write "俭倥偠傞僟儣兪,3,ｈｉｊｋｌｍｎｏ-v1",!
	write s32k,!
	write s1mb,!
	write "End,1,ｈｉｊｋｌｍｎｏ-v1",!
	close file
	;
	do type
	write "TRUNCATE with OPEN on an existing file",!
	do open^io(file,"TRUNCATE:BIGRECORD:RECORDSIZE=1048576",encoding)
	use file:(WIDTH=1048576)
	write "Start,2,ｈｉｊｋｌｍｎｏ-v2",!
	write "俭倥偠傞僟儣兪,1,ｈｉｊｋｌｍｎｏ-v2",!
	write "俭倥偠傞僟儣兪,2,ｈｉｊｋｌｍｎｏ-v2",!
	write "俭倥偠傞僟儣兪,3,ｈｉｊｋｌｍｎｏ-v2",!
	write "俭倥偠傞僟儣兪,4,ｈｉｊｋｌｍｎｏ-v2",!
	write s32k,!
	write s1mb,!
	write "END OF FILE, version 2",!
	close file
	;
	do type
	write "TRUNCATE with USE on an existing file",!
	do open^io(file,"REWIND:BIGRECORD:RECORDSIZE=1048576",encoding)
	use file:(WIDTH=1048576)
	read line
	read line
	use file:(TRUNCATE)
	write "Start,1,ｈｉｊｋｌｍｎｏ-v3",!
	write "俭倥偠傞僟儣兪,2,ｈｉｊｋｌｍｎｏ-v3",!
	write s32k,!
	write s1mb,!
	write "END OF FILE, version 3",!
	close file
	do type
	;
	write "TRUNCATE with OPEN on an existing file FIXED mode",!
	do open^io(file,"FIXED:TRUNCATE:BIGRECORD:RECORDSIZE=1048576",encoding)
	use file:(WIDTH=1048576)
	write "Start,2,ｈｉｊｋｌｍｎｏ-v4",!
	write "俭倥偠傞僟儣兪,1,ｈｉｊｋｌｍｎｏ-v4",!
	write "俭倥偠傞僟儣兪,4,ｈｉｊｋｌｍｎｏ-v4",!
	write "END OF FILE, version 4",!
	close file
	do type
	;
	write "TRUNCATE with USE on an existing file with FIXED mode",!
	do open^io(file,"FIXED:REWIND:BIGRECORD:RECORDSIZE=1048576",encoding)
	use file:(WIDTH=1048576)
	read line
	read line
	use file:(TRUNCATE)
	write "Start,1,ｈｉｊｋｌｍｎｏ-v5",!
	write "俭倥偠傞僟儣兪,2,ｈｉｊｋｌｍｎｏ-v5",!
	write "END OF FILE, version 5",!
	close file
	do type
	quit
type
	open file:(READONLY:NOTRUNCATE:REWIND:BIGRECORD:RECORDSIZE=1048576:ICHSET=encoding)
	do readfile^filop(file,0)
	close file
	quit
