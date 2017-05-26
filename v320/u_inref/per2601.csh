$ node = f$getsyi("nodename")
$ if node .nes. "PEG"
$  then
$   node := PEG
$  else
$   node := CETUS
$ endif
$ submit/que='node'_hiq user:[metzger.cm]gtcmstart.com/nolog
$ job = $entry
$ define gtm$gbldir mumps
$ gde @per2601.gde
$ define gtm$gbldir local
$ mupip create
$ define otherdb 'node'::'f$environment("default")'other.dat
$ define gtm$gbldir remote
$ mac rundown
$ create dm.m
dm	f  b
$ mumps dm
$ link dm,rundown
$ on error then goto cleanup
$ r dm
d ^per2601
$cleanup:
$! define/user sys$input 'f$trnlnm("sys$command")'
$! gtm
$ deassigb otherdb
$ deassing gtm$gbldir
$ delete/entry='job'
$ delete mumps.dat.,other.dat.,mumps.gld.,other.gld.,local.gld.,remote.gld.,dm.m.,dm.obj.,dm.exe.,rundown.obj.,per2601.obj.
