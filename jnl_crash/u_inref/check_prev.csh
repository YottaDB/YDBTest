#!/usr/local/bin/tcsh -f
# Followings make sure GTM have not switched journal for a bad journal file
$MUPIP journal -for -noverify -show=head a.mjl |& $grep "Prev journal file name"
$MUPIP journal -for -noverify -show=head b.mjl |& $grep "Prev journal file name"
$MUPIP journal -for -noverify -show=head c.mjl |& $grep "Prev journal file name"
$MUPIP journal -for -noverify -show=head d.mjl |& $grep "Prev journal file name"
$MUPIP journal -for -noverify -show=head e.mjl |& $grep "Prev journal file name"
$MUPIP journal -for -noverify -show=head f.mjl |& $grep "Prev journal file name"
$MUPIP journal -for -noverify -show=head g.mjl |& $grep "Prev journal file name"
$MUPIP journal -for -noverify -show=head h.mjl |& $grep "Prev journal file name"
$MUPIP journal -for -noverify -show=head mumps.mjl |& $grep "Prev journal file name"
