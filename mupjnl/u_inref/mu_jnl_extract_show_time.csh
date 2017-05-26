#!/usr/local/bin/tcsh
echo "#################################################"
echo "#TEST THE TIME QUALIFIERS WITH SHOW"
set echo
$MUPIP journal -show=b -forward -before=\"$time2\" mumps.mjl -fences=NONE
$MUPIP journal -show=ac -forward -before=\"$time2\" mumps.mjl -fences=NONE
$MUPIP journal -show=process -forward -before=\"$time2\" mumps.mjl -fences=NONE
$MUPIP journal -show=all -forward -after=\"$time1\" mumps.mjl -fences=NONE
$MUPIP journal -show=s -forward -before=\"$time6\" mumps.mjl -after=\"$time1\" -fences=NONE
$MUPIP journal -show=all -back -since=\"$time1\" mumps.mjl -fences=NONE
$MUPIP journal -show=header -noverify -back -since=\"$time1\" mumps.mjl -fences=NONE
$MUPIP journal -show=processes -back -since=\"$time1\" mumps.mjl -fences=NONE
$MUPIP journal -show=active_processes -back -since=\"$time1\" mumps.mjl -fences=NONE
$MUPIP journal -show=broken_transaction -back -since=\"$time1\" mumps.mjl -fences=NONE
$MUPIP journal -show=statistics -back -since=\"$time1\" mumps.mjl -fences=NONE
echo "###########"
echo "#TEST THE TIME QUALIFIERS WITH EXTRACT"
$MUPIP journal -extract=for1.mjf -forward -before=\"$time2\" mumps.mjl -fences=NONE
$MUPIP journal -extract=for2.mjf -forward -after=\"$time1\" mumps.mjl -fences=NONE
$MUPIP journal -extract=for3.mjf -forward -before=\"$time6\" mumps.mjl -after=\"$time1\" -fences=NONE
$MUPIP journal -extract=for4.jf -forward -before=\"$time1\" mumps.mjl -after=\"$time6\" -fences=NONE
$MUPIP journal -extract=for5.jf -forward mumps.mjl -after=\"$time6\" -fences=NONE
$MUPIP journal -extract=sinc1.mjf -back -since=\"$time1\" mumps.mjl -fences=NONE
unset echo
echo "#################################################"




