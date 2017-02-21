% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2011
% Copyright.
%
% UMBatchSliceTime
%
% A drivable routine for slice time corretion images using the 
% batch options of spm12
%
%
%  Call as :
%
%  function results = UMBatchSliceTime(Images2SliceTime,fMRI,TestFlag)
%
%  Input
% 
%     Images2SliceTime -- P x c array of file frames from NIFTI or IMG.
%                      
%     fMRI             -- structure with timing information
%
%  REQUIRED
%
%         .TR          -- repetition time       
%
%  THESE AND BELOW HAVE DEFAULTS
%
%        ( .TA          -- acqui time                  (TR-TR/nSlice) CALCUATED )
%         .SliceOrder  -- order of slice acquisition  'ascending','descending',[custom file name],[array]
%         .RefSlice    -- reference slice             'middle','first','last',[number]
%         .Prefix      -- prefix to add to the name   'a_spm12_'
%         .SlicTiming  -- if this is present then it's  MB sequence.
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
%   and "theNIIildCard" is something like "theNIIWildCard = '^run*.nii'"
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchSliceTime(Images2SliceTime,fMRI,TestFlag)

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

fprintf('Entering UMBatchSliceTime V1.0 SPM12 Compatible\n');

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

% Grab the header information to get the number of slices.

tmpHDR = spm_vol(strtrim(Images2SliceTime(1,:)));

matlabbatch{1}.spm.temporal.st.nslices   = tmpHDR.dim(3);

matlabbatch{1}.spm.temporal.st.tr        = fMRI.TR;

% We will calculate TA for them.
% This is usually okay, if a user wants something else
% they will have to let me know - RCWelsh 2013-03-04

% if isfield(fMRI,'TA') == 0
%   fMRI.TA = fMRI.TR-fMRI.TR/matlabbatch{1}.spm.temporal.st.nslices;
% end

fMRI.TA = fMRI.TR-fMRI.TR/matlabbatch{1}.spm.temporal.st.nslices;

matlabbatch{1}.spm.temporal.st.ta       = fMRI.TA;

% Default the slice order if not specified.

if isfield(fMRI,'SliceOrder') == 0
  fMRI.SliceOrder = 'ascending';
  fprintf('Using a default of ascending acquisition\n');
end

% The option is to pass in an order, or ascending or descending or the name of a file.
% Pretty cool to allow all those otions, hopefully won't break. Will need the use 
% of double quotes on the bash command line

if isnumeric(fMRI.SliceOrder) == 0
  fMRI.SliceOrder=strtrim(fMRI.SliceOrder);
  switch lower(fMRI.SliceOrder(1))
   case 'a'
    fMRI.SliceOrder = 1:matlabbatch{1}.spm.temporal.st.nslices;
   case 'd'
    fMRI.SliceOrder = matlabbatch{1}.spm.temporal.st.nslices:-1:1;
   otherwise
    fMRI.SliceOrder = load(fMRI.SliceOrder);
  end
end

if isfield(fMRI,'SliceTiming')
  fprintf('\nMulti-band slice timing correction detected\n');
  minSliceTiming  = min(fMRI.SliceTiming);
  fMRI.SliceOrder = fMRI.SliceTiming;
  if (minSliceTiming) < 0
    fMRI.SliceOrder = fMRI.SliceOrder - minSliceTiming;
    fprintf('Multi-band slice timing being shift by %4.1f\n',minSliceTiming)    
  end
  fprintf('Multi-band slice timing : \n');
  for iOrder = 1:numel(fMRI.SliceOrder)
    fprintf('  %03d : %04.1f\n',iOrder,fMRI.SliceOrder(iOrder));
  end
  fprintf('\n');
end

matlabbatch{1}.spm.temporal.st.so       = fMRI.SliceOrder;

% The reference slice can be "first", "last" or "middle" (default). You can also supply 
% a number, though bounded between 1 and nslice.

if isfield(fMRI,'RefSlice') == 0
  fMRI.RefSlice = 'middle';
  fprintf('Using a default of the middle slice for the reference slice.\n');
end

