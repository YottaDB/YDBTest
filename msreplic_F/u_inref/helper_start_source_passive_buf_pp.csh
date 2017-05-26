#!/usr/local/bin/tcsh
set log=dummyps
$MUPIP replic -source -passive -start -buff=$tst_buffsize -instsecondary=${1} -propagateprimary -log=${log}.log >& ${log}.tmp
cat ${log}.tmp
