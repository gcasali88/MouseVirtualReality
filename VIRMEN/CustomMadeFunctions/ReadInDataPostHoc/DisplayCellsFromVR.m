function Output = DisplayCellsFromVR(Experiment,Mouse,Date,VROnly,ReRunDataSet,LoadDataSet ,LoadDataSetAlreadyRun, ExtractCells, SaveTheta, NShuffles, ~,MEC_Tetrodes,HPC_Tetrodes,Method,OpenFieldShuffles , ReMakeFigures) ;
% Experiment = 'CueLocking';
% Mouse = 'm3193';
% Date = '20180205';
% VROnly = 0;
% ReRunDataSet =0  ;
% LoadDataSet = 0;
% LoadDataSetAlreadyRun = 1;
% ExtractCells = 0;
% NShuffles = 1;
% RunSarahVersion = false;

if ~exist('Method')
Method = 'Combined';
end; ;

Vars = daVarsStruct;
NewAllCells = [];

if strcmp(getenv('COMPUTERNAME'),'P-TROUX-LAB8')
    Parameters.ComputerDirectory = get_working_pc_and_directory ('/Volumes/groupfolders/DBIO_BarryLab_DATA/giulioC/Data/VR/','D:\VR');
else
    Parameters.ComputerDirectory = get_working_pc_and_directory ('/Volumes/groupfolders/DBIO_BarryLab_DATA/giulioC/Data/VR/','S:\DBIO_BarryLab_DATA\giulioC\Data\VR');
end;
Parameters.Divider = get_working_pc_and_directory ('/','\');
Parameters.MotherDirectory =  [ Parameters.ComputerDirectory Parameters.Divider ];
Parameters.FlagFigure = 0;
Parameters.SaveFlagFigure=1;
Parameters.surfaces = {'VR' 'OpenField' } ;
Parameters.Experiment = Experiment;clear Experiment;%'Uncertainty';
Parameters.Mouse = Mouse;clear Mouse;%'m3194';
Parameters.Date = Date; clear Date;%'20180226';
Parameters.VROnly =VROnly; clear VROnly;
Parameters.RunKKWick =0 ;
Parameters.BatchCluFiles = 0;
Parameters.NShuffles = NShuffles;
Parameters.SaveTheta = SaveTheta;
Parameters.MapType = 'Gauss';
if ~exist('OpenFieldShuffles')
OpenFieldShuffles = 100;
end
Parameters.OpenFieldShuffles = OpenFieldShuffles; 
Parameters.OpenFieldBootStraps = 100;
Parameters.OpenFieldGridScorePercentile = Vars.VR.OpenField.GridScorePercentile ;
Parameters.OpenFieldSacToChoose = 'Best'; % {'Best' ,'St' ,'Reg'};
Parameters.OpenFieldSpeedFilter = 1 ; 
Parameters.OpenFieldSpeedMinSpeed = 5 ; 
Parameters.Method = Method; %% it was SpikeShuffle;
Parameters.Species = 'Mouse';
Parameters.Brain = 'MEC';
Parameters.RunClimerCode = 0;
Parameters.SignificantGridCells  = [];
Parameters.SignificantPlaceCells = [];
Parameters.SignificantSpeedCells = [];
Parameters.SignificantCueLockingCells = [];
Parameters.SignificantLateralCueLocking = [];
Parameters.MEC_Tetrodes = MEC_Tetrodes;
Parameters.HPC_Tetrodes = HPC_Tetrodes;

Vars = daVarsStruct ;
Parameters.FilePath = [ Parameters.MotherDirectory Parameters.Experiment Parameters.Divider Parameters.Mouse   Parameters.Divider Parameters.Date   Parameters.Divider ];
cd(Parameters.FilePath);

list_name_set = dir([Parameters.FilePath '*.set']);
if numel(list_name_set)>0
SetFiles  = natsort(list_trials( list_name_set )); clear list_name_set;
for iFile = 1 : length(SetFiles)
SetPath{iFile} = [Parameters.FilePath SetFiles{iFile}(1:end-4)];
end
end
%isdir('kwiktint') 4
if exist('kwiktint') ==7 & Parameters.RunKKWick
Parameters.dlg_title = 'KK warning';
Parameters.num_lines = 1;
Parameters.Prompt  = {'Run Automated KK via Tint again?'};
defaultans = {num2str(Parameters.RunKKWick)};
Answers =  (inputdlg(Parameters.Prompt,Parameters.dlg_title,Parameters.num_lines ,defaultans) );
Parameters.RunKKWick = str2double(Answers{1});
end
    
if Parameters.RunKKWick
kwiktint_wrapup([],[],[SetFiles{1}(1:end-4)],SetFiles,SetPath)
end;
%% Create Parameter paths...

Parameters.ThetaFigurePath = [Parameters.FilePath   'Theta' Parameters.Divider]; 
Parameters.CellsFigurePath = [Parameters.FilePath 'Cells' Parameters.Divider]; 
Parameters.LickingFigurePath = [Parameters.FilePath 'Licking' Parameters.Divider];  
Parameters.PopulationEnsembleFigurePath = [Parameters.FilePath 'PopulationEnsemble' Parameters.Divider];   
Parameters.MatlabOutputPath = [Parameters.FilePath 'MatlabOutputPath' Parameters.Divider];  
Parameters.MatlabSingleRateMaps = [Parameters.FilePath 'MatlabSingleRateMaps' Parameters.Divider];  
Parameters.SpatialDecoding = [Parameters.FilePath 'SpatialDecoding' Parameters.Divider];  
Parameters.NewClusterSpace = sum(strcmp(ConcatentateIntoStructureIndices(dir,'.','name',[],11),'NewClusterSpace.txt')) | ~sum(strcmp(ConcatentateIntoStructureIndices(dir,'.','name',[],11),'SameClusterSpace.txt')) ;
if ~strcmp(computer,'MACI64')
    mkdir(Parameters.MatlabOutputPath);
    mkdir(Parameters.MatlabSingleRateMaps);
    mkdir(Parameters.SpatialDecoding );
end
Output.AllCells = NewAllCells;
Output.Parameters =Parameters;
Output.Theta =[];
Output.LickMap = [];
Output.SpatialDecoding = [];

if ReRunDataSet==4;ReMakeFigures = 4;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~ExtractCells


 if ~LoadDataSetAlreadyRun ;

     
     %% Run analysis again otherwise load mat file previously conducted....

    if ReRunDataSet && (LoadDataSet==0);
        if ~exist('ReMakeFigures','var');ReMakeFigures = 0 ; end;
        ConcatenateAndBatchCluFiles( Parameters, SetFiles );
        ModifyExactFileOfCutFile( Parameters.FilePath,SetFiles);
        cd(Parameters.FilePath);
        CutFiles = dir([Parameters.FilePath '*.cut']);
        if isempty(Parameters.VROnly)
            Parameters.VROnly = isempty(strfind(SetFiles{1},'openfield')) ;
        end
        if numel(CutFiles) == 0; disp('No cut files found, go back to tint you lazy boy...');return; end;
        [VRs,OpenField,FilePath] = SynchVRAndAxonaEphys(Parameters.Experiment,Parameters.Mouse,Parameters.Date ,Parameters.VROnly);
        Sessions = fields(VRs);;
        cd(Parameters.MatlabOutputPath);
        save([ Parameters.Experiment '_' Parameters.Mouse '_'  Parameters.Date '_VRs' ], [ 'VRs' ],'-v7.3') ; disp('VRs saved...');
        save([ Parameters.Experiment '_' Parameters.Mouse '_'  Parameters.Date '_OpenField' ], [ 'OpenField' ],'-v7.3') ;disp('OpenField saved...');    
         
%         for iSession = 1 : numel(Sessions)
%             eval(['VR  = VRs.' Sessions{iSession} '; ' ]);
%             for Tetrode = 1 : numel(VR.tetrode)
%                 eval(['Tetrode_' num2str(Tetrode) '.' Sessions{iSession}. = VR.tetrode(Tetrode).ts  ; ' ]);
%                 cd(Parameters.MatlabOutputPath);
%                 save([ 'Tetrode_' num2str(Tetrode) ] ,[ 'Tetrode_' num2str(Tetrode)  ] ,'-v7.3');
%             end
%         end
        
        
        %% Save instantaneous Gains if there was any Gain manipulation...
        if eval(['isfield(VRs.' Sessions{1}  '.pos,' char(39) 'PIxy_cm' char(39) ' ) &&  isfield(VRs.' Sessions{1}  '.Virmen, ' char(39) 'GainManipulation' char(39) ' ) ;' ] ) ; %% it means that the Gain was changed...
            cd(Parameters.MatlabOutputPath);
                for Session = 1 : numel(Sessions)
                    if eval(['isfield(VRs.' Sessions{Session} '.Virmen,' char(39) 'GainManipulation' char(39) ') ;' ])  
                        if eval(['isfield(VRs.' Sessions{Session} '.Virmen.GainManipulation,' char(39) 'Gain' char(39) ') ;' ]);
                        eval(['data = VRs.' Sessions{Session} '.Virmen.GainManipulation.Gain; ' ]);
                        elseif eval(['isfield(VRs.' Sessions{Session} '.Virmen.GainManipulation,' char(39) 'Gains' char(39) ') ;' ]);
                        eval(['data = VRs.' Sessions{Session} '.Virmen.GainManipulation.Gains; ' ]);
                        end
                    subplot(numel(Sessions),2,2*(Session-1) +1);
                    hist_perc(data,[0.20],[0 10],1 ); xlabel('Gain');ylabel('Prob'); 
                    eval(['title([VRs.' Sessions{Session} '.Virmen.vr.LevelOfUncertainty ' char(39) ' uncertainty' char(39) ']);' ])

                    subplot(numel(Sessions),2,2*(Session-1) +2);
                    hist_perc(log(data),[0.20],[-5 5],1 ); xlabel('Gain');ylabel('Prob'); 
                    eval(['title([VRs.' Sessions{Session} '.Virmen.vr.LevelOfUncertainty ' char(39) ' uncertainty' char(39) ']);' ])

                    eval(['Gains.' Sessions{Session} ' = data;' ]);
                    clear data;
                    end
                end

                title_Cell = [ 'Gains' ];
                set(gcf,'NumberTitle','off','Name',[title_Cell ],'PaperOrientation','portrait','PaperUnits','normalized','PaperPosition', [0 0 1 1]);
                cd(Parameters.MatlabOutputPath);
                SAVE_Figure(gcf,title_Cell,'pdf');
                disp (['Figures from ' title_Cell ' properly saved and stored into correct directory'])
                close;clear Session title_Cell;
                save('Gains','Gains');clear Gains;
        end
        
        %% Look at EEG now...
        for Session = 1 : numel(Sessions)
        %eval(['VR = VRs.' Sessions{Session} ';' ]);
        %eval(['VRs.' Sessions{Session} '.pos.xy_cm(find(VRs.' Sessions{Session} '.pos.xy_cm(:,1)<0),1)=0;' ]);
        %eval(['VRs.' Sessions{Session} '.pos.xy_cm(:,2) = rand(size(VRs.' Sessions{Session} '.pos.xy_cm(:,1),1),1) ;' ])
        eval(['EEG.Data.VR_' Sessions{Session}  '= VRs.' Sessions{Session} ';' ]);
        eval(['EEG.Surfaces.VR_' Sessions{Session}  ' = [' char(39) 'VR_' Sessions{Session} char(39) '];' ]);
        end
        if ~Parameters.VROnly
        EEG.Data.OpenField = OpenField;
        EEG.Surfaces.OpenField = 'OpenField';
        EEG.Control = 'OpenField';
        else
        %EEG.Control ='VR_Session_1';
        EEG.Control =[ 'VR_'  Sessions{1}] ;
        end
        cd(Parameters.FilePath )
        if isdir(Parameters.ThetaFigurePath );cmd_rmdir('Theta');                           end;
        if Parameters.SaveTheta~=2        
              if isdir(Parameters.LickingFigurePath );            cmd_rmdir('Licking');                           end;
                if isdir(Parameters.PopulationEnsembleFigurePath ); cmd_rmdir('PopulationEnsemble');                end;
                if ReRunDataSet == 2
                    if isdir(Parameters.CellsFigurePath );              cmd_rmdir('Cells');                             end;
                    if isdir(Parameters.MatlabSingleRateMaps );         cmd_rmdir('MatlabSingleRateMaps');                end;
                end
        end;
        mkdir(Parameters.ThetaFigurePath);
        mkdir(Parameters.LickingFigurePath);
        mkdir(Parameters.PopulationEnsembleFigurePath);
        mkdir(Parameters.CellsFigurePath);
        mkdir(Parameters.MatlabSingleRateMaps);
        %% Analysis of LFP theta...
        [~, MEC_VR_OpenFieldThetaBehaviourStats] = ReadAllFloorWallOpenFieldEEGDataSet (EEG,Parameters.Mouse,Parameters.FlagFigure,num2str(1),Parameters.ThetaFigurePath,{Parameters.Date},1,[],Parameters.SaveFlagFigure,'Mouse','PowerSpectrum');
        Hilberts  = []; HilbertSessions = fields(MEC_VR_OpenFieldThetaBehaviourStats) ;
        for iSession = 1 : numel( HilbertSessions )
        eval(['Hilberts.' HilbertSessions{iSession} ' =  MEC_VR_OpenFieldThetaBehaviourStats.' HilbertSessions{iSession} '.theta.Hilbert ; ' ]);
        end ; clear HilbertSessions iSession ;
        cd(Parameters.MatlabOutputPath);
        if Parameters.SaveTheta>0;
        disp(['Saving' Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '...' ])
        save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Theta'  ],['MEC_VR_OpenFieldThetaBehaviourStats'], '-v7.3');
        save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Hilbert'  ],['Hilberts'], '-v7.3');        
        
        if Parameters.SaveTheta==2; 
        %% SAME AS EXTRACTING CELLS AND SIMPLY ADD THETA RESULTS TO IT...
            cd(Parameters.MatlabOutputPath);
            if exist([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Cells.mat'  ]) == 2  ;
            load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Cells'  ]  );
            %% If the open field data was not saved in NewAllCells load the AllCells structure and add it so
            if ~isfield(NewAllCells,'Openfield')
            load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  ],'AllCells');
            for iCell = 1 : numel(NewAllCells)
            NewAllCells(iCell).Openfield  = AllCells(iCell).OpenField;
            end
            if ~strcmp(Parameters.Experiment , 'Multicompartment' )
            save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Cells'  ], 'NewAllCells','Parameters','CollapsedCellsAcrossCues','-v7.3');
            end
            end;
            end
            %% Output....
            Output.AllCells = NewAllCells;
            Output.Parameters =Parameters;
            Output.Theta = MEC_VR_OpenFieldThetaBehaviourStats;
        return;
        end
            
        end;
        
        Output.Theta = MEC_VR_OpenFieldThetaBehaviourStats;
        clear EEG MEC_VR_OpenFieldThetaBehaviourStats EEG;
        cd(Parameters.MatlabOutputPath);
        save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  '_ToRun'],'-v7.3');
    elseif LoadDataSet & ReRunDataSet==0
        NewLoadDataSet = LoadDataSet;
        NewRunDataSet= ReRunDataSet;
        if strcmp(getenv('COMPUTERNAME'),'P-TROUX-LAB8')
           Parameters.ComputerDirectory = get_working_pc_and_directory ('/Volumes/groupfolders/DBIO_BarryLab_DATA/giulioC/Data/VR/','D:\VR');
        else
            Parameters.ComputerDirectory = get_working_pc_and_directory ('/Volumes/groupfolders/DBIO_BarryLab_DATA/giulioC/Data/VR/','S:\DBIO_BarryLab_DATA\giulioC\Data\VR');
        end
        Parameters.Divider = get_working_pc_and_directory ('/','\');
        Parameters.MotherDirectory =  [ Parameters.ComputerDirectory Parameters.Divider ];
        Parameters.FilePath = [ Parameters.MotherDirectory Parameters.Experiment Parameters.Divider Parameters.Mouse   Parameters.Divider Parameters.Date   Parameters.Divider ];
        Parameters.MatlabOutputPath = [Parameters.FilePath 'MatlabOutputPath' Parameters.Divider];  
        cd(Parameters.MatlabOutputPath);
        load ([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  '_ToRun']);
        if strcmp(getenv('COMPUTERNAME'),'P-TROUX-LAB8')
           Parameters.ComputerDirectory = get_working_pc_and_directory ('/Volumes/groupfolders/DBIO_BarryLab_DATA/giulioC/Data/VR/','D:\VR');
        else
            Parameters.ComputerDirectory = get_working_pc_and_directory ('/Volumes/groupfolders/DBIO_BarryLab_DATA/giulioC/Data/VR/','S:\DBIO_BarryLab_DATA\giulioC\Data\VR');
        end
        Parameters.Divider = get_working_pc_and_directory ('/','\');
        Parameters.MotherDirectory =  [ Parameters.ComputerDirectory Parameters.Divider ];
        Parameters.FilePath = [ Parameters.MotherDirectory Parameters.Experiment Parameters.Divider Parameters.Mouse   Parameters.Divider Parameters.Date   Parameters.Divider ];
        Parameters.MatlabOutputPath = [Parameters.FilePath 'MatlabOutputPath' Parameters.Divider];  
        Parameters.PopulationEnsembleFigurePath = [Parameters.FilePath 'PopulationEnsemble' Parameters.Divider];   
        Parameters.MatlabSingleRateMaps = [Parameters.FilePath 'MatlabSingleRateMaps' Parameters.Divider];  cd(Parameters.MatlabOutputPath);
        Parameters.SpatialDecoding = [Parameters.FilePath 'SpatialDecoding' Parameters.Divider];  mkdir(Parameters.SpatialDecoding) ;  
        Parameters.ThetaFigurePath = [Parameters.FilePath   'Theta' Parameters.Divider];mkdir(Parameters.ThetaFigurePath) ;  
        Parameters.CellsFigurePath = [Parameters.FilePath 'Cells' Parameters.Divider]; mkdir(Parameters.CellsFigurePath) ; 
        Parameters.LickingFigurePath = [Parameters.FilePath 'Licking' Parameters.Divider];mkdir(Parameters.LickingFigurePath) ; 
        Parameters.VROnly = isempty(strfind(SetFiles{1},'openfield')) ;
        if ~isfield(Parameters,'MatlabSingleRateMaps');
            Parameters.MatlabSingleRateMaps = [Parameters.FilePath 'MatlabSingleRateMaps' Parameters.Divider];  
        end;mkdir( Parameters.MatlabSingleRateMaps );
        LoadDataSet = NewLoadDataSet; clear NewLoadDataSet;
        ReMakeFigures = LoadDataSet - 1 ;
        ReRunDataSet =NewRunDataSet; clear NewRunDataSet;
    end
    %%
    
LickColor = Vars.VR.Display.LickColor;
VRSpikeColor = Vars.VR.Display.SpikeColor;SpikeDotSize = 3;RateMapLineWidth = 2;
OFSpikeColor = Vars.SpeedModulation.OpenFieldColor;
TrackColor = Vars.VR.Display.TrackColor;TrackLineSize = 1;
RewardColor = Vars.VR.Display.RewardColor;
InsideRewardAreaLick= Vars.VR.Display.InsideRewardAreaLick;
OutsideRewardAreaLick= Vars.VR.Display.OutsideRewardAreaLick;
if eval([ 'strcmp(VRs.' Sessions{1} '.Virmen.vr.exper.name,' char(39) 'MultiCompartmentExperiment' char(39) ' );  ' ]);XTickForSpikePlot = Vars.VR.Display.XTickForSpikePlot;else;XTickForSpikePlot = 100;end
if ~exist('ReMakeFigures','var');ReMakeFigures = 0 ; end;

%% Detect boundaries of the environments....
eval(['VR = VRs.' Sessions{1} '; '  ]);
Compartments = [];
Boundaries = [];
ForEachCompartmentVisits = {};
RewardedEnvironmentIndex = [];
SmoothingFactor = Vars.rm.smthKernPos;


if isfield(VR.Virmen.vr,'WorldIndexWithReward');WorldWithRewardArea = VR.Virmen.vr.WorldIndexWithReward;else;WorldWithRewardArea = 1;VR.Virmen.vr.WorldIndexWithReward = WorldWithRewardArea;end

TotalVisits = 0;
if ~isfield(VR.pos,'NumberOfVisits') & strcmp(VR.Virmen.vr.Experiment,'Multicompartment')
    Boundaries =[50 350;400 700;750 1050;1100 1400];
    ForEachCompartmentVisits ={'A_1','B_1','B_2','C_1'};
    RewardedArea(:,:,1) =[530   570;630   670];
    RewardedArea(:,:,2) =[880   920;980  1020];
    Compartments = {'A'    'B'    'C'};
    elseif ~isfield(VR.pos,'NumberOfVisits') & strcmp(EEGVR.Virmen.vr.Experiment,'Training')
    Boundaries =[0 VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.EndPipe}.y(1)];
    ForEachCompartmentVisits ={'TrainingWorld_1'};
    GoalCueAreasInRewardedEnvironment = [   (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y) - (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2) - VR.Virmen.vr.RewardWindowWidth/2, ...     
                                            (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y) - (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2) + VR.Virmen.vr.RewardWindowWidth/2 ];
    RewardedArea(:,:,1) =[GoalCueAreasInRewardedEnvironment];
    Compartments = {'TrainingWorld'};  
    elseif strcmp(VR.Virmen.vr.Experiment,'FixingPoint');
    Boundaries = [VR.Virmen.vr.WallXLimits ;VR.Virmen.vr.WallYLimits ];
    ForEachCompartmentVisits ={'World1_1'};
    GoalCueAreasInRewardedEnvironment = [VR.Virmen.vr.circle ];
    Compartments =   {'World1'};
    else
       if strcmp(VR.Virmen.vr.Experiment,'Training');
        Compartments = {'TrainingWorld'};  
        Boundaries = [0 VR.Virmen.vr.exper.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects{VR.Virmen.vr.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects.indices.EndPipeWall}.y(1)];
       elseif strcmp(VR.Virmen.vr.Experiment,'Multicompartment');
        Compartments = {'A'    'B'    'C'};
       elseif strcmp(VR.Virmen.vr.Experiment,'TeleTunnel');
        Compartments = {'tunnel1'    'tunnel2'    'tunnel3'};
       elseif strcmp(VR.Virmen.vr.Experiment,'Uncertainty');
       Compartments =   {'A'    'B'    'C'};
       Boundaries = [0 1000];
       elseif strcmp(VR.Virmen.vr.Experiment,'VisualUncertainty')
       Compartments =   {'X'    'Y'    'Z'};
       Boundaries = [0 500];

       elseif strcmp(VR.Virmen.vr.Experiment,'CueLocking');
       Compartments =   {'A'    'B'    'C'};
       Boundaries = [0 1000];
       elseif strcmp(VR.Virmen.vr.Experiment,'MovingCue');
       Compartments =   {'Q1' 'Q2'};
       end

            for iEnvironment  = 1 : numel(Compartments)
            MaxVisits = unique([; unique( VR.pos.NumberOfVisits( VR.pos.Environment== VR.Virmen.vr.EnvironmentSettings.LabelEnvironment(find(strcmp(VR.Virmen.vr.EnvironmentSettings.Evironments ,Compartments{iEnvironment})))))]);   
            for  iVisit = 1 : max( MaxVisits)
            TotalVisits = TotalVisits + 1;
            if isempty(Boundaries)
                Boundaries = [Boundaries; 10*round(FindExtremesOfArray(VR.pos.xy_cm( ...
             find(VR.pos.Environment== VR.Virmen.vr.EnvironmentSettings.LabelEnvironment(find(strcmp(VR.Virmen.vr.EnvironmentSettings.Evironments ,Compartments{iEnvironment}))) ...
            & VR.pos.NumberOfVisits == iVisit) ))/10)] ; 
            end
            ForEachCompartmentVisits{end+1} = [Compartments{iEnvironment} '_' num2str(iVisit) ];
            if strcmp(Compartments{iEnvironment},VR.Virmen.vr.WorldNameWithReward)
            RewardedEnvironmentIndex =[RewardedEnvironmentIndex;TotalVisits];
            end
            %eval(['RateMap.Compartments.Compartment_' Compartments{iEnvironment} '_Visit_' num2str(iVisit) '= RateMap.map ( FindElementsWithMultipleBoundaries(RateMap.Pos, Boundaries(end,:),' char(39) 'inside' char(39) ') )  ;' ])
            end
            end
end;

%% Set GoalCueAreasInRewardedEnvironment....
if eval(['strcmp(VRs.' Sessions{1} '.Virmen.vr.exper.name,' char(39) 'MultiCompartmentExperiment' char(39) ')  ;  ' ])  ;
GoalCueAreasInRewardedEnvironment = [   VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y - VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.radius ...
                                        VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y + VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.radius  ] ;

elseif eval(['strcmp(VRs.' Sessions{1} '.Virmen.vr.exper.name,' char(39) 'TrainingApparatus'  char(39) ' ) ; ' ]);
    if ~isfield(VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices,'GoalCueOLD')
        GoalCueAreasInRewardedEnvironment = [   (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y) - (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2) - VR.Virmen.vr.RewardWindowWidth/2, ...     
                                            (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y) - (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2) + VR.Virmen.vr.RewardWindowWidth/2 ];
    elseif isfield(VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices,'GoalCue')
       GoalCueAreasInRewardedEnvironment = [ (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y  )] ;
    elseif isfield(VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices,'GoalCueOLD')
       GoalCueAreasInRewardedEnvironment = [ reshape(VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCueOLD}.y , [], 2 )] ;
    end
    % Check in case erroneously multiple reward area are assigned to the
    % Training Apparatus...
    for iSession = 1 : numel(Sessions)
    eval(['VRs.Session_' num2str(iSession) '.Virmen.vr.NumberOfCues = 1 ;' ]);
    end;
    eval(['VR = VRs.' Sessions{1} '; ;' ]);

elseif eval(['strcmp(VRs.' Sessions{1} '.Virmen.vr.exper.name,' char(39) 'Charlie_test' char(39) ' ) ; ' ]);
    GoalCueAreasInRewardedEnvironment = [   ];%(VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y) - (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2) - VR.Virmen.vr.RewardWindowWidth/2, ...     ...(VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y) - (VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2) + VR.Virmen.vr.RewardWindowWidth/2 ];
