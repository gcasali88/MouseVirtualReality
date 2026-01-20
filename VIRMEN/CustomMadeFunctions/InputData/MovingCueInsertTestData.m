function [ vr ] = MovingCueInsertTestData( vr )
%Pop up box asking for basic details of the test
%   Opens file and storage file

% vr.Path = ['C:\Users\Sarah\Dropbox\VIRMEN\Sarah']
% vr.FileStorePath = ['C:\Users\Sarah\Dropbox\VIRMEN\Sarah\Data'];
vr.Path = ['C:\Users\Giulio\Documents\'];
vr.FileStorePath = ['Z:\giulioC\Data\VR\'];

%Input trial data;
% if exist('WhichWorld.data','file')==2;
% vr.RunExperiment = 1;%transpose(fread(fopen('ProduceTextrue.data'),[3,Inf],'double'))
% else
% vr.RunExperiment = 0;
% end;

vr = MovingCueInsertMouseAndTrialData(vr);
vr.NameOfTheWorld = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'World (Q1,A2):'))}];
vr.RatName = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Mouse:'))} '\'];
vr.Day = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Date:'))} '\'];
vr.Session = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Session:'))} '\'];

%vr.DirectoryName = [vr.Path vr.Experiment '\' vr.MouseName vr.Day 'Session' vr.Session] ; %
vr.DirectoryName = [vr.Path '\' vr.Experiment '\' vr.RatName vr.Day ] ; 
%vr.FileStoreDirectoryName = [vr.FileStorePath vr.Experiment '\' vr.MouseName vr.Day 'Session' vr.Session] ; 
vr.FileStoreDirectoryName = [vr.FileStorePath '\' vr.Experiment '\' vr.RatName vr.Day vr.NameOfTheWorld ] ; 



vr=InsertBehaviourRequired(vr);
vr.DetectLicking = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Detect licking:'))}) ];
vr.RewardIfLicking = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Include Licking Criteria:'))}) ];
vr.MaxNumberOfLicks = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Max number of licks:' ))}) ];
vr.RewardWindowWidth = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Reward Window Width:' ))}) ];

%% Create directories...
mkdir(vr.DirectoryName);
mkdir(vr.FileStoreDirectoryName);
cd(vr.DirectoryName);

end

