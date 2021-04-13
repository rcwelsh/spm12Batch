# Data Organization

The **spm12Batch** system allows for some flexibility in data organization. In general, though, the suggested orgaznization is:

```
[experiment directory]
    Scripts/
    matlabScripts/
    ImagingData/
        Subjects/
	    [session]/
	        anatomy/
		    hiRes.nii
		    loRes.nii
		func/
		    [task1]/
		        fieldMap/
			    forwardImage.nii
			    backwardImage.nii
		        run_01/
			    run_01.nii
			run_02/
			    run_02.nii
		    [task1]/
	     		fieldMap/
			    forwardImage.nii
			    backwardImage.nii
		        run_01/
			    run_01.nii
			run_02/
			    run_02.nii
...
```


An example is:

```
MIND2014
    Scripts/
    matlabScripts/
    ImagingData/
        Subjects/
	    A001_01/
	        anatomy/
		    hiRes.nii
		    loRes.nii
		func/
		    Connect/
		        fieldMap/
			    forwardImage.nii
			    backwardImage.nii
		        run_01/
			    run_01.nii
			run_02/
			    run_02.nii
		    MID/
	     		fieldMap/
			    forwardImage.nii
			    backwardImage.nii
		        run_01/
			    run_01.nii
			run_02/
			    run_02.nii
```

In general, the default structure can be overriden with option flags to the commands. The one caveat is that when the code is searching for BOLD data and you specifify the **-v** flag, it will always do a _grep_ command searching for files that **start** with what you have specified. This is in compliance with how SPM processes and creates new data files.