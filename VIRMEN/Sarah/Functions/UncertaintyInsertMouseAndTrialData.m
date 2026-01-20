function [ vr ] = InsertMouseAndTrialData( vr )
%Mouse details requested on pop up window

vr.TrialInfo.Prompt = {'Mouse:' 'Experiment:' 'World:' 'Level of Uncertainty:' 'Date:' 'Session:' 'Max Trial Length (min):' 'Max Number of Trials:'};% 'Detect licking:' 'Valve Open for (ms):' 'Reward Speed onset:' 'Max Trial Length (min):' 'Max Number of Trials:' 'Include Licking Criteria:'};
dlg_title = 'Trial';
num_lines = 1;
defaultans = {'mx', vr.Experiment, 'A', '0', '20171122' '1' '60' '100'};
vr.TrialInfo.Answers = inputdlg(vr.TrialInfo.Prompt,dlg_title,num_lines,defaultans);
end

