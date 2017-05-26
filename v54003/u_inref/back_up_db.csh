#!/usr/local/bin/tcsh

# This script backs up the database files created during C9K11003340 test,
# using the numbers corresponding to specific tasks within the subtest.

foreach file ({a.dat,mumps.dat,mumps.gld,dse.outx,gtm.outx,dbcreate.outx,pid.outx})
        if (-f "$file") then
                mv "$file" "${1}_${file}"
        endif
end