elseif eval(['strcmp(VRs.' Sessions{1} '.Virmen.vr.exper.name,' char(39) 'UncertaintyExperiment' char(39) ' ) ; ' ]);
    GoalCueAreasInRewardedEnvironment = [   VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y - VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.radius ...
                                        VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y + VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.radius  ] ;
elseif eval(['strcmp(VRs.' Sessions{1} '.Virmen.vr.exper.name,' char(39) 'UncertaintyNew' char(39) ' ) ; ' ]);
    GoalCueAreasInRewardedEnvironment = [   VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y - VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.radius ...
                                        VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y + VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.radius  ] ;
elseif eval(['strcmp(VRs.' Sessions{1} '.Virmen.vr.exper.name,' char(39) 'CueLockingExperiment' char(39) ');' ]  )
    GoalCueAreasInRewardedEnvironment = [   VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y - VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.radius ...
                                        VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y + VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.radius  ] ;
elseif  eval(['strcmp(VRs.' Sessions{1} '.Virmen.vr.exper.name,' char(39) 'VisualUncertainty' char(39) ' ) ; ' ]);
    GoalCueAreasInRewardedEnvironment = [360 ; 400 ; 320  ];
    GoalCueAreasInRewardedEnvironment = [GoalCueAreasInRewardedEnvironment - VR.Virmen.vr.RewardWindowWidth/2 , GoalCueAreasInRewardedEnvironment + VR.Virmen.vr.RewardWindowWidth/2] ;
       
elseif strcmp(VRs.Session_1.Virmen.vr.exper.name,'MovingCues' )
    GoalCueAreasInRewardedEnvironment = [ ];
end

for iEnvironment = 1 : numel(RewardedEnvironmentIndex)                                  
for iReward = 1 : VR.Virmen.vr.NumberOfCues 
RewardedArea(:,:,iEnvironment) = Boundaries(RewardedEnvironmentIndex(iEnvironment),1) + GoalCueAreasInRewardedEnvironment ;
end
end
   
Parameters.LocalMethods = {'LocalMeanMap' 'LocalFidelity' 'LocalStability' 'LocalSigmaMap' 'LocalNormSigmaMap' 'LocalZOverDispersion'};
Parameters.CueEffects.LocalShifts = { 'XCorr' };
 
