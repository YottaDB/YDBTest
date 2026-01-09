#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
source $gtm_tst/com/set_specific.csh

# Enable diagnostic information.
set echo
set verbose

set hostn = $HOST:r:r:r
set tst_org_host=${tst_org_host:r:r:r:r}

# Encryption is NOT supported on versions < V5.3-004 and anything that is NOT V9xx.
if ((`expr "V900" \> "$tst_ver"`) && (`expr "V53004" \> "$tst_ver"`)) exit
if ((`expr "V900" \> "$gtm_verno"`) && (`expr "V53004" \> "$gtm_verno"`)) exit

# Encryption is NOT supported with MM access method either.
if ("BG" != "$acc_meth") exit 0

set timestamp = `date +%H%M%S`

# If the current version is less than V55000, use $gtm_tst/com/pre_V54002_safe_gde.csh.
if (`expr $gtm_verno "<" "V54002"`) then
	setenv GDE_SAFE "$gtm_tst/com/pre_V54002_safe_gde.csh"
else
	setenv GDE_SAFE "$GDE"
endif

# Set up encryption on all the regions (the assumption is that all regions NEED encryption AND GLD is already created).
$GDE_SAFE show -map >& encr_create_key_gde_${timestamp}.map
$tst_awk '/SEG/{seg[$3]++} END{for(i in seg) print "change -seg "i" -encr"}' encr_create_key_gde_${timestamp}.map > encr_enable_in_reg_${timestamp}.gde
$GDE_SAFE @encr_enable_in_reg_${timestamp}.gde

