% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% USA
%
% March 2017
% Copyright.
%
% UMBatchNewSeg
%
% A drivable routine for warping some images using the 
% batch options of spm12.
%
% Version 1.0
% 
%  Call as :
%
%  function results = UMBatchWarpSeg(ParamImage,Images2Write,TestFlag,VoxelSize,OutputName);
%
%  To Make this work you need to provide the following input:
%
%     ParamImage       = Image to determine warping parameters.
%     TestFlag         = Flag to test file existance but do nothing.
%
%    If the TemplateImage is blank then we are doing "Write Normalized Only"
%  
%    If Images2Write is blank then we are doing "Determine Parameters Only"
%
%    If ObjectMask = [] or '' then no masking.
%
%    ParamImage CAN NOT BE BLANK and must exist, as must its "_sn.mat" file.
%
%    If TestFlag   = 0 then execute, else just test files.
%
%  Output
%  
%     results        = -1 if failure
%                       # of seconds to execute.
%
%  If you wish to use any normalization parameters other than the default
%  you must set them yourself!
%
%  You should make call to UMBatchPrep first.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchWarpSeg(ParamImage,Images2Write,TestFlag,VoxelSize,OutputName)

% Get the defaults from SPM.

global defaults
global UMBatch
global FULLSCRIPTNAME

%
% Set the return status to -1, that is error by default.
%

results = -1;

% Make the call to prepare the system for batch processing.

UMBatchPrep

if UMBatch == 0
  fprintf('UMBatchPrep failed.')
  results = -70;
  UMCheckFailure(results);
  return
end

% Only proceed if successful.

fprintf('Entering UMBatchWarpSeg V1.0 SPM12 Compatible\n');

if TestFlag~=0
  fprintf('\nTesting only, no work to be done\n\n');
end 


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%
% Make sure that the ParamImage is there.
%

ticStart = tic;

if isempty(ParamImage) | exist(ParamImage) == 0
  fprintf('\n\nThe Parameter Image Must EXIST!\n');
  fprintf('  * * * A B O R T I N G * * *\n\n');
  results = -65;
  UMCheckFailure(results);
  return
end

clear matlabbatch

% Get the directory of this file we are working upon.

[ParamDir ParamImageName ParamImageExt] = fileparts(ParamImage);

cd(ParamDir);

% Convert the character array in a cell array

Images2Write = cellstr(Images2Write);

matlabbatch{1}.spm.spatial.normalise.write.subj.def = {fullfile(ParamDir,['y_' ParamImageName ParamImageExt])};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = Images2Write;
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
		    78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1]*VoxelSize;
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = OutputName;

% Now look for the options file

if exist([FULLSCRIPTNAME '_options.m'],'file') 
  %
  % Okay the options file exists, so we need to read those in and figure out what to do with them
  %
  fprintf('Found "warpSeg_options.m (%s)", executing that.\n',[FULLSCRIPTNAME '_options.m']);
  fprintf('- - - - - - - - - - - - - - - - - - - - - -\n')
  try
    run([FULLSCRIPTNAME '_options.m'])
  catch
    fprintf('\n\n\n * * * * * * FAILURE * * * * * *\n');
    fprintf('   ABORTING THIS JOB AS YOUR\n');
    fprintf('   newSeg_options.m file\n');
    fprintf('   contains an error\n');
    fprintf(' * * * * * * FAILURE * * * * * *\n\n\n');  
    results = -70;
    UMCheckFailure(results);
    return
  end
  fprintf('- - - - - - - - - - - - - - - - - - - - - -\n');
end

if TestFlag == 0
  % Now call the batch manager.
  
  spm_jobman('run_nogui',matlabbatch);
  
  % Log the first file, and then log subsequent files as long as they have different 
  % names, this way we don't log all of the time-series one-by-one.
  
  [ImageDirectoryPrev ImageNamePrev ImageExtPrev] = fileparts(Images2Write{1});
  
  UMBatchLogProcess(ImageDirectoryPrev,sprintf('UMBatchWarpSeg : WarpSeg processed : %s %s',ParamImage,Images2Write{1}));

  for iImg = 2:numel(Images2Write)
    
    % Log that we finished this portion.
    
    [ImageDirectory ImageName ImageExt] = fileparts(Images2Write{iImg});
    
    if ~strcmp(fullfile(ImageDirectoryPrev,ImageNamePrev),fullfile(ImageDirectory,ImageName))           
      UMBatchLogProcess(ImageDirectory,sprintf('UMBatchWarpSeg : WarpSeg processed : %s %s',ParamImage,Images2Write{iImg}));
    end
    ImageDirectoryPrev = ImageDirectory;
    ImageNamePrev      = ImageName;
  end
end

%
% Set the flag to the amount of time to execute.
%

results = toc(ticStart);

fprintf('Deformation finished in %f seconds\n',results);

return

%
% All done.
%
