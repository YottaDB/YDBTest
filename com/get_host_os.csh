#!/usr/local/bin/tcsh

# Figure out the hostnames of the given machine names

if ($# < 1) then
	echo "Usage: $0 <list of machine names>"
	exit 1
endif	

set os_names = ""
foreach mach_name ($*)
	set host_os_name = `$ssh $mach_name -l $USER "uname -s"`
	set os_names = "$os_names $host_os_name"
end	
echo $os_names
exit 0
