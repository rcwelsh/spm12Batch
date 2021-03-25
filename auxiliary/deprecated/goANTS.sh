#!/bin/bash

# 2018-02-10

# ANTs pipeline:
# 1) Create Brain Mask
# 2) N4 correct
# 3) Normalize
# 4) Warp TPMs
# 5) Segment

 # Set max number of cores used for this job to 8
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8

# Environment
base="/Users/vincent/Data/Documents/Utah/Kladblok/20170702_ANTs/20180210_FullRun"
T1="${base}/01_Data/A001_01.nii.gz"
name=$(basename "${T1}" | sed 's/\.nii\.gz//g')
log=${base}/full_log.txt

# 1) Create Brain Mask
tDIR="/Applications/ANTs/Templates/MICCAI2012-Multi-Atlas-Challenge-Data"
mDIR="${base}/02_Mask"
mkdir -p ${mDIR}

(time (antsBrainExtraction.sh \
	  -d 3 \
	  -a "${T1}" \
	  -e "${tDIR}/T_template0.nii.gz" \
	  -m "${tDIR}/T_template0_BrainCerebellumProbabilityMask.nii.gz" \
	  -f "${tDIR}/T_template0_BrainCerebellumRegistrationMask.nii.gz" \
	  -o "${mDIR}/ss_${name}_" \
	  -k 0)) \
     2>&1 | tee -a ${log}

# 2) N4 Correct
nDIR="${base}/03_N4"
mkdir -p "${nDIR}"

N4BiasFieldCorrection \
    -d 3 \
    -i "${mDIR}/ss_${name}_BrainExtractionBrain.nii.gz" \
    -o [${nDIR}/N4_${name}.nii.gz,${nDIR}/BF_${name}.nii.gz] \
    -v 1 \
    2>&1 | tee -a ${log}

# 3) Normalize
pDIR="${base}/00_TemplatePriors"
T="${pDIR}/MNI152_T1_1mm_brain.nii.gz"
M="${nDIR}/N4_${name}.nii.gz"
wDIR="${base}/04_Warp"
mkdir -p "${wDIR}"

# Calculate warp using ANTs with SyN
cd ${wDIR}
(time(antsRegistration \
    -d 3 \
    -r [ "${T}" , "${M}" , 1] \
    -m mattes[ "${T}", "${M}" , 1, 32, regular, 0.3] \
        -t translation[ 0.1 ] \
        -c [10000x111110x11110,1.e-8,20]  \
        -s 4x2x1vox  \
        -f 6x4x2 -l 1 \
    -m mattes[ "${T}", "${M}" , 1 , 32, regular, 0.3 ] \
        -t rigid[ 0.1 ] \
        -c [10000x111110x11110,1.e-8,20]  \
        -s 4x2x1vox  \
        -f 3x2x1 -l 1 \
    -m mattes[ "${T}", "${M}" , 1 , 32, regular, 0.3 ] \
        -t affine[ 0.1 ] \
        -c [10000x111110x11110,1.e-8,20]  \
        -s 4x2x1vox  \
        -f 3x2x1 -l 1 \
    -m mattes[ "${T}" , "${M}" , 0.5 , 32 ] \
    -m cc[ "${T}" , "${M}" , 0.5 , 4 ] \
        -t SyN[ .20, 3, 0 ] \
        -c [ 100x100x50,-0.01,5 ]  \
        -s 1x0.5x0vox  \
        -f 4x2x1 -l 1 -u 1 -z 1 \
    -o [ants_,normalizedImage.nii.gz,inverseWarpField.nii.gz] \
    -v 1 )) \
    2>&1 | tee -a ${log}

# 4) Warp TPMs
wtpmDIR="${base}/05_WarpedTPMs"
mkdir -p "${wtpmDIR}"

for i in {1..6}; do

    # Apply registration
    antsApplyTransforms \
        -d 3 \
        -i ${pDIR}/p${i}.nii.gz \
        -r ${T1} \
        -o ${wtpmDIR}/wp${i}.nii.gz \
        -t ${wDIR}/ants_1InverseWarp.nii.gz \
        -t [${wDIR}/ants_0GenericAffine.mat,1] \
        --float \
        -v 1  \
    2>&1 | tee -a ${log}

done

# 5) Atropos segmentation
aDIR="${base}/06_Atropos"
mkdir -p "${aDIR}"

# Create mask
fslmaths \
    ${T1} \
    -bin \
    ${aDIR}/mask.nii.gz

# Run atropos
cd ${aDIR}
(time(antsAtroposN4.sh \
          -d 3 \
          -a "${T1}" \
          -x "${aDIR}/mask.nii.gz" \
          -c 6 \
          -p ${wtpmDIR}/wp%d.nii.gz \
          -o ${aDIR} )) \
    2>&1 | tee -a ${log}

# Restrict segmentations to brain mask
for i in {1..6}; do

    # Mask out
    fslmaths \
        ${aDIR}/SegmentationPosteriors${i}.nii.gz \
        -mas "${mDIR}/ss_${name}_BrainExtractionMask.nii.gz" \
        ${aDIR}/p${i}.nii.gz
done

# Restrict labeled image to brain mask
fslmaths \
    ${aDIR}/Segmentation.nii.gz \
    -mas "${mDIR}/ss_${name}_BrainExtractionMask.nii.gz" \
    ${aDIR}/labels.nii.gz          

exit
