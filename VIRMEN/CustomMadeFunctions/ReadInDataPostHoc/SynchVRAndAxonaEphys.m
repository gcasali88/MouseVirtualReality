function [GrandVR,OpenField,FilePath] = SynchVRAndAxonaEphys(varargin)

if nargin == 0
prompt = {'Experiment:' 'Mouse:' 'Date:' 'Session:' 'VROnly' };
dlg_title = 'Input';
num_lines = 1;
defaultans = {'Training' 'm2924'  '20170731','2','1'};
Answers = inputdlg(prompt,dlg_title,num_lines,defaultans);
Experiment = Answers{1};
Mouse = Answers{2};
Date =  Answers{3};
Session = Answers{4};
VROnly = str2double(Answers{5});
elseif nargin == 3 ; 
Experiment = varargin{1};
Mouse = varargin{2};
Date =  varargin{3};
VROnly =[];
elseif nargin == 4 ; 
Experiment = varargin{1};
Mouse = varargin{2};
Date =  varargin{3};
VROnly = (varargin{4}) ;
    
elseif nargin == 5 ; 
Experiment = varargin{1};
Mouse = varargin{2};
Date =  varargin{3};
Session = varargin{4};
VROnly = (varargin{5}) ;
end    

%% Preliminary Script To Synch Axona TTL with VR
Vars =daVarsStruct;
Parameters.Divider = get_working_pc_and_directory ('/','\');
Parameters.MotherPath =  get_working_pc_and_directory ('/home/giulio/Sdrive/DBIO_BarryLab_DATA/giulioC/Data/VR/','S:\DBIO_BarryLab_DATA\giulioC\Data\VR');
Parameters.MotherPath =[Parameters.MotherPath Parameters.Divider ];
FilePath =  [Parameters.MotherPath Experiment Parameters.Divider Mouse Parameters.Divider Date Parameters.Divider ] ;
FileName = dir([FilePath '*.set']) ;
FileName  = list_trials( FileName ); % creates a series of set files...
if isempty(VROnly)
  VROnly = isempty(strfind(FileName{1},'openfield'))  ;
end
%if numel(FileName)>1 & VROnly==0; ; % it means there are more than one trial - i.e. open field and VR trial...
for iFileName = 1 : numel(FileName);FileNameSet{iFileName}= FileName{iFileName}(1:end-4);end;
cd(FilePath);
FileNameCut = dir([FilePath '*.cut']) ;   
if ~VROnly;
%% Remove extra cut fields....
RemoveTrials = [];
    for iFile =1 :numel(FileNameCut)
    FileCutName = textscan(char(FileNameCut(iFile).name), '%s' , 'Delimiter', 'VR');
    if numel(FileCutName{1})> 1
    RemoveTrials = [RemoveTrials; iFile];
    end
    end   
   FileNameCut(RemoveTrials) = [];
end
%% Now load Matlab file output from Virmen...
MatlabData = [];
FileMatlabName = dir([FilePath '*.mat']) ;
for iFile = 1 : numel(FileMatlabName)
tmpFileMatlabName= FileMatlabName(iFile).name;%(1:end-4);

if FileMatlabName(iFile).bytes==0 ; %% Sometimes oddly the mat file does not get saved
Data.vr.Session = [num2str(iFile) '\'];
Data.vr.Experiment = [num2str(iFile) '\'];

else
load(tmpFileMatlabName);
end

eval(['MatlabData.' tmpFileMatlabName(1:end-4) ' = Data;' ])
clear Data tmpFileMatlabName;
end

MATLAB_FIELDS = fields(MatlabData);

MATLAB_FIELDS_WITH_DATA = find(ConcatentateIntoStructureIndices(FileMatlabName,'.','bytes',[],0)~= 0);      MATLAB_FIELDS_WITH_DATA = MATLAB_FIELDS_WITH_DATA(end);
MATLAB_FIELDS_WITHOUT_DATA = find(ConcatentateIntoStructureIndices(FileMatlabName,'.','bytes',[],0)== 0 ) ;

if ~isempty(MATLAB_FIELDS_WITHOUT_DATA)
for iMissingField = MATLAB_FIELDS_WITHOUT_DATA
 eval([ ' MatlabData.'  MATLAB_FIELDS{iMissingField } '.vr.Experiment =    MatlabData.'  MATLAB_FIELDS{MATLAB_FIELDS_WITH_DATA } '.vr.Experiment ; ' ] )
end


clear MATLAB_FIELDS MATLAB_FIELDS_WITH_DATA MATLAB_FIELDS_WITHOUT_DATA ;
end
%% Make sure the order of the cut file is right...
[~, ~, ~,OrderFileNameCut] = read_cut_file(FileNameCut(1).name) ; 
Input = repmat('%s ',1,numel(FileName))     ; 
OrderFileNameCut = textscan(char(OrderFileNameCut), Input , 'Delimiter', ','); clear Input;
if numel(FileName) ~= numel(OrderFileNameCut); disp(['Number of trials do not match...' ]); return; end;
for iFileName = 1 : numel(FileName);
  FileName{iFileName} = [ char(OrderFileNameCut{iFileName}) '.set'];
end;

%% Load data into a single structure called CombinedSessions...

CombinedSessions = readAllDACQdata(FilePath,FileName) ; disp(['Combined trials loaded together...'])
if sum(diff(CombinedSessions.pos.ts) <= 0)>0;
    CombinedSessions.pos.ts = [0:Vars.pos.sampleRate^-1 : sum(CombinedSessions.pos.trial_duration+1)]'; 
    CombinedSessions.pos.ts(length(CombinedSessions.pos.xy_cm)+1:end)= [];
end
FirstTrialDuration = CombinedSessions.pos.trial_duration(1) ;
FirstTrialDurationPosNumber = FirstTrialDuration * Vars.pos.sampleRate ;
OriginalNumberOfPosNumber = numel(CombinedSessions.pos.ts) ;
if VROnly
    OpenFieldTrialDuration = [];
    OpenFieldDurationPosNumber = [];
else
    OpenFieldTrialDuration = FirstTrialDuration;
    OpenFieldDurationPosNumber  = FirstTrialDurationPosNumber;
end
%% Check EEG is right already...
for iEEG = 1 : numel(CombinedSessions.EEG)
    if numel(CombinedSessions.EEG(iEEG).EEG) < OriginalNumberOfPosNumber* Vars.eeg.sampleRate/Vars.pos.sampleRate
    CombinedSessions.EEG(iEEG).EEG(end+1:OriginalNumberOfPosNumber* Vars.eeg.sampleRate/Vars.pos.sampleRate) = NaN ;
    end;
    CombinedSessions.EEG(iEEG).EEG = CombinedSessions.EEG(iEEG).EEG(1:OriginalNumberOfPosNumber* Vars.eeg.sampleRate/Vars.pos.sampleRate);
end
%%
        OpenField = CombinedSessions; %% Create OpenField structure
        VR = CombinedSessions;        %% Create VR....
        VR.Virmen = MatlabData; clear MatlabData;
        
%%      Remove extra stuff from OpenField...
            %% Pos data...
            if ~VROnly ;
                
            OpenField.pos.trial_duration = OpenField.pos.trial_duration(1);
            OpenField.pos.dir_coherent = OpenField.pos.dir;
            SubFields = fields(OpenField.pos); 
                for iSubField = 1 : numel(SubFields) ; 
                    if eval( [ ' length(OpenField.pos.' SubFields{iSubField} ') == OriginalNumberOfPosNumber ' ])       
                            eval( [ 'OpenField.pos.' SubFields{iSubField} '(OpenFieldDurationPosNumber+1:end,:) = []; ' ]) ;
                    end
                end
            OpenField.pos.SurfPos = [1 : length(OpenField.pos.xy_cm)]; clear SubFields  iSubField;
            %% EEG data...
            for iEEG = 1 : numel(OpenField.EEG)
            OpenField.EEG(iEEG).EEG = OpenField.EEG(iEEG).EEG(1: FirstTrialDurationPosNumber * Vars.eeg.sampleRate/Vars.pos.sampleRate ) ;
            end
            %% Tetrodes...
            for Tetrode = 1 : numel(OpenField.tetrode)
            NSpikes = length(OpenField.tetrode(Tetrode).ts);
            SpikesToRemove = find(OpenField.tetrode(Tetrode).ts > FirstTrialDuration) ;
            TetrodeFields = fields(OpenField.tetrode(Tetrode));
            for iField = 1 : numel(TetrodeFields);
            if eval([ 'length(OpenField.tetrode(Tetrode).' TetrodeFields{iField} ') == NSpikes' ])
            eval(['OpenField.tetrode(Tetrode).' TetrodeFields{iField} '(SpikesToRemove,:) = [];' ]);            
            end
            end
            clear NSpikes SpikesToRemove TetrodeFields iField
            OpenField.tetrode(Tetrode).duration = OpenField.pos.trial_duration;
            end
            else
                OpenField = [];
                
            end
        %% Now remove data from the VR...
          %% Pos data...
          
%for iSession =1 : numel( fields(Grand_VR.Virmen))         
   %iSession =1 ;
   %VR = [CombinedSessions]; 
   if VROnly;
        VR.pos.trial_duration = CombinedSessions.pos.trial_duration(1:end);
   else
        VR.pos.trial_duration = CombinedSessions.pos.trial_duration(2:end);
   end;
   SubFields = fields(VR.pos);
   TmpPos = zeros(sum(CombinedSessions.pos.trial_duration)*Vars.pos.sampleRate,1);
   
   for iSubField = 1 : numel(SubFields) ; 
       if eval( [ ' length(VR.pos.' SubFields{iSubField} ') == OriginalNumberOfPosNumber ' ])       
        eval( [ 'VR.pos.' SubFields{iSubField} '(1:OpenFieldDurationPosNumber,:) = []; ' ]) ;
       end
   end
   VR.pos.ts = VR.pos.ts - VR.pos.ts(1);%+Vars.pos.sampleRate^-1;
   VR.Ephys=VR.pos;
%% EEG data...
            for iEEG = 1 : numel(VR.EEG)
                VR.EEG(iEEG).EEG(1: OpenFieldDurationPosNumber * Vars.eeg.sampleRate/Vars.pos.sampleRate ) = []; 
            end;
            if ~VROnly ;
                 %% Tetrodes...
                 for Tetrode = 1 : numel(VR.tetrode)
                        NSpikes = length(VR.tetrode(Tetrode).ts);
                        SpikesToRemove = find(VR.tetrode(Tetrode).ts < FirstTrialDuration) ;          
                        TetrodeFields = fields(VR.tetrode(Tetrode));
                            for iField = 1 : numel(TetrodeFields);
                                if eval([ 'length(VR.tetrode(Tetrode).' TetrodeFields{iField} ') == NSpikes' ])
                                        eval(['VR.tetrode(Tetrode).' TetrodeFields{iField} '(SpikesToRemove,:) = [];' ]);            
                                end
                            end
                        VR.tetrode(Tetrode).duration = VR.pos.trial_duration ;
                        clear SpikesToRemove NSpikes TetrodeFields;
                 end
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
clear SubFields Tetrode iSubField iFileName CombinedSessions dlg_title defaultans


VirmenSessions = fields(VR.Virmen) ;
EphysSessions = 1 : numel(VR.pos.trial_duration) ; 
N_RecordedSessions = numel(VirmenSessions);
VirmenRecordedSessions = [[1:N_RecordedSessions] ] ;
ID_RecordedSessions = [];


%% If there was any DacqQUsb data which went missing but the VR still ran normally
%here this function re-creates an Ephsy synch data file to display behaviour as normal but without
%pos data.
MissingVirmenSessions = VirmenRecordedSessions((~ismember([VirmenRecordedSessions],EphysSessions)));
    if numel(VirmenRecordedSessions)>0
        for iSession = 1 :  numel(MissingVirmenSessions)
                eval(['VR = TurnVirmenDataIntoEphysForMissingAxonaFiles(VR,[MissingVirmenSessions(iSession) ])  ;' ] )
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


AcrossSessionsPos = [];

for iSession = 1 : N_RecordedSessions
    eval(['ID_RecordedSessions(iSession) = str2double(VR.Virmen.' VirmenSessions{iSession}  '.vr.Session(1));' ]);
end

if numel(unique(ID_RecordedSessions)) ~= N_RecordedSessions ;
    % e.g. Sarah experiment ...
    ID_RecordedSessions = [ 1 : N_RecordedSessions ] ;
end
    
for iSession  = 1 : numel(VR.pos.trial_duration)   
    AcrossSessionsPos = [AcrossSessionsPos;    repmat(iSession,  VR.pos.trial_duration((iSession))*Vars.pos.sampleRate,1)];
end
    
for iSession = 1 : N_RecordedSessions

%% Adjust Pos
%ID_RecordedSessions
tmpVR = VR;
    if N_RecordedSessions == max(ID_RecordedSessions)   ;
            %if  ismember(EphysSessions,iSession)
            tmpVR.Ephys.trial_duration = VR.Ephys.trial_duration(ID_RecordedSessions(iSession));
            GoodPos = find(AcrossSessionsPos == ID_RecordedSessions(iSession) );
%           else
%            eval(['tmpVR.Ephys.trial_duration = round(VR.Virmen.' VirmenSessions{iSession} '.pos.ts(end));' ] );
%             GoodPos = find(AcrossSessionsPos == (iSession) );
%            %eval(['TurnVirmenDataIntoEphysForMissingAxonaFiles(VR.Virmen.' VirmenSessions{iSession} ')  ;' ] )
            %end
    else
        tmpVR.Ephys.trial_duration  = VR.Ephys.trial_duration((iSession));
        GoodPos = find(AcrossSessionsPos == (iSession) );
    end

    PosFields = fields(tmpVR.Ephys);
        for iField = 1 : numel(PosFields)
                if eval(['length(tmpVR.Ephys.' PosFields{iField} ') == length(AcrossSessionsPos);' ])
                    eval(['tmpVR.Ephys.' PosFields{iField} ' = tmpVR.Ephys.' PosFields{iField} '(GoodPos,:) ;' ]);
                end
                if strcmp(PosFields{iField},'ts');
                    FirstTs = [tmpVR.Ephys.ts(1)];
                end
        end

%% Adjust tetrodes

for Tetrode = 1 : numel(VR.tetrode)
tmpVR.tetrode(Tetrode).ts = tmpVR.tetrode(Tetrode).ts  - tmpVR.tetrode(Tetrode).ts(1);
SpikesToKeep = find(tmpVR.tetrode(Tetrode).ts > tmpVR.Ephys.ts(1) & tmpVR.tetrode(Tetrode).ts < tmpVR.Ephys.ts(end)) ;
NSpikes = numel(tmpVR.tetrode(Tetrode).ts) ;
TetrodeFields = fields(tmpVR.tetrode(Tetrode));
for iField = 1 : numel(TetrodeFields)
    if eval(['size(tmpVR.tetrode(Tetrode).' TetrodeFields{iField}  ',1) == NSpikes;' ])
        eval(['tmpVR.tetrode(Tetrode).' TetrodeFields{iField}  ' = tmpVR.tetrode(Tetrode).' TetrodeFields{iField} '(SpikesToKeep,:) ;' ])
    end           
end
% tmpVR.tetrode(Tetrode).ts = tmpVR.tetrode(Tetrode).ts(SpikesToKeep); 
% tmpVR.tetrode(Tetrode).cut = tmpVR.tetrode(Tetrode).cut(SpikesToKeep); 
% tmpVR.tetrode(Tetrode).duration = tmpVR.Ephys.trial_duration;
% tmpVR.tetrode(Tetrode).pos_sample = tmpVR.tetrode(Tetrode).pos_sample(SpikesToKeep); 
clear SpikesToKeep NSpikes TetrodeFields
tmpVR.tetrode(Tetrode).duration = tmpVR.Ephys.trial_duration;
end

%% Adjust EEG
for iEEG = 1 : numel(tmpVR.EEG)
 if numel(tmpVR.EEG(iEEG).EEG)/ 5 < OriginalNumberOfPosNumber ; tmpVR.EEG(iEEG).EEG(end: OriginalNumberOfPosNumber*50) = NaN;    end

    tmpVR.EEG(iEEG).EEG = tmpVR.EEG(iEEG).EEG(1: OriginalNumberOfPosNumber* Vars.eeg.sampleRate / Vars.pos.sampleRate);
    tmpVR.EEG(iEEG).EEG=reshape(tmpVR.EEG(iEEG).EEG,[],Vars.eeg.sampleRate / Vars.pos.sampleRate);
    tmpVR.EEG(iEEG).EEG = tmpVR.EEG(iEEG).EEG(GoodPos,:);
    tmpVR.EEG(iEEG).EEG = reshape(tmpVR.EEG(iEEG).EEG,[1],[]);
end

%% Select right Virmen Session....
eval(['tmpVR.Virmen = tmpVR.Virmen.' VirmenSessions{iSession} ' ;' ]);

%% Now resets pos and spike ts...
for Tetrode = 1 : numel(VR.tetrode)
tmpVR.tetrode(Tetrode).ts = tmpVR.tetrode(Tetrode).ts  - tmpVR.Ephys.ts(1) ;
end
tmpVR.Ephys.ts = tmpVR.Ephys.ts  - tmpVR.Ephys.ts(1) ;
if VROnly
    if N_RecordedSessions==1;
        tmpVR.flnmroot = VR.flnmroot ; %{ID_RecordedSessions(iSession)} ;
    else
        tmpVR.flnmroot = VR.flnmroot{iSession} ; %VR.flnmroot{ID_RecordedSessions(iSession)} ; %{ID_RecordedSessions(iSession)} ;
    end
    
else
tmpVR.flnmroot = VR.flnmroot{ find(ismember(ID_RecordedSessions,[ID_RecordedSessions(iSession) ])) +1} ; % it was tmpVR.flnmroot = VR.flnmroot{ [ID_RecordedSessions(iSession) ] +1} %% VR.flnmroot{ [ID_RecordedSessions(iSession) - (max(ID_RecordedSessions)-1)] +1}
end


if ismember(MissingVirmenSessions,iSession)

    SynchAxona =  [  FindExtremesOfArray( tmpVR.Virmen.pos.ts) ];
else
    [ times, type, chan ] = read_INP_file( [FilePath tmpVR.flnmroot '.inp'] );
        if isfield(tmpVR.Virmen.vr,'AxonaSynch')
            SynchAxona = times(chan==tmpVR.Virmen.vr.AxonaSynch.AxonaSystemUnitChannel);
        else
            SynchAxona = [NaN NaN];  
        end
end

%% Adjust Pos

OriginalPos = numel(tmpVR.Ephys.ts);
PosTsToDelete = find(tmpVR.Ephys.ts < SynchAxona(1) |tmpVR.Ephys.ts > SynchAxona(end) );
tmpVR.Ephys.ts(PosTsToDelete)=[];
tmpVR.Ephys.ts = tmpVR.Ephys.ts - SynchAxona(1);
tmpVR.Ephys.ts=tmpVR.Ephys.ts;
tmpVR.Ephys.led_pos(PosTsToDelete,:) = [];
tmpVR.Ephys.led_pix(PosTsToDelete,:) = [];
tmpVR.Ephys.xy_pixels(PosTsToDelete,:) = [];
tmpVR.Ephys.xy_cm(PosTsToDelete,:) = [];
tmpVR.Ephys.dir(PosTsToDelete,:) = [];
tmpVR.Ephys.speed(PosTsToDelete,:) = [];
%% Correct EEG...
for iEEG = 1 : numel(VR.EEG)
 if numel(VR.EEG(iEEG).EEG)/ 5 < OriginalPos ; VR.EEG(iEEG).EEG(end: OriginalPos*50) = NaN;    end

    tmpVR.EEG(iEEG).EEG=VR.EEG(iEEG).EEG(1: OriginalPos* Vars.eeg.sampleRate / Vars.pos.sampleRate);
    tmpVR.EEG(iEEG).EEG=reshape(tmpVR.EEG(iEEG).EEG,[],Vars.eeg.sampleRate / Vars.pos.sampleRate);
    tmpVR.EEG(iEEG).EEG(PosTsToDelete,:)=[];
    tmpVR.EEG(iEEG).EEG = reshape(tmpVR.EEG(iEEG).EEG,[1],[]);
end
%% Adjust tetrodes... (correct across all tetrodes)....
for Tetrode=1:numel(tmpVR.tetrode)
InitialNumberOfSpikes = size(tmpVR.tetrode(Tetrode).ts,1);
ToDelete = find(tmpVR.tetrode(Tetrode).ts > SynchAxona(end) | tmpVR.tetrode(Tetrode).ts < SynchAxona(1) );
%LastPos = find( VR.tetrode(Tetrode).ts < SynchAxona(1) , 1, 'last');
Fields = fields(tmpVR.tetrode(Tetrode));
for iField = 1 : numel(Fields);
if eval(['size(tmpVR.tetrode(Tetrode).' Fields{iField} ',1) == InitialNumberOfSpikes' ])
eval(['tmpVR.tetrode(Tetrode).' Fields{iField} '(ToDelete,:) = [];']);
end
end
tmpVR.tetrode(Tetrode).ts = tmpVR.tetrode(Tetrode).ts -[SynchAxona(1)] ;
tmpVR.tetrode(Tetrode).pos_sample = ceil(tmpVR.tetrode(Tetrode).ts * Vars.pos.sampleRate);
%% Correcte for overhanging spikes...
OverHangingSpikes = find( tmpVR.tetrode(Tetrode).pos_sample > length(tmpVR.Ephys.xy_cm));
DeletedNumberOfSpikes = size(tmpVR.tetrode(Tetrode).ts,1);


for iField = 1 : numel(Fields);
if eval(['size(tmpVR.tetrode(Tetrode).' Fields{iField} ',1) == DeletedNumberOfSpikes' ])
eval(['tmpVR.tetrode(Tetrode).' Fields{iField} '(OverHangingSpikes,:) = [];']);
end
end

clear OverHangingSpikes DeletedNumberOfSpikes  Fields InitialNumberOfSpikes  ToDelete  iField         ;
%tmpVR.tetrode(Tetrode).duration = tmpVR.te
end;

%% Convert into cm... = Move the VR.pos data into the Ephys pos reference...
% [~,~,bin_id] = histcounts(tmpVR.Ephys.ts,tmpVR.Virmen.pos.ts) ;bin_id = bin_id (bin_id~= 0) ;
% [Y] = discretize(tmpVR.Ephys.ts,tmpVR.Virmen.pos.ts);Y = find(~isnan(Y));

if strcmp(tmpVR.Virmen.vr.Experiment,'FixingPoint') ;
        FX = griddedInterpolant(tmpVR.Virmen.pos.ts,tmpVR.Virmen.pos.pos(:,1)) ; 
        tmpVR.Ephys.xy_cm(:,1) = FX(tmpVR.Ephys.ts) ;
        FY = griddedInterpolant(tmpVR.Virmen.pos.ts,tmpVR.Virmen.pos.pos(:,2)) ; 
        tmpVR.Ephys.xy_cm(:,2) = FY(tmpVR.Ephys.ts) ;
        clear FX FY;    
%     
else

        if isfield(tmpVR.Virmen,'pos')

             [uniques,unique_id] = unique(tmpVR.Virmen.pos.ts);
                 if numel(unique_id) ~= numel(tmpVR.Virmen.pos.ts)
                  FieldsToCorrect = fields(tmpVR.Virmen.pos);
                  FieldsToCorrect(find(ismember(FieldsToCorrect,'CumulativeDistance'))) = [];
                  for iField = 1 : numel(FieldsToCorrect) ; 
                      eval(['tmpVR.Virmen.pos.' FieldsToCorrect{iField} ' =  tmpVR.Virmen.pos.' FieldsToCorrect{iField} '(unique_id)  ;' ] )
                  end
                 end    ; clear uniques unique_id;  
        F = griddedInterpolant((tmpVR.Virmen.pos.ts),tmpVR.Virmen.pos.pos) ; 
        tmpVR.Ephys.xy_cm(:,1) = F(tmpVR.Ephys.ts) ;
        tmpVR.Ephys.xy_cm(:,2) = rand(numel(tmpVR.Ephys.ts),1,1)/100;
        clear F;
        else
        tmpVR.Ephys.xy_cm(:) = NaN ;
        tmpVR.Ephys.led_pos(:) = NaN ;
        tmpVR.Ephys.ts(:) = NaN ;
        tmpVR.Ephys.led_pix(:) = NaN ;
        tmpVR.Ephys.xy_pixels(:) = NaN ;
        tmpVR.Ephys.dir(:) = NaN ;
        tmpVR.Ephys.speed(:) = NaN ;
        end

        if isfield(tmpVR.Virmen,'pos') && isfield(tmpVR.Virmen.pos,'PIpos')
        F = griddedInterpolant(tmpVR.Virmen.pos.ts,tmpVR.Virmen.pos.PIpos) ; 
        tmpVR.Ephys.PIxy_cm(:,1) = F(tmpVR.Ephys.ts) ;
        tmpVR.Ephys.PIxy_cm(:,2) = rand(numel(tmpVR.Ephys.ts),1,1)/100;
        clear F;
        end;

end;

if isfield(tmpVR.Virmen,'pos')
    FTrial = griddedInterpolant(tmpVR.Virmen.pos.ts,tmpVR.Virmen.pos.Trial,'previous') ; 
    tmpVR.Ephys.Trial(:,1) = FTrial(tmpVR.Ephys.ts) ;
    clear FTrial;
else
    tmpVR.Ephys.Trial = NaN(size(tmpVR.Ephys.ts)) ;
end




if strcmp(tmpVR.Virmen.vr.Experiment,'FixingPoint') ;
    tmpVR.Ephys.Environment = ones(numel(tmpVR.Ephys.ts),1);
else
    if isfield(tmpVR.Virmen,'pos')
    FEnvironment = griddedInterpolant(tmpVR.Virmen.pos.ts,tmpVR.Virmen.pos.Environment) ; 
    tmpVR.Ephys.Environment = FEnvironment(tmpVR.Ephys.ts) ;
    clear FEnvironment;
    else
    tmpVR.Ephys.Environment = NaN(size(tmpVR.Ephys.ts)) ;
    end
end

if isfield(tmpVR.Virmen,'pos') && isfield(tmpVR.Virmen.pos,'NumberOfVisits')   ;
    FNumberOfVisits = griddedInterpolant(tmpVR.Virmen.pos.ts,tmpVR.Virmen.pos.NumberOfVisits) ; 
    tmpVR.Ephys.NumberOfVisits = round(FNumberOfVisits(tmpVR.Ephys.ts) );
    clear FNumberOfVisits;
else
    tmpVR.Ephys.NumberOfVisits =NaN(size(tmpVR.Ephys.ts)) ; 
end;

%% Create a Licking structure of the same length as pos...
tmpVR.Licking.ts = tmpVR.Ephys.ts;
tmpVR.Licking.Voltage = NaN(numel(tmpVR.Ephys.ts),1);

if isfield(tmpVR.Virmen,'pos')
    FLicking  = griddedInterpolant(tmpVR.Virmen.pos.ts,tmpVR.Virmen.Licking.PhotoDetection.Voltage) ; 
    tmpVR.Licking.Voltage = FLicking(tmpVR.Ephys.ts);
    clear FLicking;
else
    tmpVR.Licking.Voltage   =NaN(numel(tmpVR.Ephys.ts),1);
end


%% Speed worked out

[tmpVR.Ephys.speed,tmpVR.Ephys.xy_cm(:,1) ] = get_speed( tmpVR.Ephys.xy_cm(:,1),zeros(numel(tmpVR.Ephys.xy_cm(:,2)),1),Vars.pos.sampleRate) ;
tmpVR.Ephys.speed (find(diff(  tmpVR.Ephys.Trial)  )) = NaN ;
tmpVR.Ephys.Environment(find(diff(  tmpVR.Ephys.Trial)  )) = NaN ;
tmpVR.Ephys.NumberOfVisits(find(diff(  tmpVR.Ephys.Trial)  )) = NaN ;
tmpVR.Ephys.Trial(find(diff(  tmpVR.Ephys.Trial)  )) = NaN ;
tmpVR.Ephys.dir = get_heading_dir(tmpVR.Ephys.xy_cm(:,1),tmpVR.Ephys.xy_cm(:,2),tmpVR.Ephys.speed,tmpVR.Ephys.ts) ; 
tmpVR.Ephys.dir_coherent = tmpVR.Ephys.dir;
if isequal(tmpVR.Ephys.xy_cm(:,size(tmpVR.Ephys.xy_cm,2)),ones(length(tmpVR.Ephys.xy_cm),1)  );
    tmpVR.Ephys.xy_cm(:,2) = rand(length(tmpVR.Ephys.xy_cm),1) ; 
end
tmpVR.Ephys.led_pos = tmpVR.Ephys.xy_cm;

%% If the PI positions were stored, then calculate the speed and direction;
if isfield(tmpVR.Ephys, 'PIxy_cm')
[tmpVR.Ephys.PIspeed,tmpVR.Ephys.PIxy_cm(:,1)]  = get_speed( tmpVR.Ephys.PIxy_cm(:,1),zeros(numel(tmpVR.Ephys.xy_cm(:,2)),1),Vars.pos.sampleRate) ;
tmpVR.Ephys.PIdir = get_heading_dir(tmpVR.Ephys.PIxy_cm(:,1),zeros(numel(tmpVR.Ephys.xy_cm(:,2)),1),tmpVR.Ephys.PIspeed,tmpVR.Ephys.ts);
tmpVR.Ephys.PIdir_coherent = tmpVR.Ephys.PIdir;
    if isequal(tmpVR.Ephys.PIxy_cm(:,size(tmpVR.Ephys.xy_cm,2)),ones(length(tmpVR.Ephys.xy_cm),1)  );
        tmpVR.Ephys.PIxy_cm(:,2) = rand(length(tmpVR.Ephys.xy_cm),1)/100 ; 
    end
end  
    
%% Create new structure and remove that...
tmpVR.pos = tmpVR.Ephys;
tmpVR = rmfield(tmpVR,'Ephys');
tmpVR.pos.SurfPos = [1 : length(tmpVR.pos.xy_cm)]';



%% Fix errors with wrong position across trials.
if ~strcmp(tmpVR.Virmen.vr.Experiment,'FixingPoint');
    PosTrialToFix = tmpVR.pos.Trial ;
    [A, B ,C,LinearizedTrial ] = CorrectCumulativePosition(tmpVR.pos.xy_cm(:,1),tmpVR.pos.ts(:,1),PosTrialToFix);
    tmpVR.pos.xy_cm(:,1) = A;
    tmpVR.pos.cumulative_xy_cm = B ;
    tmpVR.pos.speed = C;
    clear A B C ;
    if isfield(tmpVR.pos, 'PIxy_cm')
       [A, B,C ] = CorrectCumulativePosition(tmpVR.pos.PIxy_cm(:,1),tmpVR.pos.ts(:,1),PosTrialToFix);
    tmpVR.pos.PIxy_cm(:,1) = A;
    tmpVR.pos.cumulative_PIxy_cm = B ;
    tmpVR.pos.PIspeed = C ;
    clear A B C;
    end
    
   tmpVR.pos.Trial =  LinearizedTrial ;
end

get_working_pc_and_cd;
eval(['GrandVR.Session_' num2str(ID_RecordedSessions(iSession))  '= tmpVR;' ]);
clear tmpVR;

end


end


% %subplot(1,2,1);plot(mtint.Ephys.ts,mtint.Ephys.xy_cm );
% %subplot(1,2,2);plot(mtint.Ephys.ts,mtint.Ephys.speed);ylim([0 100]);
% %% CreateSpikes =
% %numel(mtint.tetrode.cut)
% 
% 
% Nspikes = 100;
% mtint.tetrode.cut(randi([0 numel(mtint.tetrode.cut)],1,Nspikes))=1;;
% spikePos = mtint.tetrode(3).pos_sample(find(mtint.tetrode(3).cut==1)) ;
% %subplot(1,2,1);
% hold on ; 
% 
% plot(mtint.Ephys.xy_cm,mtint.Ephys.ts,'k');
% hold on;%
% scatter(mtint.Ephys.xy_cm(spikePos),mtint.Ephys.ts(spikePos),'r','filled');
%%
% [mtint.Ephys.ts(1:10) mtint.Vr.pos.ts(1:10)] 
% TimeWindow = [0 SynchAxona(end)-SynchAxona(1)];
% retEphys=hist_perc(mtint.Ephys.ts,Vars.pos.sampleRate^-1/2,[TimeWindow],0);
% retVR=hist_perc(mtint.Vr.pos.ts,Vars.pos.sampleRate^-1/2,[TimeWindow],0);
% 
% mtint.Combined.pos.ts = retEphys.x;
% mtint.Vr.pos.pos(retVR.bin)











