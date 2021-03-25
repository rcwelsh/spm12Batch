#!/bin/bash
#
# Example script to process a subject from start to finish using spm12Batch
#
# The spm12Batch calls can be done sequentially here as the -B flag is used in each.
# That tells each command to run in the foreground, allowing the commands to be daisy-chained together.
# The output status of the command is not being checked though.
#
# This is an example of using SPM normalization instead of ANTs, in the other script 7 and 8 are replaced
# with these below, and then Step 10 and Step 11 are omitted.
#
# Robert Welsh
# robert.c.welsh@utah.edu
#
# 2021-03-25

DATEStart=`date`
DATE=`date`
echo ${DATE} Step 07-alt
newSeg -a func/Rest/coReg -B -h mprage -w func/Rest/coReg/newSeg -M ImagingData/SubjectsDerived/ 5502_02
DATE=`date`
echo ${DATE} Step 08-alt
warpSeg -B -f func/Rest -h mprage -M ImagingData/SubjectsDerived -on ns -v r12aMBds_dc_ -w coReg/newSeg 5502_02
DATEStop=`date`

echo
echo Process is all completed and ran from

echo ${DATEStart}
echo ${DATEStop}

