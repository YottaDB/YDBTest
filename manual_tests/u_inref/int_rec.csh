#
# this script is for manual test intrpt_recov to create the database and journal files

setenv gtmgbldir mumps.gld
$gtm_test/T990/com/dbcreate.csh mumps
#
mupip set -journal=enable,on,before,file=mumps1.mjl -reg "*"
gtm << gtm1
  f i=1:1:1000 s ^a(i)=i
  h 1
gtm1
date +"%d-%b-%Y %H:%M:%S" > time1.txt
gtm << gtmb
  f i=1:1:1000 s ^b(i)=i
gtmb
#
mupip set -journal=enable,on,before,file=mumps2.mjl -reg "*"
gtm << gtm2
  f i=1:1:1000 s ^c(i)=i
  h 1
gtm2
date +"%d-%b-%Y %H:%M:%S" > time2.txt
#
gtm << gtmd
  f i=1:1:1000 s ^d(i)=i
gtmd
#
mupip set -journal=enable,on,before,file=mumps3.mjl -reg "*"
gtm << gtm3
  f i=1:1:1000 s ^e(i)=i
  h 1
gtm3
exit

# No need to call dbcheck.csh since this script only create the database and is called
# manually.
