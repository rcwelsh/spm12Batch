#!/bin/bash
#
#
# Run a job to despike a list of subjects
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

EXPDIR=/thalia/data/NERDLab/joedata/Eureka/RestingState_Striatal_ConnTool/ImagingData/Subjects20201104/

# put the subject list here, put in side quotes separated by space
SESSIONLIST="PTest PTest2 Ptest3"

# Where are the data?
FUNC=func/connect

# ---------------- Probably don't need to edit below ----------------------

# What volume to look for?
INPUTVOL=run

# Name to add to the front
OUTNAME=ds_

# ------------------------ DO NOT EDIT BELOW HERE --------------------------

# First check that all is okay?

DATE=`date`
BAD=0

for SESSION in ${SESSIONLIST}
do
    NRUNS=`ls ${EXPDIR}/${SESSION}/${FUNC}/run*/${INPUTVOL}*.nii 2> /dev/null | wc -l`
    if [ ${NRUNS} -eq 0 ]
    then
	echo "${DATE} : ${USER} : Something amiss with ${SESSION}"
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

for SESSION in ${SESSIONLIST}
do
    DATE=`date`
    cd ${EXPDIR}/${SESSION}/${FUNC}
    for RUN in `ls -d run_*`
    do       
	if [ -d ${RUN} ]
	then
	    cd ${EXPDIR}/${SESSION}/${FUNC}/${RUN}
	    for RUNFILE in `ls ${INPUTVOL}*.nii`
	    do
		if [ ! -e ${OUTNAME}${RUNFILE} ]
		then
		    echo "${DATE} : ${USER} : despiking ${EXPDIR}/${SESSION}/${FUNC}/${RUN}/${RUNFILE} ..."
		    echo "${DATE} : ${USER} : despiking ${RUNFILE}  " >> .00_despike
		    /home/Software/AFNI/linux_ubuntu_16_64/3dDespike ${RUNFILE}
		    echo "${DATE} : ${USER} : converting to ${OUTNAME}${RUNFILE}" >> .00_despike
		    /home/Software/AFNI/linux_ubuntu_16_64/3dAFNItoNIFTI despike+orig.BRIK
		    echo "${DATE} : ${USER} : mv despike.nii ${OUTNAME}${RUNFILE}" >> .00_despike
		    mv despike.nii ${OUTNAME}${RUNFILE}
		    rm despike+orig.*
		else
		    echo "${DATE} : ${USER} : ${EXPDIR}/${SESSION}/${FUNC}/${RUN}/${RUNFILE} appears to already to be despiked"
		    echo "${DATE} : ${USER} : appears to already to be despiked" >> .00_despike
		fi
	    done
	    cd ${EXPDIR}/${SESSION}/${FUNC}
	else
	    echo "${DATE} : ${USER} : ${EXPDIR}/${SESSION}/${FUNC}/${RUN} does not appears to be a folder"
	fi
    done    
done


echo
echo All done
echo

#
# all done.
# 
