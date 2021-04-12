# spm12Batch

#### An ecosystem for doing pre-processing of fMRI data in a flexible and reproducible manner.

**spm12Batch** provides suite of **bash** commands for interacting with neuroimaging processing software. The purpose of this suite is to provide automated processing pipeline elements to take BOLD (T2*) data from participant space to MNI space. The tool utilizes various neuroimaging software packages which are freely available.

#### My apologies in advance for some scripts that have been deprecated but not removed as yet.

The suite of commands are written in bash, and will work in a MAC OS X (Intel based) and LINUX/UNIX operating environment.

This system runs on _bare metal_ and not in _docker_. This system uses a simplified data organization scheme. See the documentation for the scheme. It relies on generic names for your folders and files. The only thing that is unique is the name of the session (participant) folder. This allows the pipeline to interact with SPM in a straight-forward manner.

To correctly use, in addtion to [MATLAB](https://www.mathworks.com), you will need to have installed the following software on your system:

1. [SPM](https://www.fil.ion.ucl.ac.uk/spm/)
2. [ANTs](http://stnava.github.io/ANTs/)
3. [Anima](https://anima.readthedocs.io/en/latest/)
4. [AFNI](https://afni.nimh.nih.gov)
5. [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)

Each step is single command. Each command takes various parameters to override default assumptions. The command can also accept a list of sessions to run. The processes default to running in the background, but can be configured to run in the foreground. By running in the foreground, you can also daisy chain the steps together. If you computer system allows for email, look at the **spm12Batch_Global** variable **MAILRECPT** to ensure it is correct. You can configure the system such that emails can be generated at job completion. The system, if configured correctly, can also send text messages at job completion. To attempt that configuration you will need some system administration experience. 

![overview0](https://github.com/rcwelsh/spm12Batch/blob/main/Documentation/spm12Batch-Pipeline/spm12Batch-Pipeline.005.png)

The philosophy of this suite is to provide automated functionality with flexibility. Flexibility is found with respect to ordering of steps, naming of files, and folder organization, and does not require a rigid system. An additional philosophy is that once a script is run, it should not be run again as it becomes part of the documentation on how you have processed your data.

The purpose of the suite is to provide rapid processing with **_extensive documentation and logging of processes_**, and more control of pre-processing to the investigator. A given step of the pre-processing is run prior to the next step. Typically one would run a bunch of sessions for a single step. That is, 10 sessions could be processed in the **_distortionCorrect_** step.

A typical pipeline is shown here:

![overview1](https://github.com/rcwelsh/spm12Batch/blob/main/Documentation/spm12Batch-Pipeline/spm12Batch-Pipeline.012.png)

Full documentation is found in the **Documentation/** sub-folder.

In summary,

* Distortion correction (**_distortionCorrect_**) uses the Anima software to correct EPI using a pseudo field-map, the results can be sent to a new directory tree to keep processing output separate from input.
* To move other necessary data from the input area to the derivatives (processed area), such as anatomy images, you use the **_prepDerivatives_**.
* You can then remove spikes in you data using the AFNI 3dDespike command by invoking **_despikeAFNI_**.
* Slice-time correction is then executed for non-SMS data (**_sliceTime12_**) or for SMS/Multi-band data (**_sliceTimeMB_**). Both commands use SPM.
* Motion correction is done with SPM using **_realignfMRI12_**.
* To get the data into normalized space, the high-resolution image (such as a MPRAGE, SPGR, etc) is co-registered (using SPM) to the resulting motion corrected data with **_coregOverlay_**.
* Normalization is invovoked with **_antsHiRes_** and uses the ANTs suite of commands. You can also opt to use SPM for normalization using **_newSeg_**.
* BOLD data is the taking to normalized space with **_antsfMRI_**. If you use **_newSeg_**, then instead of **_antsfMRI_** you would invoke **_warpSeg_** to take BOLD to MNI.
* Resulting BOLD data can be smoothed using SPM by invoking **_smoothfMRI_**.
* If you need tissue segementation, such as to use with [COMPCOR](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2214855/) and want WM and CSF segments, I have found that SPM does a better job on segmentation, so then you'd invoke **_newSeg_** but have the N4 bias corrected data from the **_antsHiRes_** as the input. After that you would then invoke **_antsfMRI_** in a manner for it to pick up the SPM derived tissue segments.

To see an example of how these calls can be further automated look in the **BatchExamples/** sub-folder. The examples are extra scripts for building jobs more automatically for a given step. The **_launch\_..._** scripts are written with flexibility to process a group of sessions sequentially or in parallel based on your computational resources.

**If you use this software, please place an acknowledgment in your manuscript to _Robert C. Welsh_, _spm12Batch_, and this page, and also indicate that this software was developed with partial support from NIH R01NS052514 (Welsh) and R01NS082304 (Welsh). Please drop me a note if you find it useful.**

Finally, the system is easily extendable. If a new pre-processing step is needed to be added, the ecosystem can be modified to accept a new command. Please contact me if you feel a new command, within the context of spm12Batch, is needed. It usually takes only 4-6 hours to build a new command.

_Enjoy!_

Robert Welsh

Copyright 2021 Robert Cary Welsh, All rights reserved. See LICENSE file for more details.