%% Do some housekeeping clearance to free up space.
clear EEG Gains  MEC_VR_OpenFieldThetaBehaviourStats Hilberts CutFiles;
clear iEnvironment iReward iVisit iFile LoadDataSet LoadDataSetAlreadyRun ;
%InsideRewardAreaLick  GoalCueAreasInRewardedEnvironment  
%% Now determine all cells across tetrodes. 

CellsAcrossTetrodes = [];
for iTetrode = 1 : eval(['numel(VRs.' Sessions{1} '.tetrode);']);
tmpCells = [];
for iSession= 1 : numel(Sessions);
eval([ 'tmpCells = [tmpCells;setdiff([unique(VRs.' Sessions{iSession} '.tetrode(iTetrode).cut)], 0)];' ]);
end;
tmpCells = sort(unique(tmpCells)) ;
CellsAcrossTetrodes = [CellsAcrossTetrodes ;repmat(iTetrode,[numel(tmpCells)],1) tmpCells] ;
clear tmpCells
end ; clear iTetrode;
CellsAcrossTetrodes =  [reshape([1 : size(CellsAcrossTetrodes,1)],[],1) CellsAcrossTetrodes ] ;

Parameters.CellsAcrossTetrodes = CellsAcrossTetrodes;
Parameters.CellsToAnalyse = reshape((1  : size(CellsAcrossTetrodes,1)),[],1);
clear CellsAcrossTetrodes iSession Cluster Cluster_id;

%% Now determine which cells need to be analysed - i.e. not previously ran...


cd(Parameters.MatlabSingleRateMaps);
CellsAlreadyAnalysed =  dir([Parameters.MatlabSingleRateMaps,'*.mat']) ;

for iCell = 1 : numel(CellsAlreadyAnalysed)
Cell_id  = min(strfind(CellsAlreadyAnalysed(iCell).name,'ID_#_'))+ numel('ID_#_')   ;
Animal_id = strfind(CellsAlreadyAnalysed(iCell).name,(['_' Parameters.Mouse '_'])) + numel(['_' Parameters.Mouse '_']) ;
Tetrode_id = strfind(CellsAlreadyAnalysed(iCell).name,'_Tetrode_') + numel('_Tetrode_') ;
Cluster_id  = max(strfind(CellsAlreadyAnalysed(iCell).name,'_Cell_')) + numel('_Cell_') ;
Mat_id  = max(strfind(CellsAlreadyAnalysed(iCell).name,'.mat')) ;

tmpCellID = str2num(CellsAlreadyAnalysed(iCell).name(Cell_id :(Animal_id - [numel(['_' Parameters.Mouse '_'])+1] ) ) );
tmpTetrode = str2num(CellsAlreadyAnalysed(iCell).name( Tetrode_id :(Cluster_id- [numel('_Cell_')+1] ) ) );
tmpCluster = str2num(CellsAlreadyAnalysed(iCell).name( Cluster_id : Mat_id)) ;
Parameters.CellsToAnalyse(find(Parameters.CellsAcrossTetrodes(:,1) == tmpCellID & Parameters.CellsAcrossTetrodes(:,2) == tmpTetrode &  Parameters.CellsAcrossTetrodes(:,3) == tmpCluster)) = [0];
end; 
clear Cell_id Animal_id Tetrode_id Cluster_id Mat_id tmpCellID tmpTetrode tmpCluster

Parameters.CellsToAnalyse = find(Parameters.CellsToAnalyse);

%% Produce rate maps of cells...
 if ReRunDataSet == 2;
   CellsToPlot = 1 : size(Parameters.CellsAcrossTetrodes,1) ;     
 elseif ReMakeFigures==0 ;
    CellsToPlot = (Parameters.CellsToAnalyse) ;
 elseif ReMakeFigures==1;
   CellsToPlot = 1 : size(Parameters.CellsAcrossTetrodes,1) ;   
 elseif    ReMakeFigures==2 
   CellsToPlot = 1 : size(Parameters.CellsAcrossTetrodes,1) ;
 elseif ReMakeFigures==3 %% Redo analyses for the Open Field only.
   CellsToPlot = 1 : size(Parameters.CellsAcrossTetrodes,1) ;
 elseif ReMakeFigures==4 
   CellsToPlot = 1 : size(Parameters.CellsAcrossTetrodes,1) ;
 elseif ReMakeFigures==5 %% Run Climer code and Phase Precession in 1D VR...
          CellsToPlot = [Parameters.CellsAcrossTetrodes(:,1)];
%         CellsToPlot = zeros(size(Parameters.CellsAcrossTetrodes ,1),numel(Sessions)) ; 
%         cd(Parameters.MatlabSingleRateMaps);
%            for iCellToAnalyse = transpose(Parameters.CellsAcrossTetrodes(:,1));
%                  eval(['tmpCell = [' char(39) 'Cell_ID_#_' num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,1)) '_' Parameters.Mouse '_' Parameters.Date '_' Parameters.Experiment '_Tetrode_' num2str(num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,2)) ) '_Cell_' num2str(num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,3)) )  '.mat' char(39) '];' ] ) ;
%                     if exist(tmpCell) ==2;
%                         load(tmpCell)
%                           for  iSession = 1 : numel(Sessions)
%                                 eval([ 'CellsToPlot(iCellToAnalyse,iSession ) = ~isfield( RateMaps.' Sessions{iSession} '.VR,' char(39) 'PhasePrecession' char(39) ') ;'  ])
%                           end              
%                     else
%                         CellsToPlot(iCellToAnalyse) = 1;
%                     end ;
%                 clear tmpCell iCellToAnalyse RateMaps;
%            end
%         CellsToPlot = find(nansum(CellsToPlot,2)==numel(Sessions)) ;
 elseif ReMakeFigures == 6;
     CellsToPlot = [];
 elseif ReMakeFigures == 7; %% Run Speed cell analyses...
     CellsToPlot = [Parameters.CellsAcrossTetrodes(:,1)];

%                     for iCellToAnalyse = transpose(Parameters.CellsAcrossTetrodes(:,1));
%                         eval(['tmpCell = [' char(39) 'Cell_ID_#_' num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,1)) '_' Parameters.Mouse '_' Parameters.Date '_' Parameters.Experiment '_Tetrode_' num2str(num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,2)) ) '_Cell_' num2str(num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,3)) )  '.mat' char(39) '];' ] ) ;
%                         if exist(tmpCell) ==2;
%                         load(tmpCell)
%                             for  iSession = 1 : numel(Sessions)
%                                 eval([ 'CellsToPlot(iCellToAnalyse,iSession ) = ~isfield( RateMaps.' Sessions{iSession} '.VR,' char(39) 'SpeedModulation' char(39) ') ;'  ])
%                             end              
%                          else
%                         CellsToPlot(iCellToAnalyse) = 1;
%                         end ;
%                     end
%                     CellsToPlot = find( nansum(CellsToPlot,2)>0);
%                 clear tmpCell iCellToAnalyse RateMaps;
           
  elseif ReMakeFigures == 8; %% Re-Run Cue-locking analysis...
     CellsToPlot = [Parameters.CellsAcrossTetrodes(:,1)];
  elseif ReMakeFigures == 9; %% Re-Run Cue-locking analysis...
    CellsToPlot = [Parameters.CellsAcrossTetrodes(:,1)];%% Analyse Stability measures of ratemaps across repeated laps...
%      for iCellToAnalyse = transpose(Parameters.CellsAcrossTetrodes(:,1));
%          eval(['tmpCell = [' char(39) 'Cell_ID_#_' num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,1)) '_' Parameters.Mouse '_' Parameters.Date '_' Parameters.Experiment '_Tetrode_' num2str(num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,2)) ) '_Cell_' num2str(num2str(Parameters.CellsAcrossTetrodes(iCellToAnalyse,3)) )  '.mat' char(39) '];' ] ) ;
%          if exist(tmpCell) ==2;
%              load(tmpCell)
%              for  iSession = 1 : numel(Sessions)
%                     %eval([ 'CellsToPlot(iCellToAnalyse,iSession ) = ~isfield( RateMaps.' Sessions{iSession} '.VR,' char(39) 'LocalMap' char(39) ') ;'  ])
%                     %eval([ 'CellsToPlot(iCellToAnalyse,iSession ) = ~isfield( RateMaps.' Sessions{iSession} '.VR,' char(39) 'LocalMap' char(39) ') ;'  ])
%                     eval(['MissingLocalMethod = Parameters.LocalMethods(~ismember(Parameters.LocalMethods, fields(RateMaps.' Sessions{iSession} '.VR.LocalMap ))); ' ]) 
%                     CellsToPlot(iCellToAnalyse,iSession ) = numel(MissingLocalMethod)>0 ;
%              end
%          else
%              CellsToPlot(iCellToAnalyse) = 1;
%          end ;
%      end
%      CellsToPlot = find( nansum(CellsToPlot,2)>0);
%      clear tmpCell iCellToAnalyse RateMaps;
%        if isempty(CellsToPlot)
%           return; 
%        end
 end
 
 if strcmp(Parameters.Experiment ,'VisualUncertainty')
 [ Parameters ] = GetCueMasksFromVisualUncertaintyInsideSession( VRs,Parameters );
 end
 
 
