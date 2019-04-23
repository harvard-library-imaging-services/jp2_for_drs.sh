#!/bin/sh
# Note: this script uses exiftool

# init a couple of variables
ICC=""
COLORMODE=""
EXT="tif"

while [ $# -gt 0 ]
do
	case "$1" in
		-ext) shift; EXT=$1;;
		#-h) Help; exit 0;;
	esac
    shift
done

# add profile checking with Bill's suggestion.
echo "  Checking ICC Profile ..."

for f in `find . -maxdepth 1 -type f -name "*.$EXT" | sort`
do
	# get the profile name
	  ICC=`exiftool $f | grep "ICC Profile Name" | cut -d : -f 2 | awk '{$1=$1};1'`

	  # sometimes there is no "ICC Profile Name" tag, let's try "Profile Description"
	  if [ "$ICC" = "" ]; then
		ICC=`exiftool $f | grep "Profile Description" | cut -d : -f 2 | awk '{$1=$1};1'`
	  fi
	  echo "  $f - $ICC "
	  # if sGray or sRGB, we are all set.
	  # if not empty and not (sGray, sRGB), move the files to a folder so we can take a look.
	  # else the files have no ICC profile, we will leave them in place.
	  if [ "$ICC" = "sGray" -o "$ICC" = "sRGB IEC61966-2.1" ]; then
			if [ ! -d "ready" ]; then
				mkdir ready
			fi
			mv $f ready/$f
		elif [ ! "$ICC" = "" ]; then
			if [ ! -d "icc-check" ]; then
				mkdir icc-check
			fi
			mv $f icc-check/$f
		fi
done

echo ""
echo " Checking Color Mode ..."
# for the files which have no ICC, we will divide them up based on their color mode.
# tifleft=`find . -type f -name "*.$EXT" | `
for f in `find . -maxdepth 1 -type f -name "*.${EXT}" | sort`
do
	COLORMODE=`exiftool $f | grep "Color Mode" | cut -d : -f 2 | awk '{$1=$1};1'`
	echo "  $f - $COLORMODE"
	if [ ! -d $COLORMODE-NO-ICC ]; then
		mkdir $COLORMODE-NO-ICC
	fi
	mv $f $COLORMODE-NO-ICC/$f
done
