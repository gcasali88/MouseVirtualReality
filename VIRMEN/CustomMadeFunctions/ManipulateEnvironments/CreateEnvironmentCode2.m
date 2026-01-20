clear 
WORLD = 1;
Transparency = NaN;
LightestColor = 255 ; 
UncertaintyLevel = 0.25 ;
MaintainColor = 0;
exper = virmenExperiment;
%load('C:\Users\Giulio\Dropbox\MATLAB_Shared\VIRMEN\ViRMEn\experiments\FloorTrial.mat')

exper.movementFunction =        @moveWithKeyboard ;
exper.transformationFunction =  @transformPerspectiveMex ;
exper.experimentCode =  @FloorTrial ;

exper.name = 'VisualUncertainty';

%WallCueSize = 30;

FloorID = 1;
WallID_1 = 2;
WallID_2 = 3;
WallID_3 = 4;

exper.worlds{WORLD}.transparency =0 ;
exper.worlds{WORLD}.objects{FloorID} = objectFloor;
exper.worlds{WORLD}.objects{WallID_1} = objectIdenticalWalls;
exper.worlds{WORLD}.objects{WallID_2} = objectIdenticalWalls;
exper.worlds{WORLD}.objects{WallID_3} = objectIdenticalWalls;


exper.worlds{WORLD}.objects{FloorID}.width = 50;
exper.worlds{WORLD}.objects{FloorID}.height = 200;

exper.worlds{WORLD}.objects{FloorID}.tiling = [10*(exper.worlds{WORLD}.objects{FloorID}.height/exper.worlds{WORLD}.objects{FloorID}.width),12];

exper.worlds{WORLD}.objects{FloorID}.elevation = -20;
exper.worlds{WORLD}.objects{FloorID}.y = exper.worlds{WORLD}.objects{FloorID}.height/2;
exper.worlds{WORLD}.objects{FloorID}.x = 0 ; 

%% Compute Texture of the floor...

exper.worlds{WORLD}.objects{FloorID}.texture.shapes{2} = shapeRectangle;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{2}.x = [0 .5];
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{2}.y  = [0 .5];  

exper.worlds{WORLD}.objects{FloorID}.texture.shapes{3} = shapeRectangle;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{3}.x = [.5 1];
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{3}.y  = [.5 1];  

exper.worlds{WORLD}.objects{FloorID}.texture.shapes{4}  = [shapeColor] ;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{4}.R = 1;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{4}.G = 1;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{4}.B = 1;

exper.worlds{WORLD}.objects{FloorID}.texture.shapes{4}.x = [mean(exper.worlds{WORLD}.objects{FloorID}.texture.shapes{2}.x);mean(exper.worlds{WORLD}.objects{FloorID}.texture.shapes{3}.x)];
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{4}.y = [mean(exper.worlds{WORLD}.objects{FloorID}.texture.shapes{2}.y);mean(exper.worlds{WORLD}.objects{FloorID}.texture.shapes{3}.y)];


exper.worlds{WORLD}.objects{FloorID}.texture.shapes{5}  = [shapeColor] ;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{5}.R = 0.1;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{5}.G = 0.1;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{5}.B = 0.1;
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{5}.x = flipud([mean(exper.worlds{WORLD}.objects{FloorID}.texture.shapes{3}.x);mean(exper.worlds{WORLD}.objects{FloorID}.texture.shapes{2}.x)]);
exper.worlds{WORLD}.objects{FloorID}.texture.shapes{5}.y = ([mean(exper.worlds{WORLD}.objects{FloorID}.texture.shapes{3}.y);mean(exper.worlds{WORLD}.objects{FloorID}.texture.shapes{2}.y)]);

compute(exper.worlds{WORLD}.objects{FloorID}.texture);

%% IDENTICAL WALLS...
WallCueSize = 100 ;

