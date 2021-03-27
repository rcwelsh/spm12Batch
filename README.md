# spm12Batch

#### An ecosystem for doing pre-processing of fMRI data in a flexible, and reproducible manner.

**spm12Batch** provides suite of **bash** commands for interacting with neuroimaging processing software. The purpose of this suite is to provide an automated processing pipeline elements to take BOLD (T2*) data from participant space to MNI space. The tool utilizes various of freely available neuroimaging software.

The suite of commands are written in bash, and will work in a MAC OS X (Intel based) and LINUX/UNIX operating environment.

This system runs on _bare metal_ and not in _docker_.

To correctly use, you will need to have installed the following software on your system:

1. [SPM](https://www.fil.ion.ucl.ac.uk/spm/)
2. [ANTs](http://stnava.github.io/ANTs/)
3. [Anima](https://anima.readthedocs.io/en/latest/)
4. [AFNI](https://afni.nimh.nih.gov)
5. [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki)

A typical pipeline is shown here:

![overview1](https://github.com/rcwelsh/spm12Batch/blob/main/Documentation/spm12Batch-Pipeline/spm12Batch-Pipeline.010.png)

The philosophy of this suite is to provide automated functionality with flexibility. Flexibility is found with respect to ordering of steps, naming of files, and folder organization, and does not require a rigid system.

The purpose of the suite is to provide rapid processing, and more control of pre-processing to the investigator.

Each step is single command. Each command takes various parameters to override default assumptions. The command can also accept a list of sessions to run. The processes default to running in the background, but can be configured to run in the foreground. By running in the foreground, you can also daisy chain the steps together.

Full documentation is found in the **Documentation/** sub-folder.

In summary,

* distortion correction (_distortionCorrect_) uses the Anima software to correct EPI using a pseudo field-map, the results can be sent to a new directory tree to keep processing output separate from input.
* to move other necessary data from the input area to the derivatives (processed area), such as anatomy images, you use the _prepDerivatives_ command.

_Enjoy!_

Robert Welsh

robert.c.welsh (at) utah (dot) edu
