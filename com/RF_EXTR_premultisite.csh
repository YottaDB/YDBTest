#!/usr/local/bin/tcsh -v
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "RF_EXTR_premultisite called by $tst" | mailx -s "RF_EXTR_premultisite : $tst" gglogs

set pri_extract = $1
set sec_extract = $2
set tmpcom = $3
set stat = 0

if !( -e compare_extract_at_source )  mkdir compare_extract_at_source
cp $pri_extract $sec_extract $tmpcom compare_extract_at_source
cd compare_extract_at_source
if (-e rcv_tmp.com) then
if ("com" == "${tmpcom:e}") then
	source $tmpcom >>&! sec_dbcreate.out
else
	echo "$GDE @$tmpcom    >>&! sec_dbcreate.out"
	$GDE @$tmpcom    >>&! sec_dbcreate.out
endif
$MUPIP create >&! sec_mupip_create.out
if ($?gtm_chset) then
	if ("UTF-8" == "$gtm_chset") then
		echo "GT.M MUPIP EXTRACT UTF-8" >&! sec_extr
	else
		echo "GT.M MUPIP EXTRACT" >&! sec_extr
	endif
endif
echo "dd-mmm-yyyy hh:mm:ss ZWR" >>& sec_extr
cat $sec_extract >>& sec_extr
$MUPIP load sec_extr  >& sec_load.out
mv $sec_extract ${sec_extract}_orig
$gtm_tst/com/db_extract.csh $sec_extract >& sec_extr.out
if (`cksum $sec_extract | $tst_awk '{print $1}'` != `cksum $pri_extract | $tst_awk '{print $1}'`) then
	set stat = 1
endif
cd -
exit $stat

