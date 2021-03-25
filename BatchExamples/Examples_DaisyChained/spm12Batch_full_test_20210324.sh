#!/bin/bash
#
# Example script to process a subject from start to finish using spm12Batch
#
# The spm12Batch calls can be done sequentially here as the -B flag is used in each.
# That tells each command to run in the foreground, allowing the commands to be daisy-chained together.
# The output status of the command is not being checked though.
#
# Robert Welsh
# robert.c.welsh@utah.edu
#
# 2021-03-25
#
# Step 1
#
# This will take the first two runs from the resting state and do the distortion correction. Because
# there are 4 runs of resting state all in the Rest/ directory and with two field map sets, then the runs
# have to be corrected one at a time explicitly.
#
# The output of the distortion correction will be sent to the SubjectedDerived folder.
#
# Step 2
#
# The anatomy is copied over to the SubjectsDerived tree
#
# Step 3
#
# The data are then despiked using AFNI. The data are taken from the SubjectsDerived directory and put
# back into the SubjectsDerived directory. For thos studies that do not have field maps, Step 1 will
# not be present. In that case also, the despikeAFNI command would instead take input from Subjects
#
# Step 4
#
# slicetime correct the data using multi-band capability
#
# Step 5
#
# motion correct the data
#
# Step 6
#
# coregister the mprage to the motion corrected data
#
# Step 7
#
# Uing ANTs, calculate the warps for the data, using the coregistered mprage as the input
# and putting the output in the coregistation tree
#
# Step 8
#
# Using ANTs, apply the warps to the fmri data, assuming the coReg is in the same task folder
#
# Step 9
#
# Smooth the fmri data
#
# Step 10
#
# Taking the bias corrected mprage from the ANTs output, do a segmentation on the data to get CSF and WM
#
# Step 11
#
# Using the ANTs warping instructions to warp the WM adn CSF to normalized space.
#

DATEStart=`date`
DATE=`date`
echo ${DATE} Step 01
distortionCorrect -B -MO ImagingData/SubjectsDerived -bi FM_AP -fi FM_PA -fm fieldMap12 -f func/Rest -v run_01 5502_02
DATE=`date`
echo ${DATE} Step 01
distortionCorrect -B -MO ImagingData/SubjectsDerived -bi FM_AP -fi FM_PA -fm fieldMap12 -f func/Rest -v run_02 5502_02
DATE=`date`
echo ${DATE} Step 02
prepDerivatives -B -MO ImagingData/SubjectsDerived -inc anatomy 5502_02
DATE=`date`
echo ${DATE} Step 03
despikeAFNI -B -M ImagingData/SubjectsDerived -MO ImagingData/SubjectsDerived -f func/Rest -on ds_ -v dc_run 5502_02
DATE=`date`
echo ${DATE} Step 04
sliceTimeMB -B -M ImagingData/SubjectsDerived  -v ds_dc_run -f func/Rest 5502_02
DATE=`date`
echo ${DATE} Step 05
realignfMRI12 -B -M ImagingData/SubjectsDerived -v aMBds_dc_run -f func/Rest 5502_02
DATE=`date`
echo ${DATE} Step 06
coregOverlay -B -M ImagingData/SubjectsDerived/ -o mprage -f func/rest -v r12aMBds_dc_run 5502_02
DATE=`date`
echo ${DATE} Step 07
antsHiRes -a func/Rest/coReg -B -h mprage -w func/Rest/coReg/ANTs_New -M ImagingData/SubjectsDerived/ 5502_02
DATE=`date`
echo ${DATE} Step 08
antsfMRI -B -f func/Rest -h mprage -M ImagingData/SubjectsDerived -on ants -v r12aMBds_dc_ -w coReg/ANTs_New 5502_02
DATE=`date`
echo ${DATE} Step 09
smoothfMRI -B -f func/Rest -M ImagingData/SubjectsDerived -v antsr12aMBds_dc_ 5502_02
DATE=`date`
echo ${DATE} Step 10
newSeg -B -a func/Rest/coReg/ANTs_New -h N4_mprage -w func/Rest/coReg/ANTs_New/newSeg -M ImagingData/SubjectsDerived/ 5502_02
DATE=`date`
echo ${DATE} Step 11
antsfMRI -B -h mprage -M ImagingData/SubjectsDerived -f func/Rest -w coReg/ANTs_New -v c2N4_mprage -in ants -on WM_ants_ 5502_02
DATE=`date`
echo ${DATE} Step 12
antsfMRI -B -h mprage -M ImagingData/SubjectsDerived -f func/Rest -w coReg/ANTs_New -v c3N4_mprage -in ants -on CSF_ants_ 5502_02
DATEStop=`date`

echo
echo Process is all completed and ran from

echo ${DATEStart}
echo ${DATEStop}

