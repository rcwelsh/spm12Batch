#!/bin/bash
#
#
# Run a job to distortion correct a list of subjects for a given task
#
# This job does the work explicitly, as there is not an spm12Batch command
# at the moment. Feel free to launch this to the backgound.
#
# You will want to verify the following variables:
#
#   EXPDIR
#   FUNC
#
# Robert Welsh
#
# 2021-03-11
#

EXPDIR=/thalia/data/MEND2/RUME19

MASTERSUBJ=ImagingData/Subjects
MASTERDERIV=ImagingData/SubjectsDerived

# put the subject list here, put in side quotes separated by space
SESSIONLIST="3516_01 3542_01"

# Where are the data?
FUNC=func/Rumination

# ---------------- Probably don't need to edit below ----------------------

# Run all sequential or parallel?
RUNAS=parallel

# What volume to look for?
INPUTVOL=run

# Name to add to the front
OUTNAME=dc_

# Field map info
fieldMapPath=fieldMap
forwardImage=FM_PA
backwardImage=FM_AP

# ------------------------ DO NOT EDIT BELOW HERE --------------------------

# First check that all is okay?

DATE=`date`
BAD=0

for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${FUNC}/run*/${INPUTVOL}*.nii 2> /dev/null | wc -l`
    if [ ${NRUNS} -eq 0 ]
    then
	echo "${DATE} : ${USER} : Something amiss with ${SESSION}"
	BAD=1
    fi
done

# Check field mape
for SESSION in ${SESSIONLIST}
do
    for MAP in ${forwardImage} ${backwardImage}
    do
	NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${FUNC}/${fieldMapPath}/${MAP}.nii 2> /dev/null | wc -l`
	if [ ${NRUNS} -eq 0 ]
	then
	    echo "${DATE} : ${USER} : Something amiss with ${SESSION},missing image ${MAP}"
	    BAD=1
	fi
    done
done

# Exit if bad

if [ ${BAD} -eq 1 ]
then
    echo "${DATE} : ${USER} : because of issue above, aborting"
    exit 1
fi

# All good, so do the work, here we explicitly do the work, and not send to a job.

cd ${EXPDIR}

echo "${DATE} : ${USER} : building job(s)"

THELOG=.dstmp.log

rm -r ${THELOG} 2> /dev/null

SPMCMD=distortionCorrect

CMD="${SPMCMD} -bi ${backwardImage} -fi ${forwardImage} -fm ${fieldMapPath} -f ${FUNC} -M ${MASTERSUBJ} -MO ${MASTERDERIV} -on ${OUTNAME} -v ${INPUTVOL}"

if [ "${RUNAS}" == "parallel" ]
then
    for SESSION in ${SESSIONLIST}
    do
	echo "${DATE} : ${USER} : ${CMD} ${SESSION}"
	${CMD}  ${SESSION} | tee -a ${THELOG}
    done
else
    echo "${DATE} : ${USER} : ${CMD} ${SESSIONLIST}"
    ${CMD} ${SESSIONLIST} | tee -a ${THELOG}
fi

# Now tell them where to look

echo
echo ${DATE} : ${USER} : Look for these logs files to ensure that your ${SPMCMD} jobs have completed.
echo

grep ${SPMCMD} ${THELOG} | grep -e "\.sh" | awk -F. '{print $1 ".log"}'

echo

#
# all done.
# 
