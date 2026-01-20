function [ vr ] = VisualUncertaintyInsertTestData( vr )
%Pop up box asking for basic details of the test
%   Opens file and storage file

% vr.Path = ['C:\Users\Sarah\Dropbox\VIRMEN\Sarah']
% vr.FileStorePath = ['C:\Users\Sarah\Dropbox\VIRMEN\Sarah\Data'];
vr.Path = ['C:\Users\Giulio\Documents\'];
vr.FileStorePath = ['S:\DBIO_BarryLab_DATA\giulioC\Data\VR\'];

%Input trial data;
% if exist('WhichWorld.data','file')==2;
% vr.RunExperiment = 1;%transpose(fread(fopen('ProduceTextrue.data'),[3,Inf],'double'))
% else
% vr.RunExperiment = 0;
% end;

vr = VisualUncertaintyInsertMouseAndTrialData(vr);
vr.NameOfTheWorld = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'World (X, Y, Z):'))}];
vr.LevelOfUncertainty = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt, 'Level of Uncertainty (Low, Medium, High):'))}];
vr.RatName = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Mouse:'))} '\'];
vr.Day = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Date:'))} '\'];
vr.Session = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Session:'))} '\'];
vr.SaveData = [str2num(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Save data:'))} )];
vr.ProduceTexture = [str2num(vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Produce Texture:'))} )];

%vr.DirectoryName = [vr.Path vr.Experiment '\' vr.MouseName vr.Day 'Session' vr.Session] ; %
vr.DirectoryName = [vr.Path '\' vr.Experiment '\' vr.RatName vr.Day ] ; 
%vr.FileStoreDirectoryName = [vr.FileStorePath vr.Experiment '\' vr.MouseName vr.Day 'Session' vr.Session] ; 
vr.FileStoreDirectoryName = [vr.FileStorePath '\' vr.Experiment '\' vr.RatName vr.Day vr.NameOfTheWorld ] ; 


%Behaviour Information
if vr.RunExperiment;
load('Answers');
vr.BehaviourInfo.Answers = Answers.BehaviourInfo;
vr.BehaviourInfo.Prompt = Prompts.BehaviourInfo;
else
vr=InsertBehaviourRequired(vr);
end
vr.DetectLicking = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Detect licking:'))}) ];
vr.LickingActiveConditionProbabilityPartitions = textscan(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Licking active condition trial (Prob):'))}, '%s' , 'Delimiter', ',') ;
vr.LickingActiveConditionProbabilityPartitions = vr.LickingActiveConditionProbabilityPartitions{1}  ; 
vr.LickingActiveConditionProbability = [(str2double(vr.LickingActiveConditionProbabilityPartitions))];
vr.LickingActiveConditionProbabilityPartitions = numel(vr.LickingActiveConditionProbabilityPartitions )  ; 
%vr.LickingActiveConditionProbabilityTimeWindos = linspace(0,

vr.MaxNumberOfLicks = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Max number of licks:' ))}) ];
vr.RewardWindowWidth = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Reward Window Width:' ))}) ];

vr.RewardIfLicking = rand(1,1)< vr.LickingActiveConditionProbability(1) ;

%% Create directories...
mkdir(vr.DirectoryName);
mkdir(vr.FileStoreDirectoryName);
cd(vr.DirectoryName);
clear Answers;
if vr.RunExperiment;
delete('Answers.mat');
end

end

