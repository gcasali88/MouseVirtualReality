function [vr ] = InputDataIntoVirmen( vr)
%Will ask for some information where to save and store the data
%recorded...

%% Trial information...
vr=InsertRatNameAndTrial(vr);
vr.RatName = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Mouse:'))} '\'];
vr.Day = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Date:'))} '\'];
vr.Session = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Session:'))} '\'];
%vr.DirectoryName = [vr.Path vr.Experiment '\' vr.RatName vr.Day 'Session' vr.Session] ; %
vr.DirectoryName = [vr.Path vr.Experiment '\' vr.RatName vr.Day ] ; 
%vr.FileStoreDirectoryName = [vr.FileStorePath vr.Experiment '\' vr.RatName vr.Day 'Session' vr.Session] ; 
vr.FileStoreDirectoryName = [vr.FileStorePath vr.Experiment '\' vr.RatName vr.Day ] ; 
vr.Setup = str2double([vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'VRSETUP'))} ])  ; 
[ vr ] = SetWindowsSetup( vr );




%% Set Windows right...
% if vr.Setup ==2;
%     
% vr.exper.windows{1}.transformation =2;
% vr.exper.windows{1}.monitor = 1;
% 
% vr.exper.windows{2}.transformation =3;
% vr.exper.windows{2}.monitor = 5;
% 
% vr.exper.windows{3}.transformation =4;
% vr.exper.windows{3}.monitor = 2;
% 
% vr.exper.windows{4}.transformation =1;
% vr.exper.windows{4}.monitor = 6 ; %% Main Display
% 
% vr.exper.windows{5}.transformation =1;
% vr.exper.windows{5}.monitor = 3;
% 
% % vr.exper.windows{3}.monitor = 3;
% % vr.exper.windows{4}.monitor = 4;
% % vr.exper.windows{5}.monitor = 1;
% % vr.exper.windows{6}.monitor = 1;
% 
% end


%% Behaviour information...
vr=InsertBehaviourRequired(vr);
vr.DetectLicking = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Detect licking:'))}) ];
vr.LickingActiveConditionProbability = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Licking active condition trial (Prob):'))}) ];
vr.MaxNumberOfLicks = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Max number of licks:' ))}) ];
vr.RewardWindowWidth = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Reward Window Width:' ))}) ];
if strcmp(vr.Experiment,'Multicompartment');
vr.DiscriminateRewardedAreas = [str2double(vr.BehaviourInfo.Answers{find(strcmp(vr.BehaviourInfo.Prompt, 'Discriminate the rewarded areas:' ))}) ];
end;

 
vr.RewardIfLicking = rand(1,1)< vr.LickingActiveConditionProbability ;

%% Create directories...
mkdir(vr.DirectoryName);
mkdir(vr.FileStoreDirectoryName);
cd(vr.DirectoryName);
end

