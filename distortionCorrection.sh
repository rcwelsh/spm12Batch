#!/bin/bash

#
# Code to do calculation the distorion
# correction utilizing the ANIMA Software
#
# Robert Welsh
# 2018-04-24
# 2018-08-09
# 2018-08-28 -- fixed to actually work with nii.gz files, and can be in any
#               working directory.
# 2018-08-29 -- point to Anima 3.1
# 2021-03-16 -- stop pointing to Anima and hope they have it defined.
# 2021-03-17 -- part of spm12Batch now.
#
# Release 1.2
#
# robert.c.welsh@utah.edu
#
# Using the ANIMA that is in the path.
#
# https://github.com/Inria-Visages/Anima-Public/wiki/Registration-tools
#
# Anima must be installed, and the environmental variable SCRIPTSDIR
# needs to be assigned below.
#
# A log of the work is placed in a hidden file called .distortionCorrectionLog
#
# The following files are needed, either specified or determined by the code
#
#   run file -- this is the file to be corrected and has the same
#               phase encode polarity as the forward image. In fact,
#               If no forward image is specified, this image will be used
#               as the forward image -- which is normal behavior.
#
#   backward -- this is the file that has everything identical to the
#               run/forward file except for the polarity of the phase-encode
#               blip is opposite
#
#   forward  -- either defaults to point to the run file or a separate file.
#
# If you have a forward and backward file in the same directory as the run file
# that are called:
#
#  *AP* for the backward file
#  *PA* for the forward file
#
# Also, this code can handle nifti or nifti-gz files, BUT the file extension
# MUST be specified.
#
# The distortion correction is a multi-step process.
#
#  Step 1)
#
#     estimate the distortion correction using animaDistortionCorrection
#
#       output of distortion correction to            : ${RUNFILE}_Correction.nii
#
#  Step 2)
#
#     application of this correction to the forward image to assess quality
#
#      output corrected forward file to first order   : dc_1st_${FORWARD}
#
#  Step 3)
#
#     refinement of the distortation correction using animageBMDistortionCorrection
#
#       output of distortion correction to            : ${RUNFILE}_Correction.nii
#        
#  Step 4)
#
#     appplication of the resulting correction of Step 3) to the original run file.
#
# 

# Setup

function echol(){
    DATE=`date`
    echo "${DATE} : ${USER} : $1" >> .distortionCorrectionLog
    echo "${DATE} : ${USER} : $1" 
}

DATE=`date`
VERSION=1.3

# Point to the Anima binaries.

ANIMACOMMAND=`which animaBMDistortionCorrection`

if [ -z "${ANIMACOMMAND}" ]
then
    echo
    echo FATAL -- CANNOT FIND ANIMA
    echo
    exit 1
fi

SCRIPTSDIR=`dirname ${ANIMACOMMAND}`


# ------------ SETUP TO RUN NOW ---------------------


RUNNII=$1

# Did they pass anything?

if [ -z "${RUNNII}" ]
then
    echo
    echo "distortionCorrection.sh [run nifti file] [[backward image]] [[forward image]] [[outputName]]"
    echo
    echo "  Code to utilize the ANIMA distortion correction routines."
    echo "  Based on https://github.com/Inria-Visages/Anima-Public/wiki/Registration-tools"
    echo 
    echo "     [run nifti file]    -- nifti file to correct"
    echo "     [[backward image]]  -- will automatically look for a AP image if"
    echo "                            nothing specified"
    echo "     [[forward image]]   -- will automatically look for a PA image if"
    echo "                            nothing specified"
    echo "                            however, if one is not found, then we will"
    echo "                            assume the [run nifti file] is the forward"
    echo "                            image."
    echo "     [[outputName]]      -- to override using \"dc_\""
    echo
    echo "  The output will go to the current working directory."
    echo 
    echo "  The [run nifti file] and the [[forward image]] are acquired with the same"
    echo "  polarity of the phase encode blips, while [[backward image]] has the"
    echo "  opposite polarity."
    echo
    echo "  A important criteria is that the headers of the two images must match exactly".
    echo "  Sometimes dcm2nii results in headers that differ in the last decimal -- while "
    echo "  not relevant to neuroimaging processsing -- but Anima will refuse to work "
    echo "  with the images unless they match exactly. This uses fslcpgeom and dd to fix this issue."
    echo
    echo "  Also, the order this should take place in the pre-processing steam is a "
    echo "  scientific question. Movement can effect distortion, but in the limit that "
    echo "  motion is non-existent, then motion correction could take place first."
    echo 
    echo "  Make backups of everthing!"
    echo
    echo "Robert Welsh - robert.c.welsh@utah.edu"
    echo "2021-03-16 Version:${VERSION}"
    echo
    exit 1
