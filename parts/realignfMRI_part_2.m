
% --------------- BEGINNING OF PART II ----------------------
%
% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

%
% Loop over the subjects and realign each subject and each run independently 
%

% The runs need to all be moved to one directory for proper realignment
% and we need to make sure there are no name conflicts. 
% For now skip using the sandbox.

curDIR = pwd;

warning off

for iSub = 1:length(UMBatchSubjs)
  WorkingSubject = [deblank(UMBatchMaster) '/' UMBatchSubjs{iSub}];
  % Make the list of images
  Images2Write = cell(1,numel(UMImgDIRS{iSub}));
  for iRun = 1:length(UMImgDIRS{iSub})
    Images2Write{iRun} = cellstr(spm_select('ExtFPList',UMImgDIRS{iSub}{iRun},['^' UMVolumeWild '.*.' UMVolumeExt],inf));
    fprintf('Realignment correcting %d "%s" images in %s \n',numel(Images2Write{iRun}),UMVolumeWild,UMImgDIRS{iSub}{iRun});
  end
  results = UMBatchRealignfMRI(Images2Write,UMfMRI,UMTestFlag);
  if UMCheckFailure(results)
    exit(abs(results))
  end
  %
  % Plot the movement parameters, added 2020-06-17/23 - RCWelsh
  % 
  for iRun = 1:length(UMImgDIRS{iSub})
    sessionName            = UMBatchSubjs{iSub};
    [realignDirectory,~,~] = fileparts(Images2Write{iRun}{1});
    runName                = regexp(UMImgDIRS{iSub}{iRun},filesep,'split');
    runName                = runName{end};
    [results]              = UMBatchPlotSPMMoveParam(sessionName,realignDirectory,UMFuncDir,runName,UMVolumeWild);
    if results ~= 0
      fprintf('Error in plotting results for %s %s %s %s %s\n',sessionName,realignDirectory,UMFuncDir,runName,UMVolumeWild);
    else
      fprintf('Plotted movement parameters for %s %s %s %s %s\n',sessionName,realignDirectory,UMFuncDir,runName,UMVolumeWild);
    end    
    
  end  
end

fprintf('\nAll done with realigning fMRI images images.\n');

cd(curDIR);

%
% all done.
%
