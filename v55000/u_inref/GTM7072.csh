#!/usr/local/bin/tcsh -f

# Try with both a non-existing file and a file that exists. Historically,
# the existing file has only intermittently failed but non-existant file
# assert fails prior to V55000 with a debug build.

setenv gtm_ztrap_form entryref

$gtm_dist/mumps -run GTM7072 << EOF
doesnotexist.txt
EOF

touch exist.txt
$gtm_dist/mumps -run GTM7072 << EOF
exist.txt
EOF
