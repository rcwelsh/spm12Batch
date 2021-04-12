#!/bin/bash
#
#
# Run a job to do SPM-based segmentation
#
# This will build the spm12Batch jobs and submit to the background.
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

EXPDIR=/Users/macalab/Desktop/Pipeline/Experiment/TestSuite

MASTERSUBJ=ImagingData/SubjectsDerived

# put the subject list here, put in side quotes separated by space
SESSIONLIST="TestSubject"

# Where are the data?
FUNC=func/Rest

# ---------------- Probably don't need to edit below ----------------------

# Overlay file
HIRES=N4_mprage_noFace

# Anatomy directory
ANATDIR=${FUNC}/coReg/ANTs

# Where to put results
NEWSEGDIR=${ANATDIR}/newSeg

# Run all sequential or parallel?
RUNAS=parallel

# ------------------------ DO NOT EDIT BELOW HERE --------------------------

# First check that all is okay?

DATE=`date`
BAD=0

for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${ANATDIR}/${HIRES}.nii 2> /dev/null | wc -l`
    if [ ${NRUNS} -eq 0 ]
    then
	echo "${DATE} : ${USER} : Something amiss with ${SESSION} with ${HIRES}.nii"
	BAD=1
    fi
done

# Exit if bad

if [ ${BAD} -eq 1 ]
then
    echo "${DATE} : ${USER} : because of issue above, aborting"
    exit 1
fi

# All good, so do the work.

cd ${EXPDIR}

echo "${DATE} : ${USER} : building job(s)"

THELOG=.nstmp.log

rm -r ${THELOG} 2> /dev/null

SPMCMD=newSeg

CMD="${SPMCMD} -a ${ANATDIR} -h ${HIRES} -M ${MASTERSUBJ} -w ${NEWSEGDIR}"

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
echo All done
echo

#
# all done
# 
