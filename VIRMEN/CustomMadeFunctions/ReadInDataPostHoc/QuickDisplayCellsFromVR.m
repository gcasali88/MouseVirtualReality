
function Out = QuickDisplayCellsFromVR


Prompt = {'Experiment','Mouse','Date','VROnly','ReRunDataSet','LoadDataSet','LoadDataSetAlreadyRun','ExtractCells','NShuffles'};
dlg_title = 'TrialInfo';
num_lines = 1;
defaultans = {'Training', 'm'  '' '1' '0' '0' '0' '0' '0' };

Answers = inputdlg(Prompt,dlg_title,num_lines,defaultans);

Out = DisplayCellsFromVR(Answers{1},Answers{2},Answers{3},str2num(Answers{4}),str2num(Answers{5}),str2num(Answers{6}),str2num(Answers{7}),str2num(Answers{8}),str2num(Answers{9}));

end
