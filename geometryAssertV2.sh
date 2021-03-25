#!/bin/bash

#
# Robert Welsh
# robert.c.welsh@utah.edu
# 2019-08-20
#
# Assert the geometry of one file on to the other file.
#

# function to log what we do

function echol() {

    DATE=`date`
    echo "$1"
    echo "$DATE : ${USER} : $1"  >> .geometryFixLog

}

# Now dow the work

GEOFILE=$1
OLDFILE=$2
NEWFILE=$3

#

if [ -z "${GEOFILE}" ]
then
    echo
    echo ./geometryAssertV2.sh [geometry file] [old file] [new file]
    echo
    echo "   [geometry file]   - the file from which the geometry comes from"
    echo "   [old file]        - the file to fix"
    echo "   [new file]        - the output file"
    echo
    echo "   [old file] and [new file] may NOT be the same, and in fact [new file] should not exist"
    echo
    exit 1
fi

if [ -z "${OLDFILE}" ] || [ -z "${NEWFILE}" ]
then
    geometryAssertV2.sh
    exit 1
fi

#

if [ ! -e "${GEOFILE}" ]
then
    echo
    echo The geometry file does not exist.
    echo
    exit 1
fi

if [ ! -e "${OLDFILE}" ]
then
    echo
    echo The old file does not exist.
    echo
    exit 1
fi

if [ -e "${NEWFILE}" ]
then
    echo
    echo The new file already exists.
    echo
    exit 1
fi

#

# This ONLY works on LINUX
STAT="stat -c%s"
UNAME=`uname | grep -i darwin`

if [ "${UNAME}" ]
then
    STAT="stat -f%z"
fi

OLDFILELENGTH=`${STAT} ${OLDFILE}`

echol "Asserting geometry"
echol "   geometry file : ${GEOFILE}"
echol "   old file      : ${OLDFILE}"
echol "   new file      : ${NEWFILE}"

# This will take the 76 magical bytes of the matrices and copy
# from the canonical souce to the target. These after 252 bytes
# of the header.

# Copy the old to the new file

cp ${OLDFILE} ${NEWFILE}
ls -l ${OLDFILE} ${NEWFILE}

# And now copy the bits of the header, first using fsl and then dd to make
# sure they exactly match.

#echol "   fslcpgeom ${GEOFILE} ${NEWFILE} -d"
#fslcpgeom ${GEOFILE} ${NEWFILE} -d
#ls -l ${OLDFILE} ${NEWFILE}

echol "   dd if=${GEOFILE} of=${NEWFILE} bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat"
dd if=${GEOFILE} of=${NEWFILE} bs=1 skip=252 count=76 seek=252 conv=notrunc
#dd if=${GEOFILE} of=${NEWFILE} bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat
ls -l ${OLDFILE} ${NEWFILE}

#
# all done
# 