fi

# Get the backward and forward image parameters.

echol "Using the run file ${RUNNII}"

BACKWARD=$2
FORWARD=$3

# check the backward image

if [ -z "${BACKWARD}" ]
then
    nBACKWARD=`ls *AP*.nii 2> /dev/null | wc -l `
    if [ ${nBACKWARD} != 1 ] 
    then
	echo
	echo "Either too make AP images or none to be found"
	echo
	exit 1
    fi
    BACKWARD=`ls *AP*.nii`
else
    if [ ! -e "${BACKWARD}" ]
    then
	echo
	echo "The backward image you specified does not exist : ${BACKWARD}"
	echo
	exit 1
    fi
fi

echol "Backward image is ${BACKWARD}"

# check the backward image

if [ -z "${FORWARD}" ]
then
    nFORWARD=`ls *PA*.nii 2> /dev/null | wc -l `
    if [ ${nFORWARD} -gt 1 ]
    then
	echo
	echo "Too many forward images."
	echo
	exit 1
    fi
    if [ ${nFORWARD} == 1 ]
    then
	FORWARD=`ls *PA*.nii`
    else
	echol "Using the run file as the forward file"
	FORWARD=${RUNNII}
    fi
else
    if [ ! -e "${FORWARD}" ]
    then
	echo
	echo "The forward image you specified does not exist : ${FORWARD}"
	echo
	exit 1
    fi    
fi

echol "Forward image is ${FORWARD}"

# Now make sure that the forward and backward images are different!

if [ ${FORWARD} == ${BACKWARD} ]
then
    echol "FATAL you specified the same file for the forward and the backward image, that is impossible"
    echo
    exit 1
fi

# Now see if they passed a prepend name

if [ -z "$4" ]
then
    outputName=dc_
else
    outputName=$4
fi

# Now get the basenames so that we can be in a different working directory than the actual files.

RUNNIIBASE=`basename ${RUNNII}`
BACKWARDBASE=`basename ${BACKWARD}`
FORWARDBASE=`basename ${FORWARD}`

RUNNIIBASENAME=`echo ${RUNNIIBASE} | sed -e's/\.nii//g' | sed -e 's/\.gz//g'`
FORWARDBASENAME=`echo ${FORWARDBASE} | sed -e's/\.nii//g' | sed -e 's/\.gz//g'`

# Put some output out.

echol "Distortion correcton log is .distortionCorrectionLog"

echol " Starting distortion correction by ${USER}"              
echol " Configured as"                                          
echol "      RUN       : ${RUNNII}"                              
echol "      BACKWARD  : ${BACKWARD}"                            
echol "      FORWARD   : ${FORWARD}"
echol "      OUTPUT    : ${outputName}${RUNNIIBASENAME}.nii"
echol "  Code Version  : ${VERSION}"
echol "  Anima Version : ${SCRIPTSDIR}"
echol " -----------------------------------------------"        

# Check the geometry of the files to make sure they all match.
# Jump forward 252 bytes and dump 76 bytes, which is where all of the
# geometry lives. 

od -h -j 252 -N 76 ${RUNNII}    &> .geometry1
od -h -j 252 -N 76 ${BACKWARD}  &> .geometry2
od -h -j 252 -N 76 ${FORWARD}   &> .geometry3

df1=`diff .geometry1 .geometry2 -q | wc -l | awk '{print $1}'`  # run and backward
df2=`diff .geometry1 .geometry3 -q | wc -l | awk '{print $1}'`  # run and forward
df3=`diff .geometry2 .geometry3 -q | wc -l | awk '{print $1}'`  # forward and backward

fileDiffs=$(( ${df1} + ${df2} + ${df3} ))

if [ ${fileDiffs} -ne 0 ]
then
    if [ ${df1} -ne 0 ]
    then
	df1="<>"
    else
	df1="="
    fi
    if [ ${df2} -ne 0 ]
    then
	df2="<>"
    else
	df2="="
    fi
    if [ ${df3} -ne 0 ]
    then
	df3="<>"
    else
	df3="="
    fi
    echol "FATAL File geometries do not match! Currently "
    echol "     [run]${df1}[backward], [run]${df2}[forward], [backward]${df3}[forward]"
    echol "Consider using fslcpgeom to make them match. It is recommended"
    echol "to copy the geometry as "
    echol "        [runfile]->[forward],"
    echol "        [runfile]->[backward]"
    echol "as necessary. Consider using assertGeometry.sh" 
    echo
    exit 1