if isnumeric(fMRI.RefSlice) == 0
  fMRI.RefSlice = strtrim(fMRI.RefSlice);
  switch lower(fMRI.RefSlice(1))
   case 'l'   % The last.
    fMRI.RefSlice = matlabbatch{1}.spm.temporal.st.nslices;
   case 'f'   % The first.
    fMRI.RefSlice = 1;
   otherwise  % The middle
    fMRI.RefSlice = round(matlabbatch{1}.spm.temporal.st.nslices/2);
  end
  % If MB, then the timing is defined by the order
  % specified. 
  % 
  if isfield(fMRI,'SliceTiming')
    SliceTimingInOrder = sort(fMRI.SliceOrder);
    fMRI.RefSlice = SliceTimingInOrder(fMRI.RefSlice);
  end
else
  if fMRI.RefSlice < 1 || fMRI.RefSlice > matlabbatch{1}.spm.temporal.st.nslices
    fprintf('Invalid reference slice\n');
    return
  end
end

matlabbatch{1}.spm.temporal.st.refslice = fMRI.RefSlice;

%if isfield(fMRI,'SliceTiming')
%  matlabbatch{1}.spm.temporal.st.refslice = fMRI.SliceOrder(fMRI.RefSlice);
%end

% Default the prefix if not specified

if isfield(fMRI,'Prefix')  == 0
  fMRI.Prefix = 'a12_';
  if isfield(fMRI,'SliceTiming')
    fMRI.Prefix='aMB_';
  end
end

matlabbatch{1}.spm.temporal.st.prefix   = fMRI.Prefix;

% Now make the list of images to slice time correct.

for iP = 1:size(Images2SliceTime,1)
  pScans{iP,1} = strtrim(Images2SliceTime(iP,:));
end

matlabbatch{1}.spm.temporal.st.scans{1} = pScans;

% All seems ok
if TestFlag == 1
    fprintf('Testing succesful.\n');
    results = toc;
    return
end

% Now look for the options file

if exist([FULLSCRIPTNAME '_options.m'],'file') 
  %
  % Okay the options file exists, so we need to read those in and figure out what to do with them
  %
  fprintf('Found "sliceTime12_options.m (%s)", executing that.\n',[FULLSCRIPTNAME '_options.m']);
  fprintf('- - - - - - - - - - - - - - - - - - - - - -\n')
  try
    run([FULLSCRIPTNAME '_options.m'])
  catch
    fprintf('\n\n\n * * * * * * FAILURE * * * * * *\n');
    fprintf('   ABORTING THIS JOB AS YOUR\n');
    fprintf('   sliceTime12_options.m file\n');
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

% Get the location where the files are located for logging.

sliceTimeDirectory = fileparts(Images2SliceTime(1,:));

% Log what we did.

UMBatchLogProcess(sliceTimeDirectory,sprintf('UMBatchSliceTime : Slice time corrected (%04d) frames   : %s -> %s',size(Images2SliceTime(:,:),1),Images2SliceTime(1,:),fMRI.Prefix));

if size(Images2SliceTime,1) > 1
  UMBatchLogProcess(sliceTimeDirectory,sprintf('UMBatchSliceTime : though                               : %s',Images2SliceTime(end,:)));
end

% Put in a note that this was multi-band corrected.

if isfield(fMRI,'SliceTiming')
  UMBatchLogProcess(sliceTimeDirectory,sprintf('UMBatchSliceTime : multi-band corrected'));
end

% Log how we did this:

if abs(sum(diff(fMRI.SliceOrder))) == matlabbatch{1}.spm.temporal.st.nslices - 1
  if sum(diff(fMRI.SliceOrder)) < 0
    fMRI.order = 'descending';
  else
    fMRI.order = 'ascending';
  end
else
  fMRI.order = 'custom';
end

UMBatchLogProcess(sliceTimeDirectory,sprintf('UMBatchSliceTime : Using TR=%2.2f, TA=%2.2f, Ref=%d, Order:%s',fMRI.TR,fMRI.TA,fMRI.RefSlice,fMRI.order));

results = toc;

fprintf('Slice timing correction done in %f seconds.\n\n\n',results);

return

%
% all done
%


