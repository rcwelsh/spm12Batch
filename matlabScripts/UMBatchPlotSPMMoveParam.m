% - - - - - - - - - - - - - - - - - - - -
%
% Robert Welsh
% 2020-06-17
%
% To be called my realignfMRI_part_2.m portion of spm12Batch for
% realignfMRI12
%
% robert.c.welsh@utah.edu
%
% - - - - - - - - - - - - - - - - - - - -

function results = UMBatchPlotSPMMoveParam(sessionName,outputDirectory,fmriPATH,runName,UMVolumeWild)

% Default is success.

results = 0;

try
    sessionNameF = '';
    for iChar = 1:numel(sessionName)
        if strcmpi(sessionName(iChar),'_')
            sessionNameF = [sessionNameF '\_'];
        else
            sessionNameF = [sessionNameF sessionName(iChar)];
        end
    end
    
    runNameF = '';
    for iChar = 1:numel(runName)
        if strcmpi(runName(iChar),'_')
            runNameF = [runNameF '\_'];
        else
            runNameF = [runNameF runName(iChar)];
        end
    end
    
    fmriPATHF = '';
    for iChar = 1:numel(fmriPATH)
        if strcmpi(fmriPATH(iChar),'_')
            fmriPATHF = [fmriPATHF '\_'];
        else
            fmriPATHF = [fmriPATHF fmriPATH(iChar)];
        end
    end
    
    rpFile = dir(fullfile(outputDirectory,sprintf('rp_*%s*.txt',UMVolumeWild)));
    rp     = load(fullfile(outputDirectory,rpFile.name));
    
    figure;
    subplot(2,1,1);
    p1 = plot(rp(:,1:3));
    grid on;
    ylabel('translation (mm)','fontsize',14,'fontweight','bold');
    legend('x','y','z','location','northwest');
    title(sprintf('%s : %s : %s : %s',date,sessionNameF,fmriPATHF,runNameF),'fontsize',14,'fontweight','bold');
    subplot(2,1,2);
    p2 = plot(rp(:,4:6)*180/pi);
    legend('pitch','roll','yaw','location','northwest');
    grid on;
    ylabel('rotation (degrees)','fontsize',14,'fontweight','bold');
    xlabel('TR #','fontsize',14,'fontweight','bold');
    
    set(get(p1(1),'parent'),'fontsize',14,'fontweight','bold');
    set(get(p2(1),'parent'),'fontsize',14,'fontweight','bold');
    pngFile = fullfile(outputDirectory,sprintf('movement_%s_%s.png',sessionName,runName));
    
    print(pngFile,'-dpng');
    
catch
    results = -1;
    return
end

return

%
% All done.
%