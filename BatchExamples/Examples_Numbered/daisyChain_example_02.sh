#!/bin/bash

# This is Example 02
#
# This will go through each step of the preprocessing for 1 test subject.
#
# The processing will be done in the foreground through the "-B" flag that turns
# off the background processing (which is default to be on).
#

# You can download the data from 

startDate=`date`

DATE=`date`
echo "${DATE} : ${USER} : distortionCorrect -B -M ImagingData/Subjects -MO ImagingData/SubjectsDerived -bi FM_AP -fi FM_PA -fm fieldMap -f func/Rest -on dc_ -v run TestSubject"
distortionCorrect -B -M ImagingData/Subjects -MO ImagingData/SubjectsDerived -bi FM_AP -fi FM_PA -fm fieldMap -f func/Rest -on dc_ -v run TestSubject

DATE=`date`
echo "${DATE} : ${USER} : prepDerivatives -B -M ImagingData/Subjects -MO ImagingData/SubjectsDerived/ -inc anatomy/mprage_noFace TestSubject"
prepDerivatives -B -M ImagingData/Subjects -MO ImagingData/SubjectsDerived/ -inc anatomy/mprage_noFace TestSubject

DATE=`date`
echo "${DATE} : ${USER} : despikeAFNI -B -M ImagingData/SubjectsDerived -f func/Rest -on ds_ -v dc_run TestSubject"
despikeAFNI -B -M ImagingData/SubjectsDerived -f func/Rest -on ds_ -v dc_run TestSubject

DATE=`date`
echo "${DATE} : ${USER} : sliceTimeMB -B -M ImagingData/SubjectsDerived -f func/Rest -on aMB_ -v ds_dc_run TestSubject"
sliceTimeMB -B -M ImagingData/SubjectsDerived -f func/Rest -on aMB_ -v ds_dc_run TestSubject

DATE=`date`
echo "${DATE} : ${USER} : realignfMRI12 -B -M ImagingData/SubjectsDerived -f func/Rest -on r12_ -v aMB_ds_dc_run TestSubject"
realignfMRI12 -B -M ImagingData/SubjectsDerived -f func/Rest -on r12_ -v aMB_ds_dc_run TestSubject

DATE=`date`
echo "${DATE} : ${USER} : coregOverlay -B -M ImagingData/SubjectsDerived -f func/Rest -o mprage_noFace -v r12_aMB_ds_dc_run TestSubject"
coregOverlay -B -M ImagingData/SubjectsDerived -f func/Rest -o mprage_noFace -v r12_aMB_ds_dc_run TestSubject

DATE=`date`
echo "${DATE} : ${USER} : antsHiRes -B -M ImagingData/SubjectsDerived -a func/Rest/coReg -h mprage_noFace -w func/Rest/coReg/ANTs TestSubject"
antsHiRes -B -M ImagingData/SubjectsDerived -a func/Rest/coReg -h mprage_noFace -w func/Rest/coReg/ANTs TestSubject

DATE=`date`
echo "${DATE} : ${USER} : antsfMRI -B -M ImagingData/SubjectsDerived -f func/Rest -h mprage_noFace -on ants_ -v r12_aMB_ds_dc_run -w coReg/ANTs TestSubject"
antsfMRI -B -M ImagingData/SubjectsDerived -f func/Rest -h mprage_noFace -on ants_ -v r12_aMB_ds_dc_run -w coReg/ANTs TestSubject

DATE=`date`
echo "${DATE} : ${USER} : smoothfMRI -B -M ImagingData/SubjectsDerived -f func/Rest -v ants_r12_aMB testSubject"
smoothfMRI -B -M ImagingData/SubjectsDerived -f func/Rest -v ants_r12_aMB testSubject

endDate=`date`

echo
echo "Started  : ${startDate}"
echo "Finished : ${endDate}"
echo
