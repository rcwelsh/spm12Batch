# # # # # # # # # # # # # # # # # #
#
# This is a modified version of the spm12Batch processing system written by Robert C. Welsh.
#
# Copyright 2002-2021, All rights reserved.
#
# No warranties or guarantees are made. 
#
# Though every effort is made to make this error free, that in itself is an impossiblility and thus this is a:
#
#         "Use at your own risk software package."
#
# -------------
#
# This code was developed on a MacBook Pro using the BASH language. It relies upon spm12 and FSL
#
# If need be you may get these from:
#
# 1. SPM	https://www.fil.ion.ucl.ac.uk/spm/
# 2. ANTs	http://stnava.github.io/ANTs/
# 3. Anima	https://anima.readthedocs.io/en/latest/
# 4. AFNI	https://afni.nimh.nih.gov
# 5. FSL	https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
#
# You will need to have packages 2-5 installed and accessible via your PATH environmental variable.
#
# -----------------------------------------------------------------
# -----------------------------------------------------------------
#
# INSTALLATION INSTRUCTIONS:
#
#
# You will need to adjust your PATH environmental variable to include
# the spm12Batch distribution
#
# You can do this on the fly by running "source spm12Setup" while in this directory.
# You can also edit your .bashrc, .bash_profile, or /etc/bashrc startup scripts to source this automatically
# for all or just some users.
#
# 
# Remember the native language of the spm12Batch system is bash. An
# excellent site for BASH help is:
# 
#     http://tldp.org/LDP/abs/html/
#
# You will need to have spm12 distribution (Included in this distribution)
#
#
# FILE FORMATS
# 
# The code can only use NIFTI images (.nii), and not NIFTI_GZ (an SPM limitation)
#
# HELP
# 
# Look in Documentation/
#
#
#
# -----------------------------------------------------------------
# -----------------------------------------------------------------
#
# LOCALIZATION (No longer needs to be edited. This section retained for developer documentation)
#
# The only file that has to be modified for local distrubution is the scripts "spm12Batch_Global"
# 
# The distribution relies on the integrity of the directory structure of the code, DO NOT MOVE ANYTHING
# from the distrubuted organization else you will BREAK the code.
#  
# -------------
#
# (The other script spm12Setup is if you don't have spm12Batch as the default and you want to add it.)
#
# You will need to go through the spm12Batch_Global and change the following definitions:
# 
# (each section is marked by "*")
#
# *I)
#
# topDIR - this should be the parent directory, typically it's your directory where 
#          all local software scripts reside.
#
# SPM12B1 - should point to the matlab code for SPM12, current version is Revision 4290
# SPM12B2 - should point to the directory where the spm12Batch resides
# SPM12B3 - needs to point to the matlabScripts directory in spm12Batch
#
# AUXPATH - any local patches you want to invoke
#
# The localisation script makes an assumption that the paths are as follows:
# 
#             topDIR/
#
#                 SPM12B1/
#                 SPM12B2/
#                 SPM12B3/
#                 AUXPATH/
#  
# If you have something other than above you will need to make the appropriate adjustments to
# the spm12Batch_Global script. There is not actually need to define everything based on 
# topDIR, just makes it neater if you do.
#
# *II)
#
# If you experience slow access to your data because it may reside on a NAS device, than you 
# may want to consider the use of a sandbox. The sandbox is a local directory that everybody can 
# read and write to that the code will pull certain files into to operate locally and then move
# the results back to the originating directory.
#
# See : http://en.wikipedia.org/wiki/Sandbox_(software_development)
#
# SANDBOXUSE
#
# *III)
#
# The user name of the local owner of the code needs to be defined.
#
# LOCALOWNER
#
# You need to specify the name of the mail ip address. The code will send email when certain processes are 
# finished, the email address used is typically the user name for the current login at the MAILRECPT address.
#
# *IV) 
#
# MAILRECPT
#
# *V) 
#
# This is typically set to "${USER}"
#
# DEFAULTUSER
#
# *VI)
#
# These are what default MNI space you want to use for normalization processes etc.
#
# TemplateImageDir
# TemplateImageFile
#
# *VII)
#
# You need to define the location of MATLAB
#
# MATLAB
#
#
#
# # # # # # # # # # # # # # # # # #
