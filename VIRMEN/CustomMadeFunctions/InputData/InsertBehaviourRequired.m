function vr = InsertBehaviourRequired(vr)

if strcmp(vr.Experiment,'Multicompartment');
vr.BehaviourInfo.Prompt = {'Detect licking:' 'Valve Open for (ms):' 'Reward Speed onset:' 'Licking active condition trial (Prob):' 'Max number of licks:' 'Sound when licking:' 'Reward Window Width:' 'Discriminate the rewarded areas:'};
dlg_title = 'Behaviour';
num_lines = 1;
defaultans = {'1' '200' '0' '1' '10' '1' '40' '0'};
    
    
else    
vr.BehaviourInfo.Prompt = {'Detect licking:' 'Valve Open for (ms):' 'Reward Speed onset:' 'Licking active condition trial (Prob):' 'Max number of licks:' 'Sound when licking:' 'Reward Window Width:'};
dlg_title = 'Behaviour';
num_lines = 1;
defaultans = {'1' '200' '0' '0' '100' '1' '60'};
end
vr.BehaviourInfo.Answers = inputdlg(vr.BehaviourInfo.Prompt,dlg_title,num_lines,defaultans);



end