fi

# Step 1
echol "${SCRIPTSDIR}/animaDistortionCorrection -o ${RUNNIIBASENAME}_Correction.nii -d 1 -b ${BACKWARD} -f ${FORWARD}"
${SCRIPTSDIR}/animaDistortionCorrection -o ${RUNNIIBASENAME}_Correction.nii -d 1 -b ${BACKWARD} -f ${FORWARD} >> .distortionCorrectionLog  2>&1
if [ $? != 0 ]
then
    echol "FAILED animaDistortionCorrection"
    echo
    exit 1
fi
# Now assert the geometry
echol "dd if=${RUNNII} of=${RUNNIIBASENAME}_Correction.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat"
dd if=${RUNNII} of=${RUNNIIBASENAME}_Correction.nii bs=1 skip=252 count=76 seek=252 conv=notrunc
#dd if=${RUNNII} of=${RUNNIIBASENAME}_Correction.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat


# Step 2
echol "${SCRIPTSDIR}/animaApplyDistortionCorrection -f ${FORWARD} -t ${RUNNIIBASENAME}_Correction.nii -o ${outputName}1st_${FORWARDBASENAME}.nii"
${SCRIPTSDIR}/animaApplyDistortionCorrection -f ${FORWARD} -t ${RUNNIIBASENAME}_Correction.nii -o ${outputName}1st_${FORWARDBASENAME}.nii >> .distortionCorrectionLog 2>&1
if [ $? != 0 ]
then
    echol "FAILED animaApplyDistortionCorrection"
    echo
    exit 1
fi
# Now assert the geometry
echol "dd if=${RUNNII} of=${outputName}1st_${FORWARDBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat"
dd if=${RUNNII} of=${outputName}1st_${FORWARDBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc
#dd if=${RUNNII} of=${outputName}1st_${FORWARDBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat


# Step 3
echol "${SCRIPTSDIR}/animaBMDistortionCorrection -f ${FORWARD} -b ${BACKWARD} -i ${RUNNIIBASENAME}_Correction.nii -O ${RUNNIIBASENAME}_BMCorrection.nii -o ${outputName}test_${FORWARDBASENAME}.nii"
${SCRIPTSDIR}/animaBMDistortionCorrection -f ${FORWARD} -b ${BACKWARD} -i ${RUNNIIBASENAME}_Correction.nii -O ${RUNNIIBASENAME}_BMCorrection.nii -o ${outputName}2nd_${FORWARDBASENAME}.nii >> .distortionCorrectionLog 2>&1
if [ $? != 0 ]
then
    echol "FAILED animaBMDistortionCorrection"
    echo
    exit 1
fi
# Now assert the geometry
echol "dd if=${RUNNII} of=${RUNNIIBASENAME}_BMCorrection.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat"
dd if=${RUNNII} of=${RUNNIIBASENAME}_BMCorrection.nii bs=1 skip=252 count=76 seek=252 conv=notrunc
#dd if=${RUNNII} of=${RUNNIIBASENAME}_BMCorrection.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat
echol "dd if=${RUNNII} of=${outputName}2nd_${FORWARDBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat"
dd if=${RUNNII} of=${outputName}2nd_${FORWARDBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc
#dd if=${RUNNII} of=${outputName}2nd_${FORWARDBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat


# Step 4
echol "${SCRIPTSDIR}/animaApplyDistortionCorrection -f ${RUNNII} -t ${RUNNIIBASENAME}_BMCorrection.nii -o ${outputName}${RUNNIIBASENAME}.nii"
${SCRIPTSDIR}/animaApplyDistortionCorrection -f ${RUNNII} -t ${RUNNIIBASENAME}_BMCorrection.nii -o ${outputName}${RUNNIIBASENAME}.nii >> .distortionCorrectionLog 2>&1
if [ $? != 0 ]
then
    echol "FAILED animaApplyDistortionCorrection"
    echo
    exit 1
fi
# Now assert the geometry
echol "dd if=${RUNNII} of=${outputName}${RUNNIIBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat"
dd if=${RUNNII} of=${outputName}${RUNNIIBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc
#dd if=${RUNNII} of=${outputName}${RUNNIIBASENAME}.nii bs=1 skip=252 count=76 seek=252 conv=notrunc,nocreat


echol "Distortion correction completed with output file : ${outputName}${RUNNIIBASENAME}.nii"
echo

#
# all done
#

