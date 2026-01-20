function [ vr ] = InputTestData( vr )
%Pop up box asking for basic details of the test
%   Opens file and storage file

vr.Path = ['C:\Users\Sarah\Dropbox\VIRMEN\Sarah']
vr.FileStorePath = ['C:\Users\Sarah\Dropbox\VIRMEN\Sarah\Data'];
%Input trial data
vr = InsertMouseAndTrialData(vr)
vr.worlds = {'A' 'B' 'C'}
vr.Experiment.World = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'World:'))} '\'];
vr.MouseName = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Mouse:'))} '\'];
vr.Day = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Date:'))} '\'];
vr.Session = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Session:'))} '\'];

%vr.DirectoryName = [vr.Path vr.Experiment '\' vr.MouseName vr.Day 'Session' vr.Session] ; %
vr.DirectoryName = [vr.Path vr.Experiment '\' vr.MouseName vr.Day ] ; 
%vr.FileStoreDirectoryName = [vr.FileStorePath vr.Experiment '\' vr.MouseName vr.Day 'Session' vr.Session] ; 
vr.FileStoreDirectoryName = [vr.FileStorePath vr.Experiment '\' vr.MouseName vr.Day ] ; 


%Behaviour Information
vr=InsertBehaviourRequired(vr);
vr.DetectLicking = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Detect licking:'))}) ];
vr.RewardIfLicking = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Include Licking Criteria:'))}) ];
vr.MaxNumberOfLicks = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Max number of licks:' ))}) ];
vr.RewardWindowWidth = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Reward Window Width:' ))}) ];
if strcmp(vr.Experiment,'Multicompartment');
vr.DiscriminateRewardedAreas = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Discriminate the rewarded areas:' ))}) ];
end

%% Create directories...
mkdir(vr.DirectoryName);
mkdir(vr.FileStoreDirectoryName);
cd(vr.DirectoryName);
end

