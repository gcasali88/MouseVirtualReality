function OutputDataFromVirmen(vr)
if ~exist('vr','var')
vr = []; 
vr.Experiment = 'Specify';
vr.Path = ['C:\Users\Giulio\Documents\'];
vr.FileStorePath = ['Z:\giulioC\Data\VR\'];
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
vr.Experiment = [vr.TrialInfo.Answers{find(strcmp(vr.TrialInfo.Prompt,'Experiment:'))} '\'];
vr.FileStoreDirectoryName = [vr.FileStorePath vr.Experiment '\' vr.RatName vr.Day ] ; 
end
Data = [];

%% Behaviour
BehaviourData = fopen('Behaviour.data','r');
if strcmp(vr.Experiment,'FixingPoint')
Behaviour= transpose(fread(BehaviourData,[4,Inf],'double'));
Data.pos.ts = Behaviour(:,1); 
Data.pos.interval = [diff(Data.pos.ts);NaN]; 
Data.pos.xy = Behaviour(:,2:3); 
Data.pos.Trial = Behaviour(:,4); 
else
Behaviour= transpose(fread(BehaviourData,[6,Inf],'double'));
Data.pos.ts = Behaviour(:,1); 
Data.pos.interval = [diff(Data.pos.ts);NaN]; 
Data.pos.pos = Behaviour(:,2); 

Data.pos.Environment = Behaviour(:,4); 
Data.pos.Trial = Behaviour(:,5); 
Data.pos.NumberOfVisits = Behaviour(:,6); 

Data.pos.dp = [diff(Data.pos.pos);NaN]; ;
Data.pos.speed = [Data.pos.dp ./ Data.pos.interval];

Data.pos.speed(find(diff(Data.pos.Trial))) = NaN;
Data.pos.dp(find(diff(Data.pos.Trial))) = NaN;

%IT WAS...
% Data.pos.speed = Behaviour(:,3); 
% Data.pos.speed(1)=Data.pos.speed(1+1);
% Data.pos.dp = Data.pos.interval.*Data.pos.speed;
% Data.pos.dp(end) = Data.pos.dp(end-1);

Data.pos.CumulativeDistance = nansum(abs(Data.pos.dp)); % Cumulative distance (abs to get rid of direction (if negative it would be backward)...
clear Behaviour;fclose(BehaviourData);clear BehaviourData;
end
%% PhotoLicking...
PhotoLickingData = fopen('PhotoLicking.data','r');
if strcmp(vr.Experiment,'FixingPoint')
PhotoLicking = transpose(fread(PhotoLickingData,[3,Inf],'double'));
if isempty(PhotoLicking)
   Data.Licking.PhotoLicking.ts = [NaN];
   Data.Licking.PhotoLicking.xy = [NaN NaN];
else
   Data.Licking.PhotoLicking.ts = PhotoLicking(:,1);
   Data.Licking.PhotoLicking.xy = PhotoLicking(:,2:3);
end;
Data.Licking.PhotoLicking.xy(Data.Licking.PhotoLicking.ts>Data.pos.ts(end),:) = [];
Data.Licking.PhotoLicking.ts(Data.Licking.PhotoLicking.ts>Data.pos.ts(end),:) = [];

else %% For all the other experiments...
PhotoLicking = transpose(fread(PhotoLickingData,[2,Inf],'double'));
if isempty(PhotoLicking)
   Data.Licking.PhotoLicking.ts = [NaN];
   Data.Licking.PhotoLicking.pos = [NaN];
else
   Data.Licking.PhotoLicking.ts = PhotoLicking(:,1);
   Data.Licking.PhotoLicking.pos = PhotoLicking(:,2);
end;
Data.Licking.PhotoLicking.pos(Data.Licking.PhotoLicking.ts>Data.pos.ts(end)) = [];
Data.Licking.PhotoLicking.ts(Data.Licking.PhotoLicking.ts>Data.pos.ts(end)) = [];
end
clear PhotoLicking; fclose(PhotoLickingData);clear PhotoLickingData;
                    %% and photo data...
PhotoData = fopen('PhotoLickingDetection.data','r');
Photo = transpose(fread(PhotoData,[2,Inf],'double'));
if isempty(Photo)
   Data.Licking.PhotoDetection.ts = [NaN];
   Data.Licking.PhotoDetection.Voltage = [NaN];
   
else
   Data.Licking.PhotoDetection.ts = Photo(:,1);
   Data.Licking.PhotoDetection.Voltage = Photo(:,2);
end 

clear Photo; fclose(PhotoData);clear PhotoData;
%% BatteryLicking
% BatteryLickingData = fopen('BatteryLicking.data','r');
% BatteryLicking = transpose(fread(BatteryLickingData,[2,Inf],'double'));
% if isempty(BatteryLicking)
%    Data.Licking.BatteryLicking.ts = [NaN];
%    Data.Licking.BatteryLicking.pos = [NaN];
% else
%    Data.Licking.BatteryLicking.ts = BatteryLicking(:,1);
%    Data.Licking.BatteryLicking.pos = BatteryLicking(:,2);
% end;
% Data.Licking.BatteryLicking.pos(Data.Licking.BatteryLicking.ts>Data.pos.ts(end)) = [];
% Data.Licking.BatteryLicking.ts(Data.Licking.BatteryLicking.ts>Data.pos.ts(end)) = [];
% 
% clear BatteryLicking; fclose(BatteryLickingData);clear BatteryLickingData;
% %% and Battery data...
% BatteryData = fopen('BatteryLickingDetection.data','r');
% Battery = transpose(fread(BatteryData,[2,Inf],'double'));
% if isempty(Battery)
%    Data.Licking.BatteryDetection.ts = [NaN];
%    Data.Licking.BatteryDetection.Voltage = [NaN];
%    
% else
%    Data.Licking.BatteryDetection.ts = Battery(:,1);
%    Data.Licking.BatteryDetection.Voltage = Battery(:,2);
% end  
% clear Battery; fclose(BatteryData);clear BatteryData;%% Axona...
% 
%% Axona Synch data...

AxonaSynchData = fopen('AxonaSynch.data','r');
if strcmp(vr.Experiment,'FixingPoint')
AxonaSynch=transpose(fread(AxonaSynchData,[3,Inf],'double'));;
if isempty(AxonaSynch)
   Data.AxonaSynch.ts = [NaN];
   Data.AxonaSynch.xy = [NaN NaN];
else
   Data.AxonaSynch.ts = AxonaSynch(:,1);
   Data.AxonaSynch.xy = AxonaSynch(:,2:3);
end;

else
AxonaSynch=transpose(fread(AxonaSynchData,[2,Inf],'double'));;
if isempty(AxonaSynch)
   Data.AxonaSynch.ts = [NaN];
   Data.AxonaSynch.pos = [NaN];
else
   Data.AxonaSynch.ts = AxonaSynch(:,1);
   Data.AxonaSynch.pos = AxonaSynch(:,2);
end;
end
clear AxonaSynch; fclose(AxonaSynchData);clear AxonaSynchData;

%% Reward....
RewardData = fopen('Reward.data','r');
if strcmp(vr.Experiment,'FixingPoint')
Reward=transpose(fread(RewardData,[3,Inf],'double'));;
if isempty(Reward)
   Data.Reward.ts = [NaN];
   Data.Reward.xy= [NaN NaN];
else
   Data.Reward.ts = Reward(:,1);
   Data.Reward.xy = Reward(:,2:3);
end;
   
else    
Reward=transpose(fread(RewardData,[2,Inf],'double'));;
if isempty(Reward)
   Data.Reward.ts = [NaN];
   Data.Reward.pos= NaN;
else
   Data.Reward.ts = Reward(:,1);
   Data.Reward.pos = Reward(:,2);
end;
end
clear Reward; fclose(RewardData);clear RewardData;
%%
% open the binary file
% VoltageLickingData = fopen('VoltageLickingDetection.data','r');
% VoltageLicking = transpose(fread(VoltageLickingData,[2,Inf],'double'));
% if isempty(VoltageLicking)
%    Data.Licking.VoltageDetection.ts = [NaN];
%    Data.Licking.VoltageDetection.V = [NaN];
% else
%    Data.Licking.VoltageDetection.ts = VoltageLicking(:,1);
%    Data.Licking.VoltageDetection.V = VoltageLicking(:,2);
% end;
% % Data.Licking.pos(Data.Licking.ts>Data.pos.ts(end)) = [];
% % Data.Licking.ts(Data.Licking.ts>Data.pos.ts(end)) = [];
% 
% clear VoltageLicking; fclose(VoltageLickingData);clear LickingData
% %%
% VoltageData = fopen('VoltageLicking.data','r');
% Licking = transpose(fread(VoltageData,[3,Inf],'double'));
% if isempty(Licking)
%    Data.Licking.VoltageLicking.ts = [NaN];
%    Data.Licking.VoltageLicking.pos = [NaN];
%    Data.Licking.VoltageLicking.Events = [NaN];
% else
%    Data.Licking.VoltageLicking.ts = Licking(:,1);
%    Data.Licking.VoltageLicking.pos = Licking(:,2);
%    Data.Licking.VoltageLicking.Events = Licking(:,3);
% end;
% Data.Licking.VoltageLicking.pos(Data.Licking.VoltageLicking.ts>Data.pos.ts(end)) = [];
% Data.Licking.VoltageLicking.ts(Data.Licking.VoltageLicking.ts>Data.pos.ts(end)) = [];
% Data.Licking.VoltageLicking.Events(Data.Licking.VoltageLicking.ts>Data.pos.ts(end)) = [];
% 
% clear Licking; fclose(VoltageData);
%% Add things relative to the GAIN - only if any change in the GAIN has been conducted...


if isfield(vr,'AnimalDisplacement')
vr.GainManipulation.POSTHOC = fopen('GainManipulation.data','r');
% read all data from the file into the matrix
vr.GainManipulation.POSTHOCData = transpose(fread(vr.GainManipulation.POSTHOC,[3,Inf],'double'));
Data.GainManipulation.ts = vr.GainManipulation.POSTHOCData(:,1);
Data.GainManipulation.SmoothedGains = vr.GainManipulation.POSTHOCData(:,2);
Data.GainManipulation.Gains = vr.GainManipulation.POSTHOCData(:,3);
%vr = rmfield(vr,'GainManipulation');
vr.AnimalDisplacement.POSTHOC = fopen('AnimalDisplacement.data','r');
% read all data from the file into the matrix
vr.AnimalDisplacement.POSTHOCData= transpose(fread(vr.AnimalDisplacement.POSTHOC,[2,Inf],'double'));
Data.pos.PIdp = vr.AnimalDisplacement.POSTHOCData(:,2);
Data.pos.PIspeed = Data.pos.PIdp ./ Data.pos.interval ;

vr.PositionPI.POSTHOC = fopen('PositionPI.data','r');
vr.PositionPI.POSTHOCData = transpose(fread(vr.PositionPI.POSTHOC,[2,Inf],'double'));
Data.pos.PIpos = vr.PositionPI.POSTHOCData(:,2);

Data.pos.PIspeed(find(diff(Data.pos.Trial))) = NaN;
Data.pos.PIdp(find(diff(Data.pos.Trial))) = NaN;

vr = rmfield(vr,'AnimalDisplacement');
vr = rmfield(vr,'PositionPI');
end


% if strcmp(vr.Experiment,'VisualUncertainty')
%     for iObject = 1 : numel(vr.VisualUncertainty.Properties.Objects)
%     vr.exper.worlds{vr.currentWorld}.objects{iObject}.texture = [];    
%     end
% end    


%% save also the vr structure before closing it...
Data.vr = vr;

%% Save into directory previously saved...
if ~isfield(vr,'SaveData');
vr.SaveData = 1;
end

if isfield(vr,'NameOfCurrentEnvironment')
tmpfile = ['Mouse_' vr.RatName(1:end-1) '_' vr.Day(1:end-1) '_Session_' vr.Session(1:end-1) '_' vr.NameOfCurrentEnvironment];
else
tmpfile = ['Mouse_' vr.RatName(1:end-1) '_' vr.Day(1:end-1) '_Session_' vr.Session(1:end-1)];    
end

if vr.SaveData
    if isdir(vr.DirectoryName);
        cd(vr.DirectoryName);
        vr.DataSaved = 0;
        while ~vr.DataSaved 
            try 
                save(['vr'],'vr', '-v7.3' ) ;       
                save(['vr_Session_' vr.Session(1:end-1)],'vr', '-v7.3' ) ;
                eval([ 'save(' char(39) tmpfile char(39) ',' char(39) 'Data' char(39) ',' char(39) '-v7.3' char(39) ');;' ])
                delete vr.mat;
                vr.DataSaved = 1;
                disp(['Data safely saved in ' vr.DirectoryName '...' ] )

            catch 
                disp(['Data unsaved here...' ] )
            end
        end
        
    end

    if isdir(vr.FileStoreDirectoryName)
        cd(vr.FileStoreDirectoryName)
        vr.DataSaved = 0;
        while ~vr.DataSaved 
            try 
                save(['vr'],'vr', '-v7.3' ) ;       
                save(['vr_Session_' vr.Session(1:end-1)],'vr', '-v7.3' ) ;
                eval([ 'save(' char(39) tmpfile char(39) ',' char(39) 'Data' char(39) ',' char(39) '-v7.3' char(39) ');;' ])
                delete vr.mat;
                vr.DataSaved = 1;
                disp(['Data safely saved in ' vr.FileStoreDirectoryName '...' ] )

            catch 
                disp(['Data unsaved here...' ] )
            end
        end
    end
else
disp([tmpfile ' NOT saved...']);    
end;

DisplaySummaryOfTrial;



end
