#!/usr/local/bin/tcsh -f

if ($?test_dont_zip) exit

if !($#argv ) then
	echo "Please give directory to zip"
	exit 1
endif

foreach direct ($argv)
	set ls_liart_file = $direct/ls_liart_`date +%H_%M_%S`.log
	echo "#ls -liart output..." >>&! $ls_liart_file
	$tst_ls -liart $direct >>&! $ls_liart_file
	if !(-d $direct) then
		echo "Please give directory to zip"
		exit 1
	endif

	find $direct -type f ! -name "*.Z" ! -name "*.gz" ! -name "*.dat" ! -name "*.gld" ! -name "*.log" ! -name "*.cmp" ! -name "*.diff" ! -name env.txt -exec $tst_gzip_quiet {} \;
end
