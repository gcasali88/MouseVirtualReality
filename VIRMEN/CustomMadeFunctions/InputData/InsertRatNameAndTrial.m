function vr=InsertRatNameAndTrial(vr)
vr.TrialInfo.Prompt = {'Mouse:' 'Experiment:' 'Date:' 'Session:' 'Max Trial Length (min):' 'Max Number of Trials:' 'VRSETUP'};% 'Detect licking:' 'Valve Open for (ms):' 'Reward Speed onset:' 'Max Trial Length (min):' 'Max Number of Trials:' 'Include Licking Criteria:'};
dlg_title = 'Trial';
num_lines = 1;
%vr.ComputerName = getenv('COMPUTERNAME');
if strcmp(getenv('COMPUTERNAME'),'DESKTOP-EGHM5PR');
    vr.Setup = 2;
    vr.Path = ['C:\Users\Giulio\Documents\'];
    vr.FileStorePath = ['S:\DBIO_BarryLab_DATA\giulioC\Data\VR\'];
    vr.NIDev = 2;
elseif strcmp(getenv('COMPUTERNAME'),'DESKTOP-MLE6SKL');
    vr.Setup = 1;
    vr.Path = ['C:\Users\VR1\Documents\'];
    vr.FileStorePath = ['S:\DBIO_BarryLab_DATA\giulioC\Data\VR\'];
    vr.NIDev = 1;
elseif strcmp(getenv('COMPUTERNAME'),'8V25CD2');
    vr.Setup = 3;
else
    vr.Setup = 4;
end
defaultans = {'mx', vr.Experiment '20170130' '1' '60' '100' num2str(vr.Setup)};

vr.TrialInfo.Answers = inputdlg(vr.TrialInfo.Prompt,dlg_title,num_lines,defaultans);

end