zwr(varname,file,encoding);
	if $data(file)=0 set file="zwr.dat"
	if $data(encoding)=0 set encoding="M"
	if $ztrnlnm("gtm_chset")'="UTF-8" open file:(NEWVERSION)
	else  open file:(NEWVERSION:ochset=encoding)
	use file
	zwr @varname 
	close file
	quit
