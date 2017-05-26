#!/usr/local/bin/tcsh
# To test $ZEOF operation for files.  $ZEOF should not be set prior to a read and should not
# be set for writes.

cat /dev/null > nullfile
$gtm_dist/mumps -direct << xxx
set f="nullfile"
open f:READONLY
use f
set z=\$ZEOF
use \$p
write "\$ZEOF after open of a null file READONLY = ",z,!
use f
read x
set z=\$ZEOF
use \$p
write "\$ZEOF after a READ of a READONLY file = ",z,!
use f
write "Output a line",!      ; this should cause an error
read x
set z=\$ZEOF
use \$p
write "\$ZEOF after a READ after a WRITE error = ",z,!
close f
open f:APPEND
use f
set z=\$ZEOF
use \$p
write "\$ZEOF after open of a null file for APPEND = ",z,!
use f
write "Output a line",!
read x
set z=\$ZEOF
use \$p
write "\$ZEOF after a READ of a file opened for APPEND = ",z,!
use f
read x
set z=\$ZEOF
use \$p
write "\$ZEOF after attempt to read past end of file = ",z,!
use f:REWIND
set z=\$ZEOF
use \$p
write "\$ZEOF after use with REWIND = ",z,!
use f
read x
set z=\$ZEOF
use \$p
write "\$ZEOF after read of one input line = ",z,!
write "Input = ",x,!
halt
xxx

$echoline
cat /dev/null > nullfile
echo "Some output" > nonnullfile
$convert_to_gtm_chset nonnullfile
$gtm_dist/mumps -run filezeof
$echoline
