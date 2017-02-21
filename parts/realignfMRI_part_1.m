% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Copyright Robert C. Welsh
% 2017
% 
% This is to be used with the UMBatch System for SPM12.
%
% This is to Realign Time-Series Images
%
% You must point to the batch processing code
%
%  spm12
%  spm12Batch
%
%
% You need to fill the following variables:
%
%   UMBatchMaster  =   point to the directory of the experiment.
%
%   UMBatchSubjs   =   list of subjects within experiment. Space
%                      pad if need be.
%
%
%   UMImgDIRS      =   directory to which to find images.
%                      (full path name)
%
%   UMVolmeWild    =   wild card name for images
%                      (e.g. "arun_*.nii')
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Make sure the UM Batch system is installed.

if exist('UMBatchPrep') ~= 2 | exist('UMBatchRealignfMRI') ~= 2
    fprintf('You need to have the UM Batch system\n');
    results = -69;
    UMCheckFailure(results);
    exit(abs(results))
end

% 
% Prepare the batch processes
%

results = UMBatchPrep;

if UMCheckFailure(results)
  exit(abs(results))
end

% --------------- END OF PART I ----------------------
