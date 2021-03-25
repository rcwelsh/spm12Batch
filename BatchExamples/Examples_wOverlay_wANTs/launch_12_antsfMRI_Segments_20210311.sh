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

EXPDIR=/thalia/data/NERDLab/joedata/Eureka/RestingState_Striatal_ConnTool

MASTERSUBJ=ImagingData/Subjects20201104_Derived

# put the subject list here, put in side quotes separated by space
SESSIONLIST="PTest PTest2 Ptest3"

# Where are the data?
FUNCDIR=func/connect

# ---------------- Probably don't need to edit below ----------------------

# Overlay file
HIRES=t1spgr.nii

# Where to put results
ANTSDIR=coReg/ANTs

# Run all sequential or parallel?
RUNAS=parallel

# ------------------------ DO NOT EDIT BELOW HERE --------------------------

# First check that all is okay?

DATE=`date`
BAD=0

# Check for WM
for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${FUNCDIR}/${ANTSDIR}/newSeg/c2N4_${HIRES} 2> /dev/null | wc -l`
    if [ ${NRUNS} -eq 0 ]
    then
	echo "${DATE} : ${USER} : Something amiss with ${SESSION} with c2N4_${HIRES}"
	BAD=1
    fi
done

# Check for CSF
for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${FUNCDIR}/${ANTSDIR}/newSeg/c3N4_${HIRES} 2> /dev/null | wc -l`
    if [ ${NRUNS} -eq 0 ]
    then
	echo "${DATE} : ${USER} : Something amiss with ${SESSION} with c3N4_${HIRES}"
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

THELOG=.astmp.log

rm -r ${THELOG} 2> /dev/null

SPMCMD=antsfMRI

# Command to warp the WM
CMD1="${SPMCMD} -f ${FUNCDIR} -h ${HIRES} -M ${MASTERSUBJ} -w ${ANTSDIR} -v c2N4_${HIRES} -in ants -on WM_ants_"

# Command to warp the CSF
CMD2="${SPMCMD} -f ${FUNCDIR} -h ${HIRES} -M ${MASTERSUBJ} -w ${ANTSDIR} -v c3N4_${HIRES} -in ants -on CSF_ants_"

if [ "${RUNAS}" == "parallel" ]
then
    for SESSION in ${SESSIONLIST}
    do
	echo "${DATE} : ${USER} : ${CMD1} ${SESSION}"
	${CMD1}  ${SESSION} | tee -a ${THELOG}
	echo "${DATE} : ${USER} : ${CMD2} ${SESSION}"
	${CMD2}  ${SESSION} | tee -a ${THELOG}
    done
else
    echo "${DATE} : ${USER} : ${CMD1} ${SESSIONLIST}"
    ${CMD1} ${SESSIONLIST} | tee -a ${THELOG}
    echo "${DATE} : ${USER} : ${CMD2} ${SESSIONLIST}"
    ${CMD2} ${SESSIONLIST} | tee -a ${THELOG}
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
