#!/bin/bash
#
#
# Run a job to warp using ANTs a bunch of hires images for a subject list
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

EXPDIR=/thalia/data/MEND2/RUME19

MASTERSUBJ=ImagingData/SubjectsDerived

# put the subject list here, put in side quotes separated by space
SESSIONLIST="3516_01 3542_01"

# Where are the data?
FUNC=func/Rumination

# ---------------- Probably don't need to edit below ----------------------

# Overlay file
HIRES=mprage.nii

# Anatomy directory
ANATDIR=${FUNC}/coReg

# Where to put results
ANTSDIR=${ANATDIR}/ANTs

# Run all sequential or parallel?
RUNAS=parallel

# ------------------------ DO NOT EDIT BELOW HERE --------------------------

# First check that all is okay?

DATE=`date`
BAD=0

for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${ANATDIR}/${HIRES} 2> /dev/null | wc -l`
    if [ ${NRUNS} -eq 0 ]
    then
	echo "${DATE} : ${USER} : Something amiss with ${SESSION} with ${HIRES}"
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

THELOG=.ahtmp.log

rm -r ${THELOG} 2> /dev/null

SPMCMD=antsHiRes

CMD="${SPMCMD} -a ${ANATDIR} -h ${HIRES} -M ${MASTERSUBJ} -w ${ANTSDIR}"

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
