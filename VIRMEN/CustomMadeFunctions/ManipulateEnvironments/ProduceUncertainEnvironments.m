clear 
load('C:\Users\Giulio\Dropbox\MATLAB_Shared\VIRMEN\ViRMEn\experiments\VisualUncertainty.mat')

Transparency = NaN;
LightestColor = 255 ; 
UncertaintyWorlds = [1 : 3];
UncertaintyLevel = [0.05 0.05  .05 ]; ;  %  [0.05 0.1  .15 ];
MaintainColor = 0;
%exper = virmenExperiment;

NWORLDS = 3;
NCUES = 3;
TrackLenght = 5;
TrackWidth = 50;
Properties.Worlds.Elevation = [-20 ];
Properties.Worlds.Top = [30 ];

Properties.A.ObjectID = 1;
Properties.A.Size = 500;

Properties.B.ObjectID = 2;
Properties.B.Size = 500;

Properties.C.ObjectID = 3;
Properties.C.Size = 200;

%% The table here summarizes how the cues are displayed across worlds.
    % The rows are three and represent the location of where the cue is displayed.
    % The columns are three and represent the three worlds.
    % So far column = 1 (i.e. World =1); the A is on the left wall, 
    % B is on the right wall and the C cues on the top.
    %A and B are single cues, while C is duplicated with fixed distance.
    
%                           World _1    World _2     World _3                                        
Properties.LocationTable =   {'A'       'C'             'B'   ;...    LEFT
                              'B'       'A'             'C'  ;...    RIGHT
                              'C'       'B'             'A'  } ;...  TOP

Properties.TextureTable =  {'BlackToBlue'   'BlackToYellow'  'BlackToWhite'   ;...    LEFT
                            'BlackToGrey'   'BlackToPurple'  'BlackToTurquoise'  ;...    RIGHT
                            'BlackToGreen'  'BlacToCyan'     'BlackToOrange'  } ;...  TOP

Properties.ColorTable ={};
Properties.ColorTable(:,:,1) = {[0 0 0  ; 0   0  255] ,  [0 0 0; 255 255 204]  ,  [0 0 0; 255 255 255]};
Properties.ColorTable(:,:,2) = {[0 0 0  ;100 100 100] ,  [0 0 0; 255  0  255]  ,  [0 0 0; 212 255 246]};
Properties.ColorTable(:,:,3) = {[0 0 0  ; 0  255  0 ] ,  [0 0 0;  0  255 255]  ,  [0 0 0; 255 229 204]};  %...  TOP

exper.movementFunction =        @moveWithKeyboard ;
exper.transformationFunction =  @transformPerspectiveMex ;
exper.experimentCode =  @VisualUncertainty ;

exper.name = 'VisualUncertainty';

WORLDNAMES = {'X','Y','Z'};

for WORLD = 1 : 3


exper.worlds{WORLD}.name = WORLDNAMES{WORLD};
exper.worlds{WORLD}.transparency =0 ;

%% Compute texture of the identical walls...

ColorExtremes = cell2mat(Properties.ColorTable(:,WORLD,find(strcmp(Properties.LocationTable(:,WORLD),'A'))) );
TextureName = char(Properties.TextureTable(find(strcmp(Properties.LocationTable(:,WORLD),'A')),WORLD)) ;
exper.worlds{WORLD}.objects{Properties.A.ObjectID}.name = ['A_' num2str(WORLD) ] ;
exper = ComputeSmoothedTextures(exper,WORLD,Properties.A.ObjectID,Transparency,[ColorExtremes],TextureName,[UncertaintyLevel(WORLD) UncertaintyLevel(UncertaintyWorlds(1)) ],MaintainColor);

ColorExtremes = cell2mat(Properties.ColorTable(:,WORLD,find(strcmp(Properties.LocationTable(:,WORLD),'B'))) );
TextureName = char(Properties.TextureTable(find(strcmp(Properties.LocationTable(:,WORLD),'B')),WORLD) );
exper.worlds{WORLD}.objects{Properties.B.ObjectID}.name = ['B_' num2str(WORLD) ] ;
exper = ComputeSmoothedTextures(exper,WORLD,Properties.B.ObjectID,Transparency,[ColorExtremes],TextureName,[UncertaintyLevel(WORLD) UncertaintyLevel(UncertaintyWorlds(1)) ],MaintainColor);

ColorExtremes = cell2mat(Properties.ColorTable(:,WORLD,find(strcmp(Properties.LocationTable(:,WORLD),'C'))) );
TextureName = char(Properties.TextureTable(find(strcmp(Properties.LocationTable(:,WORLD),'C')),WORLD) );
exper.worlds{WORLD}.objects{Properties.C.ObjectID}.name = ['C_' num2str(WORLD) ] ;
exper = ComputeSmoothedTextures(exper,WORLD,Properties.C.ObjectID,Transparency,[ColorExtremes],TextureName,[UncertaintyLevel(WORLD) UncertaintyLevel(UncertaintyWorlds(1)) ],MaintainColor);

end

cd('C:\Users\Giulio\Dropbox\MATLAB_Shared\VIRMEN\ViRMEn\experiments');
save(exper.name); disp(['Experiment ' exper.name ' succesfully saved...' ]);