for iCellToAnalyse = 1: numel( CellsToPlot ) ;
    %Parameters.CellID = 0;;%AllCells = [];%for Tetrode = 1  : eval(['numel(VRs.' Sessions{1} '.tetrode) ; ' ]);;%Clusters  = [];%for iSession = 1 : numel(Sessions);%eval(['Clusters = [Clusters;[unique(VRs.' Sessions{iSession} '.tetrode(Tetrode).cut)] ];' ]);%end;%Clusters = unique(Clusters); Clusters =Clusters(~ismember(Clusters,0));%for Cluster = 1  : length(Clusters) ;%Cell = Clusters(Cluster) ;%Parameters.CellID = Parameters.CellID +1;
    
    
    Parameters.CellID = Parameters.CellsAcrossTetrodes(CellsToPlot(iCellToAnalyse),1) ;
    Tetrode = Parameters.CellsAcrossTetrodes(CellsToPlot(iCellToAnalyse),2) ;
    Cell = Parameters.CellsAcrossTetrodes(CellsToPlot(iCellToAnalyse),3) ;
    
    figure(1);SpikeWaweforms.VR.Ch1 = [];SpikeWaweforms.VR.Ch2 = [];SpikeWaweforms.VR.Ch3 = [];SpikeWaweforms.VR.Ch4 = [];
    if ReMakeFigures>0 & ReMakeFigures~= 3 | ReMakeFigures==7; ;
    cd(Parameters.MatlabSingleRateMaps)
    title_cell = ['Cell_ID_#_' num2str(Parameters.CellID) '_' Parameters.Mouse '_' Parameters.Date '_' Parameters.Experiment '_Tetrode_' num2str(Tetrode) '_Cell_' num2str(Cell) ] ;
    load(title_cell);  
    else
    RateMaps = [];  
    RateMaps.Mouse = Parameters.Mouse;
    RateMaps.Date = Parameters.Date;
    RateMaps.Experiment = Parameters.Experiment;
    RateMaps.Tetrode = Tetrode;
    RateMaps.Cell = Cell;
    RateMaps.CellID = Parameters.CellID;
    RateMaps.VROnly = Parameters.VROnly;
    end
       
    %%
    MaxPosAcrossSessions = [];
        
        for iSession = 1 : numel(Sessions)
            eval(['VRs.' Sessions{iSession}  '.tetrode(Tetrode).pos_sample(~VRs.' Sessions{iSession}  '.tetrode(Tetrode).ts) = 1 ;' ] );
            eval(['VR = VRs.' Sessions{iSession}  ';' ]);
            cd(Parameters.MatlabOutputPath);
            load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Hilbert'  ]);
            eval(['Hilbert = Hilberts.VR_' Sessions{iSession} ' ;  ' ]); clear Hilberts;

                if strcmp(Parameters.Experiment,'MovingCue') ;
                    Parameters.CueWindow = 50;Parameters.CueLockingShuffles = Parameters.NShuffles;  %% it was 200
                        if  strcmp(VR.Virmen.vr.NameOfTheWorld,'A')
                        eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.World = ' char(39) VR.Virmen.vr.NameOfTheWorld char(39) ';']);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Name = ' char(39) 'A_W_a_l_l' char(39) ';' ]);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Frequency = 1000/10;' ]);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Position = [ .5 1] ;' ]);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Width = diff(Parameters.Cues.Session_' num2str(iSession) ' .Cue1.Both.Position) * Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Frequency ;' ]);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.CueWindow = Parameters.CueWindow;' ]);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Locations = Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Frequency/2:Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Frequency:1000 ;Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Locations = Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Locations  + Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Width/2; ' ]);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Locations = repmat(  Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.Locations, max(VR.pos.Trial),1) ; ' ]);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.SpikeCueColors = jet(numel(fields(Parameters.Cues.Session_' num2str(iSession) ' )) / numel(fields(Parameters.Cues.Session_' num2str(iSession) '.Cue1)) );' ]);eval(['Parameters.Cues.Session_' num2str(iSession) '.Cue1.Both.CueColor =  [VR.Virmen.vr.exper.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects{VR.Virmen.vr.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects.indices.stripeysidewalls }.texture.shapes{4}.R ,VR.Virmen.vr.exper.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects{VR.Virmen.vr.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects.indices.stripeysidewalls }.texture.shapes{4}.G, VR.Virmen.vr.exper.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects{VR.Virmen.vr.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects.indices.stripeysidewalls }.texture.shapes{4}.B] ;' ]); 
                        elseif  strcmp(VR.Virmen.vr.NameOfTheWorld,'Q1') || strcmp(VR.Virmen.vr.NameOfTheWorld,'Q2')
                        WORLDCUES = fields(VR.Virmen.vr.CueLocation) ;  WORLDCUES = WORLDCUES(~ismember(WORLDCUES,'GoalCue')) ; CueSides = {'Left' 'Right'};    NCUES  = numel(WORLDCUES) /  numel(CueSides) ;  SpikeCueColors = jet(NCUES);
                            for iSide = 1 : numel(CueSides) ;for iCue  = [1 : (NCUES)] + ((iSide-1)* NCUES);eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.World = ' char(39)  VR.Virmen.vr.NameOfTheWorld   char(39)  ' ; ' ] );eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.Name = ' char(39)  WORLDCUES{iCue}   char(39)  ' ; ' ] );    eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.Frequency = NaN ;' ]);           eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.Position = NaN ;' ]);                 eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.Width = VR.Virmen.vr.TrialSettings.CueSize ;' ]);                eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.CueWindow = Parameters.CueWindow   ;' ]);                eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.Locations = transpose(VR.Virmen.vr.CueLocation.' WORLDCUES{iCue}  ');' ]);                eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.SpikeCueColors = SpikeCueColors(iCue-((iSide-1)* NCUES),:) ;' ]) ;eval([' Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iCue-((iSide-1)* NCUES)) '.'  CueSides{iSide} '.CueColor = [VR.Virmen.vr.exper.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects{VR.Virmen.vr.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects.indices.'    WORLDCUES{iCue}     ' }.texture.shapes{2}.R, VR.Virmen.vr.exper.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects{VR.Virmen.vr.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects.indices.'    WORLDCUES{iCue}     ' }.texture.shapes{2}.G, VR.Virmen.vr.exper.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects{VR.Virmen.vr.worlds{VR.Virmen.vr.WorldIndexWithReward}.objects.indices.'    WORLDCUES{iCue}     ' }.texture.shapes{2}.B ]; ' ]) ;;end;end;
                          clear WORLDCUES CueSides NCUES  SpikeCueColors iSide iCue ;
                        end;
                end;
                
        %% Spike plots...
        if ReMakeFigures~=4 & ReMakeFigures~=5 & ReMakeFigures~=7 & ReMakeFigures~=8 & ReMakeFigures~=9  ;
            if strcmp(Parameters.Experiment,'Uncertainty')
                SP_VR =subaxis(3*2,numel(Sessions)+2,iSession,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal,'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
                SpikePlotForVR(VR,Tetrode,Cell,VRSpikeColor,SpikeDotSize,TrackColor,TrackLineSize,Boundaries,[],Parameters.Experiment);
                title('VR'); MaxPosAcrossSessions(iSession,1) = max(VR.pos.xy_cm(:,1)); 
                eval(['SP_VR_' Sessions{iSession} ' =   SP_VR ;  ' ] ) ;

                SP_PI = subaxis(3*2,numel(Sessions)+2,iSession+numel(Sessions)+2,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal,'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
                SpikePlotForVR(VR,Tetrode,Cell,VRSpikeColor,SpikeDotSize,TrackColor,TrackLineSize,Boundaries,'PI',Parameters.Experiment);
                title('PI'); MaxPosAcrossSessions(iSession,2) = max(VR.pos.PIxy_cm(:,1)); 
                eval(['SP_PI_' Sessions{iSession} ' =   SP_PI ;  ' ] ) ;


                elseif   ~strcmp(Parameters.Experiment,'MovingCue')  
                SP_VR = subaxis(3,numel(Sessions)+2,iSession,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
                SpikePlotForVR(VR,Tetrode,Cell,VRSpikeColor,SpikeDotSize,TrackColor,TrackLineSize,Boundaries,[],Parameters.Experiment);subplot1 = gca;%title([ Sessions{iSession}(1:end-2) ' ' num2str(iSession)]);
                AddVRCuesToSpikePlot ;
                MaxPosAcrossSessions(iSession,1) = max(VR.pos.xy_cm(:,1)); 
                xlim([FindExtremesOfArray(Boundaries)])
                eval(['SP_VR_' Sessions{iSession} ' =   SP_VR ;  ' ] ) ;
            end
        end
                %% Rate maps
                                 % if RunSarahVersion == false;%             RateMap.VR.RateMap = RateMapForVR(VR,Tetrode,Cell,SmoothingFactor,Vars.rm.binSizePosCm ,VRSpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits,0,Parameters.MapType,[],Parameters.Experiment) ;;%             if strcmp(Parameters.Experiment,'Uncertainty');%             RateMap.PI.RateMap = RateMapForVR(VR,Tetrode,Cell,SmoothingFactor,Vars.rm.binSizePosCm ,VRSpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits,0,Parameters.MapType,'PI',Parameters.Experiment) ;%             end;%         else;% RateMap.VR.RateMap  = RateMapForVRBySarah(VR,Tetrode,Cell,SmoothingFactor,Vars.rm.binSizePosCm ,VRSpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits,0,Parameters.MapType) ;;%         end;%         
                %% Create subplots handles.
         if ReMakeFigures~=4 & ReMakeFigures~=5 & ReMakeFigures~=7 & ReMakeFigures~=8 & ReMakeFigures~=9 ;
                    if strcmp(Parameters.Experiment,'Uncertainty')       
                        RM_VR = subaxis(3*2,numel(Sessions)+2,(iSession+numel(Sessions)+2)+(numel(Sessions)+2)*1,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);%RateMap.VR.TankMethod = TankGridDecoder2(VR,Tetrode,Cell,[],'Tank',[1],0,Parameters.NShuffles,Parameters.Experiment,'',[FindExtremesOfArray(Boundaries)]) ;
                        RM_PI = subaxis(3*2,numel(Sessions)+2,(iSession+numel(Sessions)+2)+(numel(Sessions)+2)*2,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);%RateMap.PI.TankMethod = TankGridDecoder2(VR,Tetrode,Cell,[],'Tank',[1],0,Parameters.NShuffles,Parameters.Experiment,'PI') ;
                        SAC_VR = subaxis(3*2,numel(Sessions)+2,(iSession+numel(Sessions)+2)+(numel(Sessions)+2)*3, 'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);   
                        SAC_PI = subaxis(3*2,numel(Sessions)+2,(iSession+numel(Sessions)+2)+(numel(Sessions)+2)*4,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
                    elseif ~strcmp(Parameters.Experiment,'MovingCue')         
                        RM_VR = subaxis(3,numel(Sessions)+2,iSession+numel(Sessions)+2, 'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0,'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);        %RateMap.VR.TankMethod = TankGridDecoder2(VR,Tetrode,Cell,[],'Tank',[1],0,Parameters.NShuffles,Parameters.Experiment) ;
                        SAC_VR = subaxis(3,numel(Sessions)+2,iSession+(numel(Sessions)+2)*2, 'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0,'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
                    end;
         end
        %% Analyse SCALE....
        if ~strcmp(Parameters.Experiment,'MovingCue')
               
                if strcmp(Parameters.Experiment,'Uncertainty') ; 
                        if ReMakeFigures==1 | ReMakeFigures==2 |  ReMakeFigures== 4 ;
                            eval(['TankGridDecoder2(VR,Tetrode,Cell,[],' char(39) 'Giulio' char(39) ',[RM_VR],[SAC_VR],Parameters.NShuffles,Parameters.Experiment,' char(39) '' char(39) ',[FindExtremesOfArray(Boundaries)],RateMaps.' Sessions{iSession} '.VR.SACMethod) ; ' ]);
                            eval(['TankGridDecoder2(VR,Tetrode,Cell,[],' char(39) 'Giulio' char(39) ',[RM_PI],[SAC_PI],Parameters.NShuffles,Parameters.Experiment,' char(39) 'PI' char(39) ',[FindExtremesOfArray(Boundaries)],RateMaps.' Sessions{iSession} '.PI.SACMethod) ;'  ]);

                        elseif  ReMakeFigures~=7  ; %% Actually run analysis...
                            [RateMap.VR.SACMethod] = TankGridDecoder2(VR,Tetrode,Cell,[],'Giulio',[RM_VR],[SAC_VR],Parameters.NShuffles,Parameters.Experiment,'',[FindExtremesOfArray(Boundaries)]) ;
                            [RateMap.PI.SACMethod] = TankGridDecoder2(VR,Tetrode,Cell,[],'Giulio',[RM_PI],[SAC_PI],Parameters.NShuffles,Parameters.Experiment,'PI',[]) ;
                            [RateMap.VR.Oscillation] = RunAutocorrelogramAtDifferentSpeedsGC( VR,Tetrode ,Cell,Hilbert, 0 ,0,'Fixed',0,Vars.pos.maxSpikeSpeed,0,Parameters.RunClimerCode,Parameters.Species,{ 'Matched'} ,'');                
                            [RateMap.PI.Oscillation] = RunAutocorrelogramAtDifferentSpeedsGC( VR,Tetrode ,Cell,Hilbert, 0 ,0,'Fixed',0,Vars.pos.maxSpikeSpeed,0,Parameters.RunClimerCode,Parameters.Species,{ 'Matched'} ,'PI');                
                        end
                                              
                        if ReMakeFigures~=7;
                             eval(['RM_VR_' Sessions{iSession} ' =   RM_VR ;  ' ] ) ; 
                            eval(['RM_PI_' Sessions{iSession} ' =   RM_PI ;  ' ] ) ;
                            eval(['SAC_VR_' Sessions{iSession} ' =  SAC_VR ;  ' ] ) ;
                            eval(['SAC_PI_' Sessions{iSession} ' =  SAC_PI ;  ' ] ) ;
                        elseif ReMakeFigures == 7;
                            Vars = daVarsStruct; % Run Speed analyses
                            eval(['RateMaps.' Sessions{iSession} '.VR.SpeedModulation = SpeedCellAnalysisinVR(VR,Tetrode,Cell,[Vars.SpeedModulation.SpeedRange],Parameters.NShuffles,Vars.VR.OpenField.SpeedScorePercentile ,' char(39) 'VR' char(39) ');'])
                            eval(['RateMaps.' Sessions{iSession} '.PI.SpeedModulation = SpeedCellAnalysisinVR(VR,Tetrode,Cell,[Vars.SpeedModulation.SpeedRange],Parameters.NShuffles,Vars.VR.OpenField.SpeedScorePercentile ,' char(39) 'PI' char(39) ');'])
                            %eval(['[ RateMaps.' Sessions{iSession} '.VR.PhasePrecession.Time ] = PhasePrecessionOn1DVR_v2(VR,Tetrode,Cell,Hilbert,Parameters.NShuffles,RateMaps.' Sessions{iSession} '.VR.SACMethod , 0 , [], [] , [],[] , []);' ]);
                            %eval(['[ RateMaps.' Sessions{iSession} '.PI.PhasePrecession.Time ] = PhasePrecessionOn1DVR_v2(VR,Tetrode,Cell,Hilbert,Parameters.NShuffles,RateMaps.' Sessions{iSession} '.VR.SACMethod , 0 , [], [] , [],[] , [],' char(39) 'PI' char(39) ');' ]);
                        elseif ReMakeFigures == 8;
                        disp(['here';]);
                        end
                                 
                elseif strcmp(Parameters.Experiment,'FixingPoint');
                    eval(['in.x = RateMap.' Parameters.MapType 'Map ;' ]);in.nodwell = isnan(in.x);tol= 1.0000e-10; in.tol = tol;PLOT_ON = 1; in.PLOT_ON = PLOT_ON;ret = autoCorr2D (in);sac = sacProps(ret.autocorrelogram );sac.sac =ret.autocorrelogram; clear ret;in.sac = sac.sac;in.PLOT_ON =1;ProduceRM(sac.sac);axis off;
                    text( max(FindExtremesOfArray([1:size(sac.sac,1)])),min(FindExtremesOfArray([1:size(sac.sac,2)])),['Grid score = ' num2str( roundsd( sac.gridness(:),2))]);
                    text( max(FindExtremesOfArray([1:size(sac.sac,1)])),min(FindExtremesOfArray([15:size(sac.sac,2)])) ,['Scale = ' num2str( roundsd( sac.scale*Vars.rm.binSizePosCm,2)) ' cm']);
                    if ~isempty(sac.peakOrient);text( max(FindExtremesOfArray([1:size(sac.sac,1)])),min(FindExtremesOfArray([30:size(sac.sac,2)])) ,['Angle = ' num2str( roundsd( sac.peakOrient(1),2)) char(176)]);
                    else;text( max(FindExtremesOfArray([1:size(sac.sac,1)])),min(FindExtremesOfArray([30:size(sac.sac,2)])) ,['Angle = NaN']);
                    end;clear sac in ;

                elseif strcmp(Parameters.Experiment,'CueLocking')  | strcmp(Parameters.Experiment,'Training') | strcmp(Parameters.Experiment,'VisualUncertainty') ;
                    
                    if ReMakeFigures==1 | ReMakeFigures== 3 ;%| ReMakeFigures== 4  ;
                        eval(['RateMaps.' Sessions{iSession} '.VR.SACMethod = TankGridDecoder2(VR,Tetrode,Cell,[],' char(39) 'Giulio' char(39) ',[RM_VR],[SAC_VR],Parameters.NShuffles,Parameters.Experiment,' char(39) '' char(39) ',[FindExtremesOfArray(Boundaries)],RateMaps.' Sessions{iSession} '.VR.SACMethod) ; ' ]);
                        AddVRCuesToSpikePlot;
                        eval(['RateMaps.' Sessions{iSession} '.VR.SpeedModulation = SpeedCellAnalysisinVR(VR,Tetrode,Cell,[2,50],Parameters.NShuffles,Vars.VR.OpenField.SpeedScorePercentile );'])
                        eval(['[ RateMaps.' Sessions{iSession} '.VR.PhasePrecession.Time ] = PhasePrecessionOn1DVR_v2(VR,Tetrode,Cell,Hilbert,Parameters.NShuffles,RateMaps.' Sessions{iSession} '.VR.SACMethod , 0 ); ' ] );
                    elseif ReMakeFigures == 7;Vars = daVarsStruct; % Run Speed analyses
                         eval(['RateMaps.' Sessions{iSession} '.VR.SpeedModulation = SpeedCellAnalysisinVR(VR,Tetrode,Cell,[Vars.SpeedModulation.SpeedRange],Parameters.NShuffles,Vars.VR.OpenField.SpeedScorePercentile );'])
                    elseif ReMakeFigures == 8;
                            eval(['RunCueScore =  ~isfield(RateMaps.' Sessions{iSession} '.VR.SACMethod,' char(39) 'CueResponse' char(39) ' ) ; ' ])
                            eval(['RunCuePSTH =  ~isfield(RateMaps.' Sessions{iSession} '.VR.SACMethod,' char(39) 'PSTH' char(39) ' ) ; ' ])
                            eval(['RunCueShuffledPSTH =  ~isfield(RateMaps.' Sessions{iSession} '.VR.SACMethod,' char(39) 'CueShuffledPSTH' char(39) ' ) ; ' ])
                            if RunCueScore
                                eval(['RateMaps.' Sessions{iSession} '.VR.SACMethod.CueResponse = RunCueScoreWithShuffles(VR,Tetrode,Cell,RateMaps.' Sessions{iSession} '.VR.SACMethod.RandomTimeShifts , Parameters ) ; ' ]);                       
                            end
                            if RunCuePSTH
                                eval(['RateMaps.' Sessions{iSession} '.VR.SACMethod.PSTH = RunCuePSTHWithShuffles(VR,Tetrode,Cell,RateMaps.' Sessions{iSession} '.VR.SACMethod.RandomTimeShifts , Parameters.NShuffles ,Parameters.CueSummary.' Sessions{iSession} ' ) ; ' ]); 
                            end
                            if RunCueShuffledPSTH
                                eval(['RateMaps.' Sessions{iSession} '.VR.SACMethod.CueShuffledPSTH = RunShuffledCuePSTHWithShuffles(VR,Tetrode,Cell,RateMaps.' Sessions{iSession} '.VR.SACMethod.RandomTimeShifts , Parameters.NShuffles ,Parameters.CueSummary.' Sessions{iSession} ' ) ; ' ]); 
                            end;
                            
                            eval(['[ RateMaps.' Sessions{iSession} '.VR.SACMethod.AntiCue ] = DetectSignificantCueInhibitionInVisualUncertainty(            RateMaps.' Sessions{iSession} '.VR.SACMethod.PSTH.Spatial.Observed ,            RateMaps.' Sessions{iSession} '.VR.SACMethod.PSTH.Spatial.Shuffles,             Parameters.CueSummary.' Sessions{iSession} ' ,[-100,100]);']);
                            eval(['[ RateMaps.' Sessions{iSession} '.VR.SACMethod.CueShuffledAntiCue ] = DetectSignificantCueInhibitionInVisualUncertainty( RateMaps.' Sessions{iSession} '.VR.SACMethod.CueShuffledPSTH.Spatial.Observed , RateMaps.' Sessions{iSession} '.VR.SACMethod.CueShuffledPSTH.Spatial.Shuffles,  Parameters.CueSummary.' Sessions{iSession} ' ,[-100,100]);']);
                            close;clear RunCueScore RunCuePSTH RunCuePSTH CueSummary; 
                            
                    elseif ReMakeFigures == 9;
                        %% Local Map Firing Rate stability...
                        if  eval([' ~isfield(RateMaps.' Sessions{iSession} '.VR,' char(39) 'LocalMap' char(39) ') ; ' ]);
                            eval([' RateMaps.' Sessions{iSession} '.VR.LocalMap = [] ; ' ]);
                        end;
                        eval([' RateMaps.' Sessions{iSession} '.VR.LocalMap  = AnalysesSpatialStabilityOfCellsAcrossLapsInVisualUncertainty( RateMaps.' Sessions{iSession} '.VR.SACMethod , [VR.Virmen.vr.RewardLocation+([-1,1]*VR.Virmen.vr.RewardWindowWidth/2)] ,Parameters.CueSummary.' Sessions{iSession} '  ,RateMaps.' Sessions{iSession} '.VR.LocalMap , Parameters.LocalMethods )  ; ' ])
                        %% Local Map Field shift stability...
                        if  eval([' ~isfield(RateMaps.' Sessions{iSession} '.VR,' char(39) 'LocalShift' char(39) ') ; ' ]);
                            eval([' RateMaps.' Sessions{iSession} '.VR.LocalShift = [] ; ' ]);
                        end;
                        eval([' RateMaps.' Sessions{iSession} '.VR.LocalShift  = AnalysesSpatialShiftOfCellsAcrossLapsInVisualUncertainty( RateMaps.' Sessions{iSession} '.VR.SACMethod ,  [VR.Virmen.vr.RewardLocation+([-1,1]*VR.Virmen.vr.RewardWindowWidth/2)]  , Parameters.CueSummary.' Sessions{iSession} '  ,RateMaps.' Sessions{iSession} '.VR.LocalShift , Parameters.CueEffects.LocalShifts )  ; ' ])

                        
                    elseif ReMakeFigures== 5 ; % Run Oscillation analyses
                        Parameters.RunClimerCode = 0 ;
                        eval(['RateMaps.' Sessions{iSession} '.VR.Oscillation = RunAutocorrelogramAtDifferentSpeedsGC( VR,Tetrode ,Cell,Hilbert, 0 ,0,' char(39) 'Fixed' char(39) ',0,Vars.pos.maxSpikeSpeed,0,Parameters.RunClimerCode,Parameters.Species,{' char(39) 'Matched' char(39) '} ,' char(39) '' char(39) ');' ]);
                        eval(['[ RateMaps.' Sessions{iSession} '.VR.PhasePrecession.Time ] = PhasePrecessionOn1DVR_v2 (VR,Tetrode,Cell,Hilbert,Parameters.NShuffles,RateMaps.' Sessions{iSession} '.VR.SACMethod , 0 ); ' ] );
                        eval(['[ RateMaps.' Sessions{iSession} '.VR.PhasePrecession.Space ] = PhasePrecessionOn1DVR_v3 (VR,Tetrode,Cell,Hilbert,Parameters.NShuffles,RateMaps.' Sessions{iSession} '.VR.SACMethod , 0 ); ' ] );
                    elseif ReMakeFigures ~= 4
                        Vars = daVarsStruct;
                        RateMap.VR.SACMethod = TankGridDecoder2(VR,Tetrode,Cell,[],'Giulio',[RM_VR],[SAC_VR],Parameters.NShuffles,Parameters.Experiment,'',[FindExtremesOfArray(Boundaries)],[],0,CueTemplate) ;
                        AddVRCuesToSpikePlot;
                        RateMap.VR.Oscillation = RunAutocorrelogramAtDifferentSpeedsGC( VR,Tetrode ,Cell,Hilbert, 0 ,0,'Fixed',0,Vars.pos.maxSpikeSpeed,0,Parameters.RunClimerCode,Parameters.Species,{ 'Matched'} ,'');                
                        RateMap.VR.SpeedModulation = SpeedCellAnalysisinVR(VR,Tetrode,Cell,[Vars.SpeedModulation.SpeedRange],Parameters.NShuffles,Vars.VR.OpenField.SpeedScorePercentile );
                        %RateMap.VR.PhasePrecession.Time  = PhasePrecessionOn1DVR_v2(VR,Tetrode,Cell,Hilbert,Parameters.NShuffles,[] , 0 );
                    end
                    
                elseif strcmp(Parameters.Experiment,'Multicompartment') ;
                        RateMap =ComputeCorrelationsBetweenCompartments(RateMap,VR);
                        RateMap.VR.SACMethod = TankGridDecoder2(VR,Tetrode,Cell,[],'Giulio',[RM_VR],[SAC_VR],Parameters.NShuffles,Parameters.Experiment,'',[]) ;
                end
        
        else strcmp(Parameters.Experiment,'MovingCue')  ;
            eval(['Cues = fields(Parameters.Cues.Session_' num2str(iSession) ');' ]);            NCues = numel(Cues);eval([' CuesSide = fields(Parameters.Cues.Session_' num2str(iSession) '.Cue1) ; ' ]);NCueSides = numel((CuesSide));           
            if NCueSides== 1;ROWS = NCues +1 ;else;ROWS = NCues ;end;
            COLUMNS = NCueSides*(numel(Sessions)+2);
                        for iCueSide = 1 :  NCueSides;
                            for iRow = 1 : (ROWS) ; % EACH ROW IS A SINGLE CUE
                                if NCueSides==1;id_plot = (iRow-1)*(COLUMNS) + iCueSide-1 + iSession;elseif NCueSides==2;id_plot =(iRow-1)*(COLUMNS) + (iSession-1)*2+iCueSide ;  end;
                                subaxis(ROWS,COLUMNS,id_plot, 'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
                                if NCueSides==1 ;RunCueResponse = id_plot ==1 ; else ; RunCueResponse = 1; end ;                                          
                                    if  RunCueResponse ;
                                    iCue = iRow + ROWS*(iCueSide-1);eval(['CueName = Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iRow) '.' CuesSide{iCueSide} '.Name ; ' ]);eval(['CueWidth = Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iRow) '.' CuesSide{iCueSide} '.Width ; ' ]);eval(['CueLocations = Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iRow) '.' CuesSide{iCueSide} '.Locations ; ' ]);eval(['CueWindow = Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iRow) '.' CuesSide{iCueSide} '.CueWindow ; ' ]);eval (['SpikeCueColor = Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iRow) '.' CuesSide{iCueSide} '.SpikeCueColors ; ' ]);eval (['CueColor = Parameters.Cues.Session_' num2str(iSession) '.Cue' num2str(iRow) '.' CuesSide{iCueSide} '.CueColor ; ' ]);eval(['RateMap.VR.CueResponse.' CueName '= CueResponse( VR , Tetrode , Cell,CueLocations , CueWidth, CueName ,SpikeCueColor,CueWindow,CueColor,Parameters.CueLockingShuffles , 1) ;' ]);else ;                        RateMap.VR.SACMethod = TankGridDecoder2(VR,Tetrode,Cell,[],'Giulio',[0],[1],Parameters.CueLockingShuffles,Parameters.Experiment) ; P_SI = 1 - invprctile(RateMap.VR.SACMethod.SAC.S2N.Shuffles, RateMap.VR.SACMethod.SAC.S2N.Observed) / 100    ;axis square;;title([CueName ', ' FindSignificantStar(P_SI,0.05) ] ) ;clear  P_SI;
                                    end;        
                            end
                        end
            clear id_plot NCues NCueSides ROWS COLUMNS iCueSide iRow CueName CueWidth CueLocations CueWindow SpikeCueColor
         end
                
        if ReMakeFigures ~= 1 & ReMakeFigures~= 4 & ReMakeFigures~= 5 & ReMakeFigures~= 7 & ReMakeFigures~= 8 & ReMakeFigures~= 9 ;
            eval(['RateMaps.' Sessions{iSession}  '= RateMap ;' ]);
        end ;
            clear RateMap  RM_VR RM_PI SAC_VR SAC_PI ;
        % load spikes...
            if ReMakeFigures~= 4 | ReMakeFigures~= 7 | ReMakeFigures~= 8 | ReMakeFigures~= 9
                for iChannel = 1 : 4;
                    if eval(['~isempty(VR.tetrode(Tetrode).ch' num2str(iChannel) ' );' ] );
                    eval([ 'SpikeWaweforms.VR.Ch' num2str(iChannel) ' = [ SpikeWaweforms.VR.Ch' num2str(iChannel) ' ; VR.tetrode(Tetrode).ch' num2str(iChannel) '(find(VR.tetrode(Tetrode).cut == Cell),:)] ;' ]) 
                    end
                end;
                clear ch1 ch2 ch3 ch4; % delete spikes;
            end
    end;

    %% Now fix max XLIM across subplots...
                if  ~isempty(MaxPosAcrossSessions) 
                    if max(MaxPosAcrossSessions(:)) > max(Boundaries)& strcmp(Parameters.Experiment,'Uncertainty');
                    MaxCommonPos = [min(Boundaries) ceil(max(MaxPosAcrossSessions(:))) ];
                    else
                    MaxCommonPos = (Boundaries);    
                    end
                    for iSession = 1 : numel(Sessions)
                    eval(['SP_VR_' Sessions{iSession} '.XLim = MaxCommonPos ;' ]); 
                    eval(['SP_PI_' Sessions{iSession} '.XLim = MaxCommonPos ;' ]);
                    eval(['RM_VR_' Sessions{iSession} '.XLim = MaxCommonPos ;' ]);
                    eval(['RM_PI_' Sessions{iSession} '.XLim = MaxCommonPos ;' ]);
                    clear([ 'SP_VR_' Sessions{iSession} ] );clear([ 'SP_PI_' Sessions{iSession} ] );clear([ 'RM_VR_' Sessions{iSession} ] );clear([ 'RM_PI_' Sessions{iSession} ] );
                    end
                end;
            %% Open Field categorize cells...
                if ~Parameters.VROnly 
                    clear in ;
                    in.Parameters = Parameters;
                    in.ProduceSpreadSheet  = 0;
                    in.surface = 'OpenField' ;
                    in.Date = Parameters.Date ;
                    in.Parameters.ExpSession = 1 ;
                    in.Parameters.FlagFigure = 0;
                    in.Parameters.DownSampleFWByDwellTime = 0;
                    in.mtint = OpenField;
                    in.Tetrode = Tetrode;
                    in.Cell = Cell;
                    in.MapType = 'Gauss';
                %if ~ReMakeFigures
                    cd(Parameters.MatlabOutputPath);
                    load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Hilbert'  ]);;
                    Hilbert = Hilberts.OpenField;
                    in.Hilbert = Hilbert ; clear Hilberts;
                %end
                    if Parameters.OpenFieldSpeedFilter
                           in.MinSpeed = Parameters.OpenFieldSpeedMinSpeed;	
                        else
                            in.MinSpeed = 0;
                    end
                    Vars = daVarsStruct;
                    in.MaxSpeed = Vars.pos.maxSpeed*100;;
                    in.SpeedTuningMinSpeed = min(Vars.SpeedModulation.SpeedRange);
                    in.SpeedTuningMaxSpeed = max(Vars.SpeedModulation.SpeedRange);
                    in.Percentile =  Parameters.OpenFieldGridScorePercentile ; 
                    in.SHUFFLES = Parameters.OpenFieldShuffles;
                    in.BOOTSTRAPS = Parameters.OpenFieldBootStraps; 
                if ~ReMakeFigures | ReMakeFigures== 4
                    RateMaps.OpenField.OpenFieldCategorizer  = CategorizeCell (in) ;
                elseif ReMakeFigures== 7
                   Stats = SpeedCellAnalysisinVR(OpenField,Tetrode,Cell,[Vars.SpeedModulation.SpeedRange],Parameters.NShuffles,Vars.VR.OpenField.SpeedScorePercentile );
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedScore  = Stats.SpeedScore(1) ;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedLineScore  = Stats.SpeedLineScore(1) ;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.Observed = Stats.SpeedLineScore(1) ;;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.Shuffles = Stats.SpeedLineScore(2:end) ;;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.Threshold = prctile(RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.Shuffles,Vars.VR.OpenField.SpeedScorePercentile);
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.Significant = RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.Observed > RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.Threshold ;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.SlopeObserved = Stats.SpeedLineSlope;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.SlopeShuffles(:) = NaN ; 
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.RAWObserved = Stats.SpeedScore(1) ; 
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.RAWShuffles = Stats.SpeedScore(2:end) ; 
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.RAWThreshold = prctile(RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.RAWShuffles, Vars.VR.OpenField.SpeedScorePercentile);
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.RAWSignificant = RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.RAWObserved > RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.RAWThreshold ;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.r = Stats.SpeedLineScore(1);
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.p_value = Stats.SpeedLineP;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.slope = Stats.SpeedLineSlope;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.intercept = Stats.SpeedLineIntercept ;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.bins = Stats.bins ;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.meanFreqPerBin = Stats.meanFreqPerBin ;
                   RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.semFreqPerBin = Stats.semFreqPerBin ;
                   clear Stats;
                end
                    %% Plot open field...
                                        % as spike plot...
                                if ReMakeFigures~=5 & ReMakeFigures~=7 & ReMakeFigures~=8 & ReMakeFigures~=9;
                                        
                                        [ RateMaps.OpenField.PhasePrecession.Time ] = PhasePrecessionOn1DVR_v2(OpenField,Tetrode,Cell,in.Hilbert,Parameters.NShuffles,[] , 0 ); 
                                        
                                        subaxis(6,numel(Sessions)+2,numel(Sessions)+1,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal,'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);%subplot(6,numel(Sessions)+2,numel(Sessions)+1);                                     
                                        SpikePos = OpenField.tetrode(Tetrode).pos_sample( find(OpenField.tetrode(Tetrode).cut == Cell));SpikePos(find(OpenField.pos.speed(SpikePos)<in.MinSpeed)) = [];plot(OpenField.pos.xy_cm(:,1),OpenField.pos.xy_cm(:,2),'Color',TrackColor);axis tight;hold on ;axis square;axis off;scatter(OpenField.pos.xy_cm(SpikePos,1),OpenField.pos.xy_cm(SpikePos,2),'MarkerFaceColor',[OFSpikeColor],'MarkerEdgeColor',[OFSpikeColor],'SizeData',SpikeDotSize) ; title([ 'OF']);;text(round( max(FindExtremesOfArray(OpenField.pos.xy_cm(:,1)))), round( max(FindExtremesOfArray(OpenField.pos.xy_cm(:,2)))),[num2str(numel(SpikePos)) ' spikes'])
                                        %... rate map...
                                        subaxis(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1),'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal,'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);%%subplot(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1));     
                                        title([ 'Rate map' ]);axis tight square;axis off;set(gca,'XTickLabel', strread(num2str([get(gca,'XTick')*Vars.rm.binSizePosCm]),'%s'));eval(['MeanRate = round(nanmean(RateMaps.OpenField.OpenFieldCategorizer.RateMap.' Parameters.MapType 'Map(:)),2);' ]);eval(['PeakRate = round(max(RateMaps.OpenField.OpenFieldCategorizer.RateMap.' Parameters.MapType 'Map(:)),2);' ]);if PeakRate > 1;PeakRateDisplay = PeakRate;else;PeakRateDisplay = ceil(PeakRate);end;eval(['ProduceRM(RateMaps.OpenField.OpenFieldCategorizer.RateMap.' Parameters.MapType 'Map,[0 PeakRateDisplay]);' ]);title([ 'Rate map' ]);eval(['text( max(FindExtremesOfArray([1:size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.' Parameters.MapType 'Map,1)])),min(FindExtremesOfArray([1:size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.' Parameters.MapType 'Map,2)])),     [' char(39) 'Mean rate = ' char(39) ' num2str( MeanRate ) ' char(39) ' Hz' char(39) '])'; ]) ;
                                        eval(['text( max(FindExtremesOfArray([1:size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.' Parameters.MapType 'Map,1)])),min(FindExtremesOfArray([10:size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.' Parameters.MapType 'Map,2)])) ,   [' char(39) 'Peak rate = ' char(39) ' num2str( PeakRate) ' char(39) ' Hz' char(39) '])'; ]); 
                                        hold on; axis off;line([0 round(size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.UnSmoothedDwell,2),-1) ],2+[size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.UnSmoothedDwell,1) size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.UnSmoothedDwell,1) ] ,'Color','k','LineWidth',2);axis off;ylim([0 2+size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.UnSmoothedDwell,1)]); XTickLabel = [num2str(round(size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.UnSmoothedDwell,2),-1)*[Vars.rm.binSizePosCm]) ' cm'];text(1+round(size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.UnSmoothedDwell,2),-1),2+[size(RateMaps.OpenField.OpenFieldCategorizer.RateMap.UnSmoothedDwell,1)], [ XTickLabel ],'FontWeight','bold')
                                        % ...HD...
                                        subaxis(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*1,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal,'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);%%subplot(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*1); 
                                        in_UNsm_rm = make_in_struct_for_rm (OpenField,Tetrode,Cell,50,5,[Vars.rm.binSizePosCm],[Vars.rm.binSizeDir],1,'dir',0,0) ;in = in_UNsm_rm;PolarMap = GetRateMap ( in);% ProduceRM(flipud(RateMap.map'));title([ 'Rate map' ]);axis tight square;axis off;set(gca,'XTickLabel', strread(num2str([get(gca,'XTick')*Vars.rm.binSizePosCm]),'%s'))
                                        % ... and SAC...   %subplot(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*2);
                                        subaxis(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*2,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal,'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);%
                                        eval(['ProduceRM(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac);' ]); axis off;eval(['text( max(FindExtremesOfArray([1:size(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac,1)])),min(FindExtremesOfArray([1:size(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac,2)])),[' char(39) 'Grid score = ' char(39) ' num2str( roundsd( RateMaps.OpenField.OpenFieldCategorizer.GridScore(:),2))]); ' ]);eval(['text( max(FindExtremesOfArray([1:size(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac,1)])),min(FindExtremesOfArray([16:size(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac,2)])) ,[' char(39) 'Scale = ' char(39) ' num2str( roundsd( RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.scale*Vars.rm.binSizePosCm,2)) ' char(39) ' cm' char(39) ' ]); ' ]);if eval(['~isempty(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.peakOrient);' ]);eval(['text( max(FindExtremesOfArray([1:size(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac,1)])),min(FindExtremesOfArray([31:size(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac,2)])) ,[' char(39) 'Angle = ' char(39) ' num2str( roundsd( RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.peakOrient(1),2)) char(176)]);' ]);else;   eval(['text( max(FindExtremesOfArray([1:size(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac,1)])),min(FindExtremesOfArray([31:size(RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose 'Sac.sac,2)])) ,[' char(39) 'Angle = NaN' char(39) ']); ' ]);end;                % and speed tuning                    % Speed modulation...                    subplot(5,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*3);in.bins = RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.bins;in.meanFreqPerBin= RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.meanFreqPerBin;in.semFreqPerBin = RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.semFreqPerBin;in.xlabel ='cm/s';in.ylabel='Rate (Hz)';in.xlim=[0  RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.bins(end)+1]; in.title='Speed line.';in.PLOT_ON = 1;in.ylim=[0  ceil(max(RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.meanFreqPerBin))];XYSemArea(in);
                                        % ... and speed modulation...%subplot(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*3); 
                                        subaxis(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*3,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal,'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);%
                                        in.bins = RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.bins;in.meanFreqPerBin= RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.meanFreqPerBin;in.semFreqPerBin = RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.semFreqPerBin;in.xlabel ='cm/s';in.ylabel='Rate (Hz)';in.xlim=[0  RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.bins(end)+1]; in.title='Speed line.';in.PLOT_ON = 1;in.ylim=[0  ceil(max(RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.meanFreqPerBin))];XYSemArea(in);
                                        % and ... theta modulation...%subplot(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*4); 
                                        subaxis(6,numel(Sessions)+2,(+2+iSession+numel(Sessions)+1)+(numel(Sessions)+2)*4,'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal,'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);%
                                end      
                                        if ~isfield(RateMaps.OpenField.OpenFieldCategorizer,'Oscillation')
                                            [ RateMaps.OpenField.OpenFieldCategorizer.Oscillation ] = RunAutocorrelogramAtDifferentSpeedsGC( OpenField,Tetrode ,Cell,Hilbert,0,0,'Fixed',0,Vars.pos.maxSpikeSpeed,0,Parameters.RunClimerCode,Parameters.Species,{ 'Matched'} );AutoCorrelationTimeWindow = 0.5;PlotTemporalXCorrelation (RateMaps.OpenField.OpenFieldCategorizer , OpenField,Tetrode,Cell,AutoCorrelationTimeWindow) ; clear Hilbert;
                                        end   
                                        if ReMakeFigures==5 ;
                                            close;
                                            [ RateMaps.OpenField.PhasePrecession.Time ] = PhasePrecessionOn1DVR_v2(OpenField,Tetrode,Cell,in.Hilbert,Parameters.NShuffles,[] , 0 ); 
                                        elseif ReMakeFigures ~=7 & ReMakeFigures ~=8 & ReMakeFigures ~=9 ;
                                            if      eval([ 'RateMaps.OpenField.OpenFieldCategorizer.' Parameters.OpenFieldSacToChoose  'Gridness.Significant ' ]) && MeanRate < Vars.rm.MeanFiringRateForGCDetection && PeakRate > Vars.rm.PeakFiringRateThreshold  ; 
                                                        Parameters.SignificantGridCells = [Parameters.SignificantGridCells; Parameters.CellID];
                                            elseif  RateMaps.OpenField.OpenFieldCategorizer.nFields >1 && RateMaps.OpenField.OpenFieldCategorizer.WithinSessionSpatialCorrelation.Observed > Vars.rm.MinimumSpatialCorrelation && RateMaps.OpenField.OpenFieldCategorizer.SpatialModulationbitsbitsSpike.Observed  > Vars.rm.PlaceCellsMinimumSpatialModulationbitsbitsSpike  && MeanRate < Vars.rm.MeanFiringRateForGCDetection && PeakRate > Vars.rm.PeakFiringRateThreshold  ;
                                                        Parameters.SignificantPlaceCells = [Parameters.SignificantPlaceCells; Parameters.CellID];                   
                                            elseif  RateMaps.OpenField.OpenFieldCategorizer.SpeedModulation.Significant &  max(RateMaps.OpenField.OpenFieldCategorizer.SpeedModulationResults.meanFreqPerBin) >1 ;
                                                        Parameters.SignificantSpeedCells = [Parameters.SignificantSpeedCells; Parameters.CellID];                   
                                            end;
                                        end
                else
                    RateMaps.OpenField = [];    
                end
                    %% Draw spike-waveforms...
                    if ~Parameters.VROnly & ReMakeFigures~=5 & ReMakeFigures~=7 & ReMakeFigures~=8  & ReMakeFigures~=9
                        for iChannel = 1 : 4;  
                                if eval(['~isempty(OpenField.tetrode(Tetrode).ch' num2str(iChannel) ' );' ] );
                                eval(['SpikeWaweforms.OpenField.Ch' num2str(iChannel) ' = [OpenField.tetrode(Tetrode).ch' num2str(iChannel) '(find(OpenField.tetrode(Tetrode).cut == Cell),:)] ;' ])  ; 
                                end
                        end
                    end;
                    if ReMakeFigures~=5 & ReMakeFigures~=7  & ReMakeFigures~=8 & ReMakeFigures~=9
                        for iChannel = 1 : 4;  
                            subaxis(4,numel(Sessions)+2,(numel(Sessions)+2)*iChannel,'SpacingVertical',0.05,'SpacingHorizontal',0.05, 'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, 'MarginLeft',.05,'MarginRight',.05,'MarginTop',.05,'MarginBottom',.05); 
                                clear in ;in.title =['Ch ' num2str(iChannel) ];
                                eval(['in.meanFreqPerBin = nanmean(SpikeWaweforms.VR.Ch' num2str(iChannel) ',1);' ]);
                                if eval(['size(SpikeWaweforms.VR.Ch' num2str(iChannel) ',1)>1 ;' ]);
                                    eval(['in.semFreqPerBin = nanstd(SpikeWaweforms.VR.Ch' num2str(iChannel) ',1);' ]);
                                else;
                                    eval(['in.semFreqPerBin = zeros(size(in.meanFreqPerBin));' ]);
                                end;
                                in.linecolor = Vars.SpeedModulation.FloorColor;
                                in.shadecolor = Vars.SpeedModulation.FloorShadeColor;
                                in.shadecolortransparency = 0.5;
                                in.xlim =[-.2 .3];in.ylim =[-150 150];in.xlabel = '';in.ylabel = '';in.bins= linspace(-0.2,0.3,50); ;
                                XYSemArea(in);
                           if ~Parameters.VROnly & isfield(SpikeWaweforms,'OpenField') 
                                hold on
                                eval(['in.meanFreqPerBin = nanmean(SpikeWaweforms.OpenField.Ch' num2str(iChannel) ',1);' ]);
                                        if eval(['size(SpikeWaweforms.OpenField.Ch' num2str(iChannel) ',1)>1 ;' ]);
                                            eval(['in.semFreqPerBin = nanstd(SpikeWaweforms.OpenField.Ch' num2str(iChannel) ',1);' ]);
                                        else;
                                            eval(['in.semFreqPerBin = zeros(size(in.meanFreqPerBin));' ]);
                                        end;
                                in.linecolor = Vars.SpeedModulation.OpenFieldColor;
                                in.shadecolor = Vars.SpeedModulation.OpenFieldShadeColor;
                                XYSemArea(in);
                           end;
                        set(gca,'XTick',[]);set(gca,'YTick',[]);axis off;clear in;
                        end
                    end
                    %% Save figure..... %%
%                     RateMaps.OpenField = Output.AllCells(iCellToAnalyse).Openfield;
%                     RateMaps.OpenField.PhasePrecession = Output.AllCells(iCellToAnalyse).Openfield.VR.PhasePrecession;
%                     RateMaps.OpenField = rmfield(RateMaps.OpenField,'VR');
%                     
                    title_Cell = ['Cell_ID_#_' num2str(RateMaps.CellID) '_' Parameters.Mouse '_' Parameters.Date '_' Parameters.Experiment '_Tetrode_' num2str(Tetrode) '_Cell_' num2str(Cell) ]; set(gcf,'NumberTitle','off','Name',[title_Cell ],'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition', [0 0 1 1]); 
                    cd(Parameters.CellsFigurePath );  
                    if ReMakeFigures~= 5 & ReMakeFigures~=7 & ReMakeFigures~=8 & ReMakeFigures~=9 ;
                        SAVE_Figure(gcf, title_Cell, 'jpeg','landscape')
                        if Parameters.NShuffles>0;
                            SAVE_Figure(gcf, title_Cell, 'pdf','landscape')
                        end
                        disp (['Figures from ' title_Cell ' properly saved and stored into correct directory']);
                    else; close;
                    end
                    if ReMakeFigures~=1
                        cd(Parameters.MatlabSingleRateMaps);
                        if isfield(RateMaps.OpenField,'VR') & isfield(RateMaps.OpenField.VR,'PhasePrecession')
                           RateMaps.OpenField.PhasePrecession =  RateMaps.OpenField.VR.PhasePrecession;
                           RateMaps.OpenField= rmfield(RateMaps.OpenField,'VR');
                        end 
                        if eval(['isfield(RateMaps.' Sessions{1} ',' char(39) 'Openfield' char(39) ');' ])
                            eval(['RateMaps = rmfield(RateMaps.' Sessions{1} ',' char(39) 'Openfield' char(39) ');' ]);
                        end
                        save( [title_Cell ] ,'RateMaps','-v7.3') ;
                        disp (['Matfile from ' title_Cell ' properly saved and stored into correct directory']);
                    end ;
                    close;clear iSession SpikeWaweforms RateMaps;
                    %AllCells =[AllCells;RateMaps];
                    clear RM_PI RM_VR SAC_VR SAC_PI PolarMap PeakRateDisplay PeakRate in in_UNsm_rm iChannel iSession MeanRate Hilbert in ch1 ch2 ch3 ch4   ;
                    clear SAC_VR_Session_1 SAC_VR_Session_2 SAC_VR_Session_3 SP_PI SP_VR title_Cell title_cell SpikeWaweforms ch1 ch2 ch3 ch4;                   
    end


%%
clear VR Tetrode Cell ch1 ch2 ch2 iCell iCellToAnalyse MaxCommonPos MaxPosAcrossSessions MaxVisits ;
clear SAC_PI_Session_1 SAC_PI_Session_2 SAC_PI_Session_3    ;
%% Close script if only the
if or(ReMakeFigures ==1 , strcmp(getenv('COMPUTERNAME'),'P-TROUX-LAB8'))
    return;
end;


%% Now that each individual cell has been saved, load them all and add them to AllCells.
if ReMakeFigures ~= 6 ;
    cd(Parameters.MatlabSingleRateMaps)
    CellsAlreadyAnalysed = dir([Parameters.MatlabSingleRateMaps,'*.mat']) ;
        for iCellToAnalyse =  1 : numel( CellsAlreadyAnalysed ) 
            eval(['load(' char(39)  CellsAlreadyAnalysed(iCellToAnalyse).name  char(39) ')' ])
            AllCells(iCellToAnalyse) = RateMaps ;
            clear RateMaps;
        end
end
%% Produce lick maps...
if ~strcmp(Parameters.Experiment , 'TeleTunnel' ) & ~strcmp(Parameters.Experiment , 'MovingCue' )   ;
AllLickMap = [];
for iSession = 1 : numel(Sessions)
eval(['VR = VRs.' Sessions{iSession} ';' ])
if strcmp(Parameters.Experiment , 'VisualUncertainty' );
   %RewardedLocation =   RewardedArea( FindElementsWithMultipleBoundaries(VR.Virmen.vr.RewardLocation,RewardedArea,'inside'),:);
   [~,id] = FindElementsWithMultipleBoundaries(VR.Virmen.vr.RewardLocation,RewardedArea,'inside') ;
   RewardedLocation = RewardedArea(id,:) ;clear id;
elseif strcmp(Parameters.Experiment , 'Training' );
    if strcmp(class(VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}),'objectFloor')
        RewardedLocation = [    VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y - VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.width/2 , ...
                                VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y + VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.width/2]  ;
    end    
else
    RewardedLocation = RewardedArea ;
end
subaxis(4,numel(Sessions),iSession+numel(Sessions)*0,...
        'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, ...
        'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, ...
        'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
VR = ProduceLickPlot(VR,TrackColor,OutsideRewardAreaLick,InsideRewardAreaLick,RewardColor,WorldWithRewardArea,Boundaries,RewardedLocation) ; 

subaxis(4,numel(Sessions),iSession+ numel(Sessions)*(1),...
        'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, ...
        'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, ...
        'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
[VR,LickMap] = ProduceLickMap(VR,TrackColor,Vars,1,Boundaries,RewardedLocation,ForEachCompartmentVisits) ;
subaxis(4,numel(Sessions),iSession+ numel(Sessions)*(2),...
        'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, ...
        'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, ...
        'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
ProduceTemporalLickPlot(VR,1,10);

subaxis(4,numel(Sessions),iSession+ numel(Sessions)*(3),...
        'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, ...
        'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, ...
        'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
    LickMap =ComputeCorrelationsBetweenCompartments(LickMap,VR);  
    AllLickMap=[AllLickMap;LickMap];
end
Parameters.RewardedLocation = RewardedLocation ; 
title_Cell = [Parameters.Mouse '_' Parameters.Date '_' Parameters.Experiment ];
set(gcf,'NumberTitle','off','Name',title_Cell,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition', [0 0 1 1]) %,');
cd(Parameters.LickingFigurePath);
SAVE_Figure(gcf,title_Cell,'pdf','landscape');
SAVE_Figure(gcf,title_Cell,'jpeg','landscape');
close;
Output.LickMap = AllLickMap;
cd(Parameters.MatlabOutputPath)
save( [ Parameters.Experiment  '_' Parameters.Mouse '_' Parameters.Date '_LickBehaviour' ] , 'AllLickMap' , '-v7.3') ;
if ReMakeFigures == 6
    return;
end
%% Produce population ensemble maps and compare to behaviour...
if  strcmp(Parameters.Experiment , 'Multicompartment' )% | ~strcmp(Parameters.Experiment , 'TeleTunnel' ) ;
CellsToBehaviourCorrelation =[];
for iSession = 1 : numel(Sessions)

subaxis(3,numel(Sessions),iSession,...
        'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, ...
        'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, ...
        'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);
ProduceRM( nanmean(ConcatentateIntoStructureIndices(AllCells,['Session_' num2str(iSession) '.'],'VR.Correlations',[],4),3),[-.4 .4]);colorbar;
set(gca,'XTick', [1:numel(ForEachCompartmentVisits)],'XTickLabel',ForEachCompartmentVisits, 'YTick', [1:numel(ForEachCompartmentVisits)],'YTickLabel',ForEachCompartmentVisits);
title([' All cells (Session ' num2str(iSession) ')'])

subaxis(3,numel(Sessions),iSession+numel(Sessions),...
        'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, ...
        'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, ...
        'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom);

ProduceRM( (ConcatentateIntoStructureIndices(AllLickMap,['.'],'VR.Correlations',[iSession],0))',[-.4 .4]);colorbar;
set(gca,'XTick', [1:numel(ForEachCompartmentVisits)],'XTickLabel',ForEachCompartmentVisits, 'YTick', [1:numel(ForEachCompartmentVisits)],'YTickLabel',ForEachCompartmentVisits);
title([' Licking (Session ' num2str(iSession) ')'])

CellsToBehaviourCorrelation =[CellsToBehaviourCorrelation; nancorr( ...
nanmean(ConcatentateIntoStructureIndices(AllCells,['Session_' num2str(iSession) '.'],'VR.Correlations',[],4),3) , ...
ConcatentateIntoStructureIndices(AllLickMap,['VR.'],'Correlations',[iSession],0)' ,'Pearson')] ;   

end;
subaxis(3,numel(Sessions)+1,3+(1+numel(Sessions))*2,...
        'SpacingVertical',Vars.VR.Display.SpacingVertical,'SpacingHorizontal',Vars.VR.Display.SpacingHorizontal, ...
        'PaddingLeft',0,'PaddingRight',0,'PaddingTop',0,'PaddingBottom',0, ...
        'MarginLeft',Vars.VR.Display.MarginLeft,'MarginRight',Vars.VR.Display.MarginRight,'MarginTop',Vars.VR.Display.MarginTop,'MarginBottom',Vars.VR.Display.MarginBottom+0.02);
plot([1:numel(Sessions)],[CellsToBehaviourCorrelation],'color','k');hold on;p=plot([1:numel(Sessions)],[CellsToBehaviourCorrelation],'.','Color','r','MarkerSize',30);line([0 numel(Sessions)+1],[0 0],'LineStyle','--','Color','b');xlim([0 numel(Sessions)+1]);ylim([-1.2 1.2 ]);xlabel('Sessions');ylabel('Correlation');title('Cells to behaviour');set(gca,'XTick',[1 : numel(Sessions)]);
title_Cell = [Parameters.Mouse '_' Parameters.Date '_' Parameters.Experiment ];
set(gcf,'NumberTitle','off','Name',title_Cell,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition', [0 0 1 1]) %,');
cd(Parameters.PopulationEnsembleFigurePath);saveas(gcf,title_Cell,'pdf');disp (['Figures from ' title_Cell ' properly saved and stored into correct directory']);clear title_Cell;
end;
close;

clear  Tetrode subplot1 subplot2 SpikePos PolarMap PLOT_ON OpenFieldRateMap  VR ;
clear      SetPath     
clear iSession  LickMap iVisit iReward iEnvironment iFile in in_UNsm_rm   Session  
clear   iChannel    CutFiles Clusters Cluster Cell  ans sac tol;



%% Save data already ran...
% cd(Parameters.MatlabOutputPath);
% disp(['Saving' Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '...' ])
% save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  ],'-v7.3');
% disp(['...now saved' ]);
elseif LoadDataSetAlreadyRun 
cd(Parameters.MatlabOutputPath);
load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  ]);
end


%% Detect Significant periodic cells
UncertaintyLevel ={};
WorldOrder = {};
for iSession = 1 : numel(Sessions)

if eval(['~isfield(VRs.' Sessions{iSession} '.Virmen.vr, ' char(39) 'LevelOfUncertainty' char(39) ')' ])
   eval([ 'VRs.' Sessions{iSession} '.Virmen.vr.LevelOfUncertainty = ' char(39) 'Low' char(39) ' ;' ]); 
end
eval(['UncertaintyLevel{iSession} =  VRs.' Sessions{iSession} '.Virmen.vr.LevelOfUncertainty ;' ])
eval(['WorldOrder{iSession} =  VRs.' Sessions{iSession} '.Virmen.vr.WorldNameWithReward ;' ])
end
Parameters.UncertaintyLevel = UncertaintyLevel;
Parameters.WorldOrder = WorldOrder;

if ~Parameters.VROnly
Output.OpenField = OpenField; 
else
Output.OpenField = []; 
end

%% Resort AllCells in case they were not in the right order in the structure...
AllCells = SortStructure(AllCells,[ConcatentateIntoStructureIndices(  AllCells, ['.'] ,'CellID' ,[] , [])],...
    sort([ConcatentateIntoStructureIndices(  AllCells, ['.'] ,'CellID' ,[] , [])]));
Parameters.NameOfSessions = fields(VRs);

%% Conduct spatial decoding from all cells...

% Parameters.Boundaries = Boundaries;
% [SpatialDecoding ] = WrapperFunctionForSpatialDecoding(VRs ,  Parameters , 1 ) ;
% cd(Parameters.SpatialDecoding)
% SAVE_Figure(gcf, [  [ Parameters.Experiment '_' Parameters.Mouse '_'  Parameters.Date '_SpatialDecoding' ] ], 'jpeg','landscape');
% SAVE_Figure(gcf, [  [ Parameters.Experiment '_' Parameters.Mouse '_'  Parameters.Date '_SpatialDecoding' ] ], 'pdf','landscape');
% close;
% cd(Parameters.MatlabOutputPath);
% save([ Parameters.Experiment '_' Parameters.Mouse '_'  Parameters.Date '_SpatialDecoding' ], [ 'SpatialDecoding' ],'-v7.3') ;
% Output.SpatialDecoding = SpatialDecoding;

%% Reload cells and Run QLocking analysis in the useful experiments...
Parameters.CueLockingShuffles = Parameters.NShuffles;
Parameters.CueWindow = 50;
for iSession = 1 : numel(Sessions )
    eval(['VR = VRs.' Sessions{iSession} ' ; ' ])
    eval(['Output.VR.' Sessions{iSession} '.Behaviour =  VR.pos ; ' ]);
    eval(['Output.VR.' Sessions{iSession} '.Virmen =  VR.Virmen.vr ; ' ]);
    for Tetrode = 1 : numel(VR.tetrode);
        eval(['Output.VR.' Sessions{iSession} '.Tetrode(Tetrode).id =  VR.tetrode(Tetrode).id ; ' ]);
        eval(['Output.VR.' Sessions{iSession} '.Tetrode(Tetrode).ts =  VR.tetrode(Tetrode).ts ; ' ]);
        eval(['Output.VR.' Sessions{iSession} '.Tetrode(Tetrode).pos_sample =  VR.tetrode(Tetrode).pos_sample ; ' ]);
        eval(['Output.VR.' Sessions{iSession} '.Tetrode(Tetrode).cut =  VR.tetrode(Tetrode).cut ; ' ]);
        eval(['Output.VR.' Sessions{iSession} '.Tetrode(Tetrode).duration =  VR.tetrode(Tetrode).duration ; ' ]);
        end; 
    clear Tetrode;
    MakeSettingsForCueResponseAnalysis;
end


eval(['RunCueAnalysis  = ~isfield(AllCells(1).' Sessions{1} '.VR,' char(39) 'CueResponse' char(39) ') && strcmp(Parameters.Experiment,' char(39) 'CueLocking' char(39) ') |  strcmp(Parameters.Experiment,' char(39) 'MovingCues' char(39) ') ;' ])

if RunCueAnalysis
    PerformCueResponseAnalysis
end


%% Adjust Dataset to be compatible with Charlie's data...
NewAllCells = [];
if strcmp(Parameters.Experiment , 'Multicompartment' )
        for iCell = 1  : numel(AllCells);
            Fields =  (fields(AllCells(iCell)));
            IndexC = strfind(Fields, 'Session_');
            Index = find(not(cellfun('isempty', IndexC)));
            NSessions = numel(Index);

            for iSession = 1  : NSessions  
                for iVisit = 1 : numel(ForEachCompartmentVisits)
                        eval(['NewAllCells(iCell).' ForEachCompartmentVisits{iVisit} ' = AllCells(iCell) ;' ])
                        eval(['NewAllCells(iCell).' ForEachCompartmentVisits{iVisit} '.UncertaintyLevel = VRs.Session_' num2str(iSession) '.Virmen.vr.LevelOfUncertainty;  ' ])
                        eval(['ToNaN = FindElementsWithMultipleBoundaries(NewAllCells(iCell).' ForEachCompartmentVisits{iVisit} '.Session_' num2str(iSession) '.VR.Pos , Boundaries(iVisit,:) ,' char(39) 'outside' char(39) '); ' ]);
                        eval(['FieldsToNaN = fields(NewAllCells(iCell).' ForEachCompartmentVisits{iVisit} '.Session_' num2str(iSession) '.VR) ; ' ]);
                        for iField = 1 : numel(FieldsToNaN)
                            if  eval(['length(NewAllCells(iCell).' ForEachCompartmentVisits{iVisit} '.Session_' num2str(iSession) '.VR.' FieldsToNaN{iField} ') ==  length(NewAllCells(iCell).' ForEachCompartmentVisits{iVisit} '.Session_' num2str(iSession) '.VR.Pos) ;' ])
                                if strcmp(FieldsToNaN{iField},'nodwell')
                                eval(['NewAllCells(iCell).' ForEachCompartmentVisits{iVisit} '.Session_' num2str(iSession) '.VR.' FieldsToNaN{iField} '(ToNaN) = 1 ;' ])
                                else    
                                eval(['NewAllCells(iCell).' ForEachCompartmentVisits{iVisit} '.Session_' num2str(iSession) '.VR.' FieldsToNaN{iField} '(ToNaN) = NaN ;' ])
                                end
                            end;
                        end;
                end;
            end;
        end; % icell;
        
else ;  %% For any other experiment...
        for iCell = 1  : numel(AllCells);
            Fields =  (fields(AllCells(iCell)));
            IndexC = strfind(Fields, 'Session_');
            Index = find(not(cellfun('isempty', IndexC)));
            NSessions = numel(Index);
            
            [UniqueNamesOfEnvironments,~,session_id ] = unique ( Parameters.WorldOrder );
            
            if numel(session_id) == NSessions & NSessions>0 ; SameWorldRepeated = 1;else SameWorldRepeated = 0 ; end;
            
                    
            for iUniqueEnvironment = 1 :  numel(UniqueNamesOfEnvironments)
            tmpEnvironmentName = UniqueNamesOfEnvironments{iUniqueEnvironment} ;
            eval(['NewAllCells(iCell).' tmpEnvironmentName ' = AllCells(iCell) ;' ])
            eval(['NewAllCells(iCell).' tmpEnvironmentName ' = rmfield(  NewAllCells(iCell).' tmpEnvironmentName ',  Fields(Index(find(~strcmp(Parameters.WorldOrder , UniqueNamesOfEnvironments{iUniqueEnvironment} ))))) ; ;' ] );
            eval(['NewAllCells(iCell).' tmpEnvironmentName '.UncertaintyLevel = Parameters.UncertaintyLevel(strcmp(Parameters.WorldOrder,UniqueNamesOfEnvironments{iUniqueEnvironment})) ; '  ]);
            eval(['NewAllCells(iCell).' tmpEnvironmentName '.UncertaintyLevel  = NewAllCells(iCell).' tmpEnvironmentName '.UncertaintyLevel{1};  ; ' ] );
%             if eval(['isfield(NewAllCells(iCell).' tmpEnvironmentName ',' char(39) 'OpenField' char(39) ') ' ]);
%                eval(['NewAllCells(iCell).' tmpEnvironmentName '= rmfield(NewAllCells(iCell).' tmpEnvironmentName '  ,' char(39) 'OpenField' char(39) ') ; ' ])
%             end
%                 if ~Parameters.VROnly;
%                     NewAllCells(iCell).Openfield = AllCells(iCell).OpenField ;
%                 end
            end;
            
        end;
end

NewAllCells;
clear ToDelete iSession iCell iToDelete ans iFile Index IndexA IndexB IndexC SubFields tmpEnvironmentName NSessions;

Parameters.MEC_Tetrodes = MEC_Tetrodes;
Parameters.HPC_Tetrodes = HPC_Tetrodes ; 

%% Analyse periodic cells, but not in Multicompartment experiment...
if  ~strcmp(Parameters.Experiment , 'Multicompartment' )
%% Detect Significant periodic cells,[]
if strcmp(Parameters.Experiment,'VisualUncertainty')
[ Parameters ] = GetCueMasksFromVisualUncertaintyInsideSession( VRs,Parameters );
end
[Parameters ,CollapsedCellsAcrossCues ] = DetectPeriodicCellsWithinSession(Parameters,NewAllCells,UncertaintyLevel,0, 'Uncertainty' ,'VR', {'Grid' }) ; close all;
%% Now re-save
cd(Parameters.MatlabOutputPath);
save('Parameters','Parameters','-v7.3');
Output.Parameters = Parameters;
%return

%% save first all cells....
disp(['Saving' Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date ' Grouped cells ...' ])
save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Cells'  ], 'NewAllCells','Parameters','-v7.3');
elseif  strcmp(Parameters.Experiment , 'Multicompartment' )
cd(Parameters.MatlabOutputPath);
%% save first all cells....
disp(['Saving' Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date ' Grouped cells ...' ])
save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Cells'  ], 'NewAllCells','Parameters','-v7.3');
    
end

if ~exist('SameWorldRepeated','var');SameWorldRepeated = 0 ;end;

%% If the open field data was not saved in NewAllCells load the AllCells structure and add it so
if ~isfield(NewAllCells,'Openfield');
                       if eval(['isfield(NewAllCells(1).' Parameters.WorldOrder{1} ',' char(39) 'OpenField' char(39) ') ' ])
                                    for iCell = 1 : numel(NewAllCells)
                                        eval(['NewAllCells(iCell).Openfield  = AllCells(iCell).OpenField ;' ]); 
                                        for iSession = 1 : numel(Sessions)
                                            if eval(['isfield(NewAllCells(iCell).' Parameters.WorldOrder{iSession} ',' char(39) 'OpenField' char(39) ')'  ])
                                            eval([ 'NewAllCells(iCell).' Parameters.WorldOrder{iSession}  ' = rmfield(NewAllCells(iCell).' Parameters.WorldOrder{iSession} ',' char(39) 'OpenField' char(39) ') ; ' ]);
                                            end
                                        end

                                    end
                       else
                            load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  ],'AllCells');
                            for iCell = 1 : numel(NewAllCells)
                            NewAllCells(iCell).Openfield  = AllCells(iCell).OpenField;
                            end
                            if ~strcmp(Parameters.Experiment , 'Multicompartment' )
                            save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Cells'  ], 'NewAllCells','Parameters','CollapsedCellsAcrossCues','-v7.3');
                            end
                       end
end;

%% Output....
Output.AllCells = NewAllCells;
Output.Parameters =Parameters;
cd(Parameters.MatlabOutputPath);
%load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  '_Theta']);
%Output.Theta = MEC_VR_OpenFieldThetaBehaviourStats;
clear MEC_VR_OpenFieldThetaBehaviourStats ;



%% Save stuff...
clear EEG MEC_VR_OpenFieldThetaBehaviourStats EEG;
cd(Parameters.MatlabOutputPath);
if ~strcmp(Parameters.Experiment , 'Multicompartment' )
disp(['Saving' Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '...' ])
save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Output' ],'Output'  ,'-v7.3');
disp(['...now saved' ]);
else
clear VR;
Sessions = fields(VRs);
for iSession = 1  : numel(Sessions)
eval(['VRs.Session_' num2str(iSession) '.Virmen = rmfield(VRs.Session_' num2str(iSession) '.Virmen ,' char(39) 'vr' char(39) ');' ]);
end
save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  '_Output' ],'Output' ,'-v7.3');
end
disp(['...now saved' ]);
 end

 else
     
        cd(Parameters.MatlabOutputPath);
        disp([ Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date ' loading...' ]);

if      ExtractCells == 1; %% Returns the Output with all the fields...
                load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Output'  ]  );
                if ~isfield(Parameters,'RewardedLocation');
                    SessionNames = fields(Output.VR) ;
                    eval(['Parameters.RewardedLocation = [repmat(Output.VR.' SessionNames{1} '.Virmen.RewardLocation,1,2)] + [-Output.VR.' SessionNames{1} '.Virmen.RewardWindowWidth/2 ,  Output.VR.' SessionNames{1} '.Virmen.RewardWindowWidth/2 ];' ] );
                    clear SessionNames
                end              
                Output.OpenField = [];
                Sessions = fields(Output.VR) ;
                for iSession = 1 : numel(Sessions);
                   eval([' Output.VR.' Sessions{iSession} '.Behaviour = [];  '   ])
                   eval([' Output.VR.' Sessions{iSession} '.Tetrode = [];  '   ])
                end      
                
                
                
elseif  ExtractCells == 2; %% Add Licking to the Output session..
          if exist([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  '_Behaviour.mat' ])==2
                load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  '_Behaviour' ]  );
          end     
                
            if sum(isfield(Output.Parameters, 'WorldOrder') & strcmp(Output.Parameters.WorldOrder,'A')) == 0;
                            load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date   ]  );
                            Output.OpenField = OpenField;
                           for iSession = 1  : numel(Sessions)
                                eval(['Output.VR.' Sessions{iSession} '.Behaviour.Licking = VRs.' Sessions{iSession} '.Licking ;' ])
                                    if eval(['isfield(Output.VR.' Sessions{iSession} ',' char(39) 'Tetrode' char(39) ')  ; ' ])
                                       eval([ ' Output.VR.' Sessions{iSession} ' = rmfield(Output.VR.' Sessions{iSession} ',' char(39) 'Tetrode' char(39) ');' ] )
                                    end
                            end
                            Output = rmfield(Output ,'AllCells');      
                            Output.Parameters = Parameters;
                            save([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date  '_Behaviour' ],'Output' ,'-v7.3');
            end

