#!/bin/sh
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script heavily relies on the OpenSSL configuration file and is based on CA.sh that comes with OpenSSL.

USAGE()
{
	echo "Usage: $0 CA|CERT <options>"
	echo
	echo "Tool to generate CAs, RootCAs and certificates."
	echo
	echo "  CA                   Creates a RootCA or an intermediate CA."
	echo "  CERT                 Creates a certificate."
	echo
	echo "      --out            Specifies the output filename to write to."
	echo "      --days           Specifies the number of days to make a certificate valid for. The default is 365 days."
	echo "      --startdate      Specifies the start-date for the certificate"
	echo "      --enddate        Specifies the start-date for the certificate"
	echo "      --keysize        Specifies the strength (in bits) of the private key."
	echo "      --pass           Specifies the password that should be used to protect the private key"
	echo "      --subj           String to be substituted for the subject field of the certificate: /O=../C=../CN=.."
	echo "      --self-sign      Create a self-signed RootCA."
	echo "      --signca         Specifies the filename of the CA which should be used to sign the certificate."
	echo "      --signpass       Specifies the password of the signing CA's private key file."
	echo "      --config         Specified the config file to use."
	echo
	echo " NOTES"
	echo
	echo "      The script generates certificates using the default OpenSSL configuration file which requires a specific"
	echo "      directory structure to be created (if not already present). When using the configuration file shipped with"
	echo "      OpenSSL, below is how the directory structure is laid out."
	echo
	echo "      ./demoCA              - main CA directory."
	echo "      ./demoCA/certs        - Directory for storing issued certificates."
	echo "      ./demoCA/crl          - CA revocation list directory."
	echo "      ./demoCA/newcerts     - New certificates directory."
	echo "      ./demoCA/private      - Private key directory."
	echo "      ./demoCA/index.txt    - CA database."
	echo
	echo "      When specifying --signca, provide just the name of the certificate. The script always looks for the"
	echo "      certificate and private key file relative to ./demoCA."

}

# Set defaults.
days=365
keysize=1024
selfsign=0
config=

# On certain systems, ``openssl'' utility is found in /usr/local/ssl/bin. So, first add it to the path.
export PATH=${PATH}:/usr/local/ssl/bin

# Create the directory structure if not already present.
if [ x"$CADIR" = "x" ]; then CADIR="./demoCA" ; fi

if [ ! -d $CADIR ]; then
	# Create the dummy directory structure that openssl.cnf refers to (``openssl'' utility will rely on this config file.
	mkdir -p ${CADIR}
	mkdir -p ${CADIR}/certs
	mkdir -p ${CADIR}/crl
	mkdir -p ${CADIR}/newcerts
	mkdir -p ${CADIR}/private
	# Create an empty database.
	touch ${CADIR}/index.txt
	# Create crlnumber file to contain the serial number for the next CRL
	echo "01" > ${CADIR}/crlnumber
fi

if [ $# -eq 0 ]; then USAGE; exit 0; fi
# Set CA extensions (if a CA/rootCA is requested).
ca_extensions=""
if [ "$1" = "CA" ]; then
	# If CA option is provided then we need to pick up the X509_V3 extensions otherwise the certificate generated will not be
	# treated as a CA.
	ca_extensions="-extensions v3_ca"
fi
shift

# Process the arguments.
while [ $1 != "" ] ; do
	case $1 in
		--out)
			out=$2
			shift 2
			;;
		--startdate)
			startdate=$2
			shift 2
			;;
		--enddate)
			enddate=$2
			shift 2
			;;
		--days)
			days=$2
			shift 2
			;;
		--keysize)
			keysize=$2
			shift 2
			;;
		--pass)
			passwd=$2
			shift 2
			;;
		--subj)
			subj=$2
			shift 2
			;;
		--signca)
			signca=$2
			shift 2
			;;
		--signpass)
			signpass=$2
			shift 2
			;;
		--self-sign)
			selfsign=1
			shift
			;;
		--config)
			config="-config $2"
			shift 2
			;;
		--)
			break
			;;
		*)
			exit 1
			;;
	esac
	if [ x"$1" = x ]; then break; fi
done

# Set variables for basic OpenSSL subcommands.
CA="openssl ca $config"
REQ="openssl req $config"
RSA="openssl genrsa"

exit_stat=0

# STEP 1: First generate the private key.
keyfile=${out%.*}.key
if [ -f $CADIR/private/$keyfile ]; then echo "Private key file $keyfile already exists in $CADIR/private"; exit 1; fi
$RSA -des3 -passout pass:$passwd -out $CADIR/private/$keyfile $keysize
if [ $? -ne 0 ]; then echo "OpenSSL private key generation failed." ; exit 1; fi

# STEP 2: Generate a certificate request.
reqfile=${out%.*}.csr
if [ -f $CADIR/$reqfile ]; then echo "Certificate Request file $reqfile already exists in $CADIR"; exit 1; fi
$REQ -new -key $CADIR/private/$keyfile -batch -subj "$subj" -passin pass:$passwd -out $CADIR/$reqfile
if [ $? -ne 0 ]; then echo "OpenSSL Certificate Request generation failed."; exit 1; fi

# STEP 3: Generate the certificate.
certfile=${out%.*}.pem
if [ -f $CADIR/$certfile ]; then echo "Certificate file $certfile already exists in $CADRI"; exit 1; fi
# Should the serial be created or reused?
serial_args=""
if [ ! -f $CADIR/serial ]; then serial_args="-create_serial"; fi
# Is this a rootCA?
if [ $selfsign -eq 1 ]; then
	selfsign_args="-selfsign"
	# Creating RootCA. So, use the key file that was just generated.
	keyfile_args="-keyfile $CADIR/private/$keyfile"
	cert_args=""
	passin_args="-passin pass:$passwd"
else
	selfsign_args=""
	keyfile_args="-keyfile $CADIR/private/${signca%.*}.key"
	cert_args="-cert $CADIR/$signca"
	passin_args="-passin pass:$signpass"
fi
validity_args="-days $days"
if [ x"$startdate" != "x" -a x"$enddate" != "x" ]; then
	validity_args="-startdate $startdate -enddate $enddate"
fi

$CA $serial_args -policy policy_anything -out $CADIR/$certfile $validity_args -batch $cert_args $keyfile_args $selfsign_args	\
		$ca_extensions $passin_args -infiles $CADIR/$reqfile
if [ $? -ne 0 ]; then exit 1; fi

exit 0
