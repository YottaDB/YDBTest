#!/usr/local/bin/tcsh -f

#  Verify that the open command behaves correctly for /dev/zero, /dev/random and /dev/null devices.

foreach devtype ("zero" "random" "urandom" "null")
if ( -e "/dev/$devtype" ) then
        $GTM << EOF
        set dev="/dev/$devtype"
        open dev:(nofixed:wrap:readonly:chset="M")
        zshow "D"
        use dev 
        if (("$devtype"="zero")!("$devtype"="urandom")) read l#5 use \$p write "$devtype",!
        close dev
        open dev:(fixed:wrap:readonly:chset="M")
        zshow "D"
        use dev 
        if (("$devtype"="zero")!("$devtype"="urandom")) read l#5 use \$p write "$devtype",!
        close dev
EOF

endif
end