elseif ExtractCells == 3;
                load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Output'  ]  );
                if ~isfield(Parameters,'RewardedLocation');
                    SessionNames = fields(Output.VR) ;
                    eval(['Parameters.RewardedLocation = [repmat(Output.VR.' SessionNames{1} '.Virmen.RewardLocation,1,2)] + [-Output.VR.' SessionNames{1} '.Virmen.RewardWindowWidth/2 ,  Output.VR.' SessionNames{1} '.Virmen.RewardWindowWidth/2 ];' ] );
                    clear SessionNames
                end
                Output.Theta = [];
                Output.LickMap = [];
                Output.OpenField = [];
                Sessions = fields(Output.VR);
                    for iSession = 1 ;
                        eval(['Output.VR.' Sessions{iSession} '.Behaviour = [] ;' ] );
                        eval(['Output.VR.' Sessions{iSession} '.Tetrode = [] ;' ] );
                    end
                

elseif ExtractCells == 4
        cd(Parameters.FilePath);
        Virmens = dir([Parameters.FilePath '*.mat' ]  );
        Virmens = ConcatentateIntoStructureIndices( Virmens, '', 'name' , [] ,11 ) ;
            if strcmp(Parameters.Experiment , 'VisualUncertainty')
               Output = [];
               Output.Parameters = [Parameters];
               VR.Low = struct();
               VR.Medium = struct();
               VR.High = struct();
                   for iVR = 1  : numel(Virmens);
                       eval([' load ' Virmens{iVR} '; ' ]);
                       eval(['VR.' Data.vr.LevelOfUncertainty '.Session_' num2str(eval([ 'numel(fields(VR.' Data.vr.LevelOfUncertainty ' )) +1 ' ])) ' = Data.vr ; ' ]);
                       clear Data;
                   end;
               eval([' Output.Virmen = VR    ;  ' ] ) ;
               clear VR;
            end