# Get the list of all databases that are present in the GLD OR explicitly passed to this script (as the case may be).
if ($# != 0) then
	echo $argv > dbfiles_$timestamp.lst
else
	$tst_awk '/FILE/{file[$3]++} END{for (i in file) print i}' encr_create_key_gde_${timestamp}.map > dbfiles_$timestamp.tmp
	sort dbfiles_$timestamp.tmp > dbfiles_$timestamp.lst
endif

# If gtm_use_same_sym_key variable is defined by any subtest, then use the same symmetric key for all databases. This key will be
# generated on the tst_org_host (the server where the test starts). The keys for all hosts, including tst_org_host, have the form
# ${whose_key_it_is}_sym_key_from_${who_created_the_key}.asc. If we are not the tst_org_host, then get the tst_org_host to encrypt
# the symmetric key with our public key.
if ($?gtm_use_same_sym_key) then
	if ("$hostn" != "$tst_org_host") then
		# Determine path to symmetric key on remote host. Note that this script is run on all the instances for non-replic,
		# replic, MSR, and multimachine. The code below is only run on a remote host when the same sym key needs to be used
		# across all databases. The usage of "remote" in the variable names below is from the perspective of tst_org_host,
		# even though the script is actually being executed on the remote host.
		if !($?test_replic) set test_replic = "unspecified"
		if ("MULTISITE" == "$test_replic") then
			# In multisite version of MSR there is also an instance directory in the path.
			set remote_symkey_path = "$SEC_SIDE/../.."
		else
			set remote_symkey_path = "$SEC_SIDE/.."
		endif

		set remote_host_key_name = ${hostn}_$$_pubkey.asc
		set shared_sym_key_on_remote_host = ${hostn}_sym_key_from_$tst_org_host.asc

		# Determine the ID of the remote host's default public key.
		set key_id = `$gpg --homedir=$GNUPGHOME --list-keys --keyid-format long | $tst_awk '/^pub/ {sub(/.*\//,""); print $1; exit}'`

		# Send the remote host's default public key to tst_org_host.
		$rcp $GNUPGHOME/gtm@fnis.com_pubkey.txt ${tst_org_host}:$tst_general_dir/$remote_host_key_name

		# Tag the transferred public key for use on tst_org_host, import it into the tst_org_host's key ring, and sign it.
		$rsh $tst_org_host "																								\
			$convert_to_gtm_chset $tst_general_dir/$remote_host_key_name																		\
			cd $tst_working_dir;																							\
			source $tst_general_dir/encrypt_env_settings.csh;																			\
			printf 'yes\\n${gtm_test_gpghome_passwd}\\n' | $gtm_tst_ver_gtmcrypt_dir/import_and_sign_key.sh $tst_general_dir/$remote_host_key_name $key_id >&! import_and_sign_$timestamp.out;			\
			cat import_and_sign_$timestamp.out"

		# Encrypt the pregenerated shared symmetric key with the remote host's now-signed public key.
		$rsh $tst_org_host "																								\
			cd $tst_working_dir;																							\
			source $tst_general_dir/encrypt_env_settings.csh;																			\
			echo $gtm_test_gpghome_passwd | $gtm_tst_ver_gtmcrypt_dir/encrypt_sign_db_key.sh $gtm_use_same_sym_key $tst_general_dir/$shared_sym_key_on_remote_host $key_id >&! encrypt_sign_db_key_$timestamp.out;	\
			cat encrypt_sign_db_key_$timestamp.out"

		set i = 2
		while ($i <= $gtm_test_eotf_keys)
			set inputfile = ${gtm_use_same_sym_key}_$i
			set outputfile = ${shared_sym_key_on_remote_host}_$i
			$rsh $tst_org_host "																					\
				cd $tst_working_dir;																				\
				source $tst_general_dir/encrypt_env_settings.csh;																\
				echo $gtm_test_gpghome_passwd | $gtm_tst_ver_gtmcrypt_dir/encrypt_sign_db_key.sh $inputfile $tst_general_dir/$outputfile $key_id >&! encrypt_sign_db_key_$timestamp.out;	\
				cat encrypt_sign_db_key_$timestamp.out"
				@ i++
		end
		# Copy the shared symmetric key to the remote side.
		$rcp -r ${tst_org_host}:$tst_general_dir/$shared_sym_key_on_remote_host $remote_symkey_path

		# Tag the symmetric key for use on the remote side.
		$convert_to_gtm_chset $remote_symkey_path/$shared_sym_key_on_remote_host
	endif
endif

set dblist = `$gtm_tst/com/names.csh dbfiles_$timestamp.lst`

if (-f $gtm_dbkeys) then
	cp -f $gtm_dbkeys dbkeys_$timestamp.out
else
	touch $gtm_dbkeys
endif

# When processing each database, we need to take the following into account:
# (a) If the global directory contains GT.CM databases, then only those that are needed in the current host (those that do not have
#     a ":") should be created. The remote side will take care of creating its set of encrypted keys and databases.
# (b) If the database file name already has a "." in it, say mumps.ubg, the key will be created under the name mumps_ubg_key.
foreach db ($dblist)
	set keylist = ""
	# Skip databases that have a ":" in their names (see (a) above).
	if ("$db" =~ "*:*") continue

	# Following IF is needed for the case where the FILE that maps to a given SEGMENT does not have a ".". However, when
	# MUPIP CREATE, creates the file, it will create with a ".dat" extension automatically. So, the db_mapping_file needs
	# to have the ".dat" extension in it as well.
	if ("" == $db:e) set db = "$db.dat"

	# Takes care of dot substitution (see (b) above).
	set key = "${db:t:as/./_/}_key"

	# See if the database/key pair is already present in the gtm_dbkeys.
	$grep -w "$key" $gtm_dbkeys
	if (0 == $status) continue

	if ($?gtm_use_same_sym_key) then
		# Use the same key for all the hosts.
		if ("$hostn" != "$tst_org_host") then
			# This is the remote side. We have already done the hard job of getting the symmetric key from tst_org_host
			# side encrypted with our public key. All we need now is to copy that encrypted symmetric key under the
			# name corresponding to the database files in use.
			cp $remote_symkey_path/${hostn}_sym_key_from_$tst_org_host.asc $key
			set srcpath = "$remote_symkey_path"
			set srckeybase = "${hostn}_sym_key_from_$tst_org_host.asc"
		else
			cp $tst_general_dir/${hostn}_sym_key_from_$tst_org_host.asc $key
			set srcpath = "$tst_general_dir"
			set srckeybase = "${hostn}_sym_key_from_$tst_org_host.asc"
		endif
		cp $srcpath/$srckeybase $key
		set i = 2
		while ($i <= $gtm_test_eotf_keys)
			set altkey = ${key}_$i
			cp $srcpath/${srckeybase}_$i $altkey
			@ i++
		end

	else
		# Generate a new symmetric key, making sure to specify the --no-tty option on remote boxes.
		setenv gtm_encrypt_notty "--no-permission-warning --batch"
		if ("$hostn" != "$tst_org_host") then
			setenv gtm_encrypt_notty "$gtm_encrypt_notty --no-tty"
		endif
		# This command is for debugging if GPG cannot start. Left here for reference.
		# $ gpg-agent -vvv --debug-all --daemon --batch
		$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 $key
		if (1 < $gtm_test_eotf_keys) then
			set i = 2
			while ($i <= $gtm_test_eotf_keys)
				set altkey = ${key}_$i
				$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 $altkey
				@ i++
			end
		endif
		unsetenv gtm_encrypt_notty
	endif
	set i = 2
	while ($i <= $gtm_test_eotf_keys)
		set altkey = ${key}_$i
		# See if $db is a relative or an absolute path. If relative, then we need to prepend it with $PWD.
		if ($db !~ /*) set db = $PWD/$db
		if ($altkey !~ /*) set altkey = $PWD/$altkey

		# Now add $db and $key to a temporary file in the old $gtm_dbkeys file format.
		# Add the alternate keys first, since mupip create would pick the last key, which would be the default name ($key) added later
		echo "dat $db" >>&! $gtm_dbkeys
		echo "key $altkey" >>&! $gtm_dbkeys
		set keylist = "$keylist $altkey"
		@ i++
	end

	# See if $db is a relative or an absolute path. If relative, then we need to prepend it with $PWD.
	if ($db !~ /*) set db = $PWD/$db
	if ($key !~ /*) set key = $PWD/$key

	# Now add $db and $key to a temporary file in the old $gtm_dbkeys file format.
	echo "dat $db" >>&! $gtm_dbkeys
	echo "key $key" >>&! $gtm_dbkeys
	set keylist = "$keylist $key"
end

if ((`expr "V900" \> "$gtm_verno"`) && (`expr "V61001" \> "$gtm_verno"`)) then
	@ do_conv = 0
else
	@ do_conv = 1
endif

# Now, copy the gtmtls.cfg from $gtm_tst/com/tls/ to the current directory and append the database section created by CONVDBKEYS
# to it. This new configuration file will contain information required for running tests with both TLS and encryption.
if (-f gtmcrypt.cfg) mv gtmcrypt.cfg gtmcrypt_$timestamp.cfg
if (-f gtmtls.cfg) mv gtmtls.cfg gtmtls_$timestamp.cfg
cp $gtm_tst/com/tls/gtmtls.cfg .
sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! gtmcrypt.cfg

if ($do_conv) then
	# Convert gtm_dbkeys to the new configuration file format.
	if (-f tmp_gtmcrypt.cfg) mv tmp_gtmcrypt.cfg tmp_gtmcrypt_$timestamp.cfg
	$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys tmp_gtmcrypt.cfg
	cat tmp_gtmcrypt.cfg >>&! gtmcrypt.cfg
endif

# Turn off additional diagnostic info.
unset echo
unset verbose
