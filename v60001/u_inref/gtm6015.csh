#!/usr/local/bin/tcsh -f
$GTM <<EOF >&! cmd0.out
 do ^gtm6015
 halt
EOF

echo "Expect count of 2 for cmdline 'first job process'"
$grep -c 'first job process' cmd1.out
echo "Expect count of 1 for mumps process without any CMDLINE"
$grep -c '\-direct' cmd2.out
echo "Expect count of 2 for cmdline 'third job process'"
$grep -c 'third job process' cmd3.out