elseif ExtractCells == 5;
                load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Output'  ]  );
                if ~isfield(Parameters,'RewardedLocation');
                    SessionNames = fields(Output.VR) ;
                    eval(['Parameters.RewardedLocation = [repmat(Output.VR.' SessionNames{1} '.Virmen.RewardLocation,1,2)] + [-Output.VR.' SessionNames{1} '.Virmen.RewardWindowWidth/2 ,  Output.VR.' SessionNames{1} '.Virmen.RewardWindowWidth/2 ];' ] );
                    clear SessionNames
                end
                Output.Theta = [];
                Output.LickMap = [];
                Output.OpenField = [];
                Output.SpatialDecoding = [];
                Sessions = fields(Output.VR) ;
                for iSession = 1 : numel(Sessions);
                   eval([' Output.VR.' Sessions{iSession} '.Behaviour = [];  '   ])
                   eval([' Output.VR.' Sessions{iSession} '.Tetrode = [];  '   ])
                end
elseif ExtractCells == 6;
                load([Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date '_Output'  ]  );
                if ~isfield(Parameters,'RewardedLocation');
                    SessionNames = fields(Output.VR) ;
                    eval(['Parameters.RewardedLocation = [repmat(Output.VR.' SessionNames{1} '.Virmen.RewardLocation,1,2)] + [-Output.VR.' SessionNames{1} '.Virmen.RewardWindowWidth/2 ,  Output.VR.' SessionNames{1} '.Virmen.RewardWindowWidth/2 ];' ] );
                    clear SessionNames
                end
                Output.Theta = [];
                Output.OpenField = [];
                Sessions = fields(Output.VR);
                    for iSession = 1 ;
                        eval(['Output.VR.' Sessions{iSession} '.Behaviour = [] ;' ] );
                        eval(['Output.VR.' Sessions{iSession} '.Tetrode = [] ;' ] );
                    end
                
elseif ExtractCells == 7;
cd(Parameters.MatlabOutputPath)
load 'Parameters'   
Output.Parameters = Parameters;
end
disp([ Parameters.Experiment '_' Parameters.Mouse '_' Parameters.Date ' loaded now, carry on...' ]);
end;

clc;

Output.OpenField=[];
%Output.SpatialDecoding = [];
Output.VR=[];

cd(Parameters.MatlabOutputPath)
%if ~exist('AllCells.mat') ;
    AllCells = Output.AllCells;
    save('AllCells','AllCells','-v7.3');
%end  


end

