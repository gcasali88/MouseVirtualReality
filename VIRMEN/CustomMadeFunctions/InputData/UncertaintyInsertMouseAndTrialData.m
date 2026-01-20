function [ vr ] = UncertaintyInsertMouseAndTrialData( vr )
%Mouse details requested on pop up window

if strcmp(getenv('COMPUTERNAME'),'DESKTOP-EGHM5PR');
    vr.Setup = 2;
elseif strcmp(getenv('COMPUTERNAME'),'423-ALEXBOSS');
    vr.Setup = 1;
elseif strcmp(getenv('COMPUTERNAME'),'8V25CD2');
    vr.Setup = 3;
end

%% Set windows
vr = SetWindowsSetup(vr);

%%%%%%%%%%%%
vr.TrialInfo.Prompt = {'Mouse:' 'Experiment:' 'World (A, B, C):' 'Level of Uncertainty (Low, Medium, High):' 'Date:' 'Session:' 'Max Trial Length (min):' 'Max Number of Trials:'};% 'Detect licking:' 'Valve Open for (ms):' 'Reward Speed onset:' 'Max Trial Length (min):' 'Max Number of Trials:' 'Include Licking Criteria:'};
dlg_title = 'Trial';
num_lines = 1;


if exist('Answers.mat ','file')==2;
vr.RunExperiment = 1;%transpose(fread(fopen('ProduceTextrue.data'),[3,Inf],'double'))
else
vr.RunExperiment = 0;
end;

if vr.RunExperiment;
    load ('Answers')
    vr.TrialInfo.Answers = Answers.TrialInfo;
else
    defaultans = {'mx', vr.Experiment, 'A', 'Low', '20170125' '1' '60' '100' num2str(vr.Setup)};
    vr.TrialInfo.Answers = inputdlg(vr.TrialInfo.Prompt,dlg_title,num_lines,defaultans);
end
end


