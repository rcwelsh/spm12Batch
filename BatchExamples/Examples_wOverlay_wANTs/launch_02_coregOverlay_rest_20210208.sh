#!/bin/bash

#
# Robert Welsh
# 2019-10-14
#
# robert.c.welsh@utah.edu
#
# This uses the spm12Batch command coregOverlay
#

EXP=/thalia/data/MEND2/RUME19

DATE=`date`

#BATCH=$1
#START=$2

#SUBJECTLIST=/thalia/data/MEND2/RUME19/Scripts/PreProcessing/Resting/jobs_20200910a/subjectList_20200914_b.txt

# The subject list, seperate by spaces.
# ******************************* modify only the line below this *************************************
SUBJLIST="3561_01 3564_01 3566_01 3567_01 3568_01 3569_01 3573_01 3587_01 3588_01 3589_01 3593_01 3594_01 3595_01 5502_01"
# ******************************* modify only the line above this *************************************

cd ${EXPDIR}

echo 
echo "${DATE} : ${USER} : checking for mprage"
echo

for SUBJ in ${SUBJLIST}
do
    if [ ! -e ${EXP}/ImagingData/SubjectsDerived/${SUBJ}/anatomy/mprage.nii ]
    then
	if [ ! -e ${EXP}/ImagingData/Subjects/${SUBJ}/anatomy/mprage.nii ]
	then
	    cd ${EXP}/ImagingData/Subjects/${SUBJ}/anatomy
	    NECHO=`ls memprage*.nii| wc -l `
	    if [ ${NECHO} != 4 ]
	    then
		echo "${DATE} : ${USER} : FATAL - I need to build an RMS image, but no echos for ${SUBJ}"
		echo
		exit 1
	    fi
	    export FSLOUTPUTTYP=NIFTI
	    fslmerge -t tmpmprage.nii memprage*.nii
	    fslmaths tmpmprage -sqr -Tmean -sqrt mprage.nii
	    rm -r tmpmprage.nii
	    echo "${DATE} : ${USER} : build RMS mprage image from 4 echos" >> .mprage
	    cd ${EXP}
	    echo "${DATE} : ${USER} : build RMS mprage image from 4 echos for ${SUBJ}"
	fi
	if [ ! -e ${EXP}/ImagingData/Subjects/${SUBJ}/anatomy/mprage.nii ]
	then
	    echo "${DATE} : ${USER} : FATAL - mprage.nii failure for ${SUBJ}"
	    echo
	    exit 1
	fi
	mkdir -p ${EXP}/ImagingData/SubjectsDerived/${SUBJ}/anatomy/
	if [ $? != 0 ]
	then
	    echo "${DATE} : ${USER} : FATAL failed to build directory ${EXP}/ImagingData/SubjectsDerived/${SUBJ}/anatomy/"
	    exit 1
	fi
	cp ${EXP}/ImagingData/Subjects/${SUBJ}/anatomy/mprage.nii ${EXP}/ImagingData/SubjectsDerived/${SUBJ}/anatomy/
	echo "${DATE} : ${USER} : cp ${EXP}/ImagingData/Subjects/${SUBJ}/anatomy/mprage.nii ${EXP}/ImagingData/SubjectsDerived/${SUBJ}/anatomy/ " >> ${EXP}/ImagingData/SubjectsDerived/${SUBJ}/anatomy/.mprage
	echo "${DATE} : ${USER} : copied mprage into SubjectsDerived for ${SUBJ}"
    fi
done

echo

# Now launch the spm12Batch command.

cd ${EXP}

echo "${DATE} : ${USER} : coregOverlay -f func/Rest -o mprage -v meandc_run_01 -M ImagingData/SubjectsDerived -U NOMAIL ${SUBJLIST}"
coregOverlay -f func/Rest -o mprage -v meandc_run_01 -M ImagingData/SubjectsDerived -U NOMAIL ${SUBJLIST}

#
# all done.
#
