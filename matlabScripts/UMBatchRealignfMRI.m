% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% USA
%
% March 2017
% Copyright.
%
% UMBatchRealignfMRI
%
% A drivable routine for realigning fmri time-series using the 
% batch options of spm12
%
%
%  Call as :
%
%  function results = UMBatchSliceTime(Images2Realign,fMRI,TestFlag)
%
%  Input
% 
%     Images2Realign   -- P x c array of file frames from NIFTI or IMG.
%                      
%     fMRI             -- structure with timing information
%
%  REQUIRED
%
%         .Prefix      -- prefix to add to the name   'r12'
%
%  Output
%  
%     results        = -1 if failure
%                       # of seconds to execute.
%
%
% Hint:
% 
%   To get the list of files to smooth try something like
%
%      P = spm_select('ExtFPList',theDir,theNIIWildCard,[inf])
%
%   where "theDir" is a pointer to the directory of interest,
%   and "theNIIildCard" is something like "theNIIWildCard = '^run.*.nii'"
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchRealignfMRI(Images2Realign,fMRI,TestFlag)

global defaults
global UMBatch
global FULLSCRIPTNAME

% Default return

results = -1;

% Make the call to prepare the system for batch processing.

UMBatchPrep;

if UMBatch == 0
  fprintf('UMBatchPrep failed.')
  results = -70;
  UMCheckFailure(results);
  return
end

% Only proceed if successful.

fprintf('Entering UMBatchRealignfMRI V1.0 SPM12 Compatible\n');

if exist('TestFlag') == 0
    TestFlag = 0;
end

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 

clear matlabbatch

% Start the timer.

tic;

% Setup the job.

% Default the prefix if not specified

if isfield(fMRI,'Prefix')  == 0
  fMRI.Prefix = 'r';
end

% All seems ok
if TestFlag == 1
    fprintf('Testing succesful.\n');
    results = toc;
    return
end

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality  = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep      = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm     = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm      = fMRI.numPasses;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp   = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap     = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight   = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which    = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp   = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap     = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask     = 1;

matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = fMRI.Prefix;

matlabbatch{1}.spm.spatial.realign.estwrite.data              = Images2Realign;

% Now look for the options file

if exist([FULLSCRIPTNAME '_options.m'],'file') 
  %
  % Okay the options file exists, so we need to read those in and figure out what to do with them
  %
  fprintf('Found "realignfMRI12_options.m (%s)", executing that.\n',[FULLSCRIPTNAME '_options.m']);
  fprintf('- - - - - - - - - - - - - - - - - - - - - -\n')
  try
  run([FULLSCRIPTNAME '_options.m'])
  catch
    fprintf('\n\n\n * * * * * * FAILURE * * * * * *\n');
    fprintf('   ABORTING THIS JOB AS YOUR\n');
    fprintf('   realignfMRI12_options.m file\n');
    fprintf('   contains an error\n');
    fprintf(' * * * * * * FAILURE * * * * * *\n\n\n');  
    results = -70;
    UMCheckFailure(results);
    return
  end
  fprintf('- - - - - - - - - - - - - - - - - - - - - -\n');
end

% Run the job.

spm_jobman('run_nogui',matlabbatch);

% Get the location where the reference image is located.

[realignDirectoryMaster,realignFileMaster,~] = fileparts(Images2Realign{1}{1});

% Look for the mean image -- which should be there unless the user overrode with 
% the "_options.m" file or the "-m" option on the command line.

refImage = spm_select('ExtFPList',realignDirectoryMaster,['^mean' realignFileMaster '.nii'],[1]);

if fMRI.numPasses == 0
  refImage = Images2Realign{1}{1};
end

% Log what we did.

for iRun = 1:numel(Images2Realign)
  % Get the location where the files are located for logging.
  [realignDirectory,~,~] = fileparts(Images2Realign{iRun}{1});
  
  UMBatchLogProcess(realignDirectory,sprintf('UMBatchRealignfMRI : Realigned (%04d) frames : %s -> %s',numel(Images2Realign{iRun}),Images2Realign{iRun}{1},fMRI.Prefix));
  
  if numel(Images2Realign{iRun}) > 1
    UMBatchLogProcess(realignDirectory,sprintf('UMBatchRealignfMRI : though                  : %s',Images2Realign{iRun}{end}));
  end
  UMBatchLogProcess(realignDirectory,sprintf('UMBatchRealignfMRI : Realign target          : %s',refImage));
  UMBatchLogProcess(realignDirectory,sprintf('UMBatchRealignfMRI : Number of passes=%d ',fMRI.numPasses+1));
end

% Log how we did this:

results = toc;

fprintf('Realignment of time-series done in %f seconds.\n\n\n',results);

return

%
% all done
%


