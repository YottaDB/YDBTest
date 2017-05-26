#!/usr/local/bin/tcsh -f
source $gtm_tst/com/dbcreate.csh mumps 1

cat << TFILE  > trigbomb.trg
-*
+^CIF(:) -commands=S -xecute="do ^trigbomb(129)"
TFILE
$load trigbomb.trg "" -noprompt
$show

$GTM << GTMDO
write "No cores expected"
set \$ETrap="write \$zstatus,! halt"
set ^CIF(1)=1
set ^CIF(1)=1
zwrite ^CIF
GTMDO

cat << TFILE  > trigcleanstop.trg
-*
+^CIF(:) -commands=S -xecute="do ^trigbomb(126)"
TFILE
$load trigcleanstop.trg "" -noprompt
$show

$GTM << GTMDO
write "No cores or failures expected"
set ^CIF(1)=1
set ^CIF(1)=100
zwrite ^CIF
GTMDO


cat << TFILE  > trigedgestop.trg
-*
+^CIF(:) -commands=S -xecute="do ^trigbomb(127)"
TFILE
$load trigedgestop.trg "" -noprompt
$show

$GTM << GTMDO
write "No cores or failures expected"
set ^CIF(1)=1
set ^CIF(1)=99
zwrite ^CIF
GTMDO

cat << TFILE  > trigbombalt.trg
-*
+^CIF(:) -commands=S -xecute="write ""I do diddly squat"",!"
+^CIF(:) -commands=S -xecute="do ^trigbomb(127)"
+^CIF(:) -commands=S -xecute="do ^trigbomb(129)"
TFILE
$load trigbombalt.trg "" -noprompt
$show

$GTM << GTMDO
set file="interleaved.out" open file:newversion use file
set ^CIF(1)=1
set ^CIF(1)=1000
close file use \$p
zwrite ^CIF
GTMDO


$gtm_tst/com/dbcheck.csh -extract
