#!/usr/local/bin/tcsh
# The intent of this script was to match the CHSET
# of GT.M.  However some elements in the test system
# don't make this possible.
# Using gtm_dont_tag_UTF8_ASCII as well to compensate

set file = $1
if ! ( -e $file ) then
	echo "$file does not exist" >> cvt.log
	exit
endif
set bak = ${1}.ibm1047

set tagit = "-T"
if ("BINARY" == $2) then
	set tagit = "-M"
endif

set cvtmode = "ISO8859-1"
if ($?gtm_chset && $?gtm_dont_tag_UTF8_ASCII) then
	# gtm_dont_tag_UTF8_ASCII must be set to one when switching to UTF-8 tagging mode
	if ("UTF-8" == $gtm_chset && 1 == $gtm_dont_tag_UTF8_ASCII) set cvtmode = "UTF-8"
endif

set filetag=`chtag -p $file | awk '{print $2}'`
if ("IBM-1047" != $filetag && "untagged" != $filetag) then
	echo "WARNING: ${file}'s ccsid is $filetag and not IBM-1047. Not converting to $cvtmode" >> cvt.log
	exit
endif

mv $file $bak
iconv $tagit -f IBM-1047 -t $cvtmode $bak > $file

if ("BINARY" == $2) then
        chtag -b $file
endif
