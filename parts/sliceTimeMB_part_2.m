
% --------------- BEGINNING OF PART II ----------------------
%
% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

%
% Loop over the subjects and slice time correct each subject and each run independently 
%

curDIR = pwd;

warning off

for iSub = 1:length(UMBatchSubjs)
  WorkingSubject = [deblank(UMBatchMaster) '/' UMBatchSubjs{iSub}];
  for iRun = 1:length(UMImgDIRS{iSub})
    cd(UMImgDIRS{iSub}{iRun});
    %
    % Find out if they are using a sandbox for the slice timing.
    %
    % Get the slice-timeing information for multi-band
    %
    sliceTimingFile = spm_select('List',UMImgDIRS{iSub}{iRun},['^' UMVolumeWild '.*.sliceTiming']);
    if isempty(sliceTimingFile)      
      fprintf('Slice timing (MB) fairure, for directory %s\n',UMImgDIRS{iSub}{iRun});
      fprintf('Slice timing (MB) fairure, cannnot find the slicetiming file %s.*.sliceTiming\n',UMVolumeWild);
      results = -1;
      if UMCheckFailure(results)
	exit(abs(results))
      end
    end    
    UMfMRI.SliceTiming = load(fullfile(UMImgDIRS{iSub}{iRun},sliceTimingFile));
    %
    [CS SandBoxPID Images2Write] = moveToSandBox(UMImgDIRS{iSub}{iRun},UMVolumeWild,SandBoxPID,UMVolumeExt);
    %P = spm_select('ExtFPList',UMImgDIRS{iSub}{iRun},['^' UMVolumeWild '.*.nii'],inf);
    fprintf('Slice time correcting (MB) %d "%s" images in %s \n',size(Images2Write,1),UMVolumeWild,UMImgDIRS{iSub}{iRun});
    results = UMBatchSliceTime(Images2Write,UMfMRI,UMTestFlag);
    if UMCheckFailure(results)
      exit(abs(results))
    end
    %
    % Now move back out of sandbox if so specified
    %
    CSBACK = moveOutOfSandBox(UMImgDIRS{iSub}{iRun},UMVolumeWild,SandBoxPID,OutputName,CS);
  end
end

fprintf('\nAll done with slicetime correcting images.\n');

cd(curDIR);

%
% all done.
%
