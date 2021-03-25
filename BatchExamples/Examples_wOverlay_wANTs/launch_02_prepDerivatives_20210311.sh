#!/bin/bash
#
#
# Run a job to prepare derivatives for a list of subjects
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

EXPDIR=/thalia/data/NERDLab/joedata/Eureka/RestingState_Striatal_ConnTool

MASTERSUBJ=ImagingData/Subjects20201104
MASTERDERIV=ImagingData/Subjects20201104_Derived

# put the subject list here, put in side quotes separated by space
SESSIONLIST="PTest PTest2 Ptest3"

# Where are the data?
FUNC=func/connect

# ---------------- Probably don't need to edit below ----------------------

# Overlay file
OVERLAY=t1overlay.nii

# Overlay file
HIRES=t1spgr.nii

# Anatomy directory
ANATDIR=anatomy

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

for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${ANATDIR}/${OVERLAY} 2> /dev/null | wc -l`
    if [ ${NRUNS} -eq 0 ]
    then
	echo "${DATE} : ${USER} : Something amiss with ${SESSION} with ${OVERLAY}"
	BAD=1
    fi
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

THELOG=.ptmp.log

rm -r ${THELOG} 2> /dev/null

SPMCMD=prepDerivatives

CMD="${SPMCMD} -inc anatomy -M ${MASTERSUBJ} -MO ${MASTERDERIV}"

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
