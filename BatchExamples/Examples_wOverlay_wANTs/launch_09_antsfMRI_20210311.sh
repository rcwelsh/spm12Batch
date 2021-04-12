#!/bin/bash
#
#
# Run a job to warp using ANTs a bunch of run volumes images for a subject list
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
FUNC=func/connect

# ---------------- Probably don't need to edit below ----------------------

# volumes to warp
INPUTVOL=r12a12ds_run

# HiRes file
HIRES=t1spgr.nii

# Where to find ants
ANTSDIR=coReg/ANTs

# Where to find ants
OUTNAME=ants

# Run all sequential or parallel?
RUNAS=parallel

# ------------------------ DO NOT EDIT BELOW HERE --------------------------

# First check that all is okay?

DATE=`date`
BAD=0

for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${FUNC}/run*/${INPUTVOL}*.nii 2> /dev/null | wc -l`
    if [ ${NRUNS} -eq 0 ]
    then
	echo "${DATE} : ${USER} : Something amiss with ${SESSION}, no run files"
	BAD=1
    fi
done

for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${MASTERSUBJ}/${SESSION}/${FUNC}/${ANTSDIR}/${HIRES} 2> /dev/null | wc -l`
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

THELOG=.aftmp.log

rm -r ${THELOG} 2> /dev/null

SPMCMD=antsfMRI

CMD="${SPMCMD} -f ${FUNC} -h ${HIRES} -M ${MASTERSUBJ} -on ${OUTNAME} -v ${INPUTVOL} -w ${ANTSDIR}"

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
