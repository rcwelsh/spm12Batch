% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% USA
%
% March 2005-2017
% Copyright.
%
% UMBatchLogProcess
%
% This will write a hidden file in the "loggingDirectory" with the
% name of the current process and place the name of the job into
% the file with date/time stamp.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchLogProcess(loggingDirectory,loggingComment)

global UMBatchJobName
global UMBatchProcessName

if isempty(UMBatchProcessName)
    UMBatchProcessName='commandLineCall';
end

if isempty(UMBatchJobName)
    UMBatchJobName='commandLineCall';
end

% Get matlab version and spm versions.

mVersion = ver('MATLAB');
mVersion = ['matlab/' mVersion.Release];

spmVersion = spm('version');

loggingFile=fullfile(loggingDirectory,sprintf('.%s',UMBatchProcessName));

try
  theFID = fopen(loggingFile,'a');
  theDATE=date;
  theTIME=sprintf('%4d %2d %2d %2d %2d %2d',round(clock));
  fprintf(theFID,'%s : %s : %s : %s : %s : %s\n',UMBatchJobName,theDATE,theTIME,mVersion,spmVersion,loggingComment);
  fclose(theFID);
catch
  fprintf('\n* * * * * * * * * * * *\n');
  fprintf('Error trying to right log file %s\n',loggingFile);
  fprintf('\n* * * * * * * * * * * *\n');
end

return

%
% All done.
%