exper.worlds{WORLD}.objects{WallID_1}.bottom = exper.worlds{WORLD}.objects{FloorID}.elevation;
exper.worlds{WORLD}.objects{WallID_1}.top = exper.worlds{WORLD}.objects{FloorID}.elevation + WallCueSize/4 ;
exper.worlds{WORLD}.objects{WallID_1}.width = WallCueSize/2;
exper.worlds{WORLD}.objects{WallID_1}.x = [-exper.worlds{WORLD}.objects{FloorID}.width/2 exper.worlds{WORLD}.objects{FloorID}.width/2];
exper.worlds{WORLD}.objects{WallID_1}.y = 50;% [exper.worlds{WORLD}.objects{FloorID}.height/2 exper.worlds{WORLD}.objects{FloorID}.height/2];
CuePeriod = 100;
exper.worlds{WORLD}.objects{WallID_1}.tiling = [1 1];%[1,round(WallCueSize/CuePeriod)];
exper.worlds{WORLD}.objects{WallID_1}.name = 'WallCue_1';

exper.worlds{WORLD}.objects{WallID_2}.bottom = exper.worlds{WORLD}.objects{FloorID}.elevation;
exper.worlds{WORLD}.objects{WallID_2}.top = exper.worlds{WORLD}.objects{FloorID}.elevation + WallCueSize/4 ;
exper.worlds{WORLD}.objects{WallID_2}.width = WallCueSize/2;
exper.worlds{WORLD}.objects{WallID_2}.x = [-exper.worlds{WORLD}.objects{FloorID}.width/2 exper.worlds{WORLD}.objects{FloorID}.width/2];
exper.worlds{WORLD}.objects{WallID_2}.y = 100; % [exper.worlds{WORLD}.objects{FloorID}.height/2 exper.worlds{WORLD}.objects{FloorID}.height/2];
exper.worlds{WORLD}.objects{WallID_2}.tiling = [1 1];%[1,round(WallCueSize/CuePeriod)];
exper.worlds{WORLD}.objects{WallID_2}.name = 'WallCue_2';

exper.worlds{WORLD}.objects{WallID_3}.bottom = exper.worlds{WORLD}.objects{FloorID}.elevation;
exper.worlds{WORLD}.objects{WallID_3}.top = exper.worlds{WORLD}.objects{FloorID}.elevation + WallCueSize/4 ;
exper.worlds{WORLD}.objects{WallID_3}.width = WallCueSize/2;
exper.worlds{WORLD}.objects{WallID_3}.x = [-exper.worlds{WORLD}.objects{FloorID}.width/2 exper.worlds{WORLD}.objects{FloorID}.width/2];
exper.worlds{WORLD}.objects{WallID_3}.y = 150; % [exper.worlds{WORLD}.objects{FloorID}.height/2 exper.worlds{WORLD}.objects{FloorID}.height/2];
exper.worlds{WORLD}.objects{WallID_3}.tiling = [1 1];%[1,round(WallCueSize/CuePeriod)];
exper.worlds{WORLD}.objects{WallID_3}.name = 'WallCue_3';

%% Compute texture of the identical walls...

ColorExtremes = [ 0 0 0 ;0 0 0 ]  ;  
LightestColor = 255;% LightestColor = 100 for black to white...
RGBColumn = [2 ];  %% it was 2;
ColorExtremes(2,RGBColumn) = LightestColor;
exper = ComputeSmoothedTextures(exper,WORLD,WallID_1,Transparency,[ColorExtremes],'BlackToGreen',UncertaintyLevel,MaintainColor);


ColorExtremes = [ 0 0 0 ;0 0 0 ]  ;  
LightestColor = 255;% LightestColor = 100 for black to white...
RGBColumn = 3;
ColorExtremes(2,RGBColumn) = LightestColor;
exper = ComputeSmoothedTextures(exper,WORLD,WallID_2,Transparency,[ColorExtremes],'BlackToBlue',UncertaintyLevel,MaintainColor);

ColorExtremes = [ 0 0 0 ;0 0 0 ]  ;  
LightestColor = 100;% LightestColor = 100 for black to white...
RGBColumn = 1:3;
ColorExtremes(2,RGBColumn) = LightestColor;
exper = ComputeSmoothedTextures(exper,WORLD,WallID_3,Transparency,[ColorExtremes],'BlackToWhite',UncertaintyLevel,MaintainColor);



cd('C:\Users\Giulio\Dropbox\MATLAB_Shared\VIRMEN\ViRMEn\experiments');
save('exper');
