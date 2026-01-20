clear 
WORLD = 1;
Transparency = 0.4;

exper = virmenExperiment
%load('C:\Users\Giulio\Dropbox\MATLAB_Shared\VIRMEN\ViRMEn\experiments\FloorTrial.mat')

exper.movementFunction =        @moveWithKeyboard ;
exper.transformationFunction =  @transformPerspectiveMex ;
exper.experimentCode =  @FloorTrial ;

exper.name = 'VisualUncertainty';

%WallCueSize = 30;

FloorID = 1;
WallID = 2;
exper.worlds{WORLD}.transparency =1 ;
exper.worlds{WORLD}.objects{FloorID} = objectFloor;
exper.worlds{WORLD}.objects{WallID} = objectIdenticalWalls;


exper.worlds{WORLD}.objects{FloorID}.width = 50;
exper.worlds{WORLD}.objects{FloorID}.height = 400;

exper.worlds{WORLD}.objects{FloorID}.tiling = [10*(exper.worlds{WORLD}.objects{FloorID}.height/exper.worlds{WORLD}.objects{FloorID}.width),10];

exper.worlds{WORLD}.objects{FloorID}.elevation = -20;
exper.worlds{WORLD}.objects{FloorID}.y = exper.worlds{WORLD}.objects{1}.height/2;
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
WallCueSize = exper.worlds{WORLD}.objects{FloorID}.height;
exper.worlds{WORLD}.objects{WallID}.bottom = exper.worlds{WORLD}.objects{FloorID}.elevation;
exper.worlds{WORLD}.objects{WallID}.top = exper.worlds{WORLD}.objects{FloorID}.elevation + WallCueSize/6 ;
exper.worlds{WORLD}.objects{WallID}.width = WallCueSize;
exper.worlds{WORLD}.objects{WallID}.x = [-exper.worlds{WORLD}.objects{FloorID}.width/2 exper.worlds{WORLD}.objects{FloorID}.width/2];
exper.worlds{WORLD}.objects{WallID}.y =  [exper.worlds{WORLD}.objects{FloorID}.height/2 exper.worlds{WORLD}.objects{FloorID}.height/2];
CuePeriod = 100;
exper.worlds{WORLD}.objects{WallID}.tiling = [1,round(WallCueSize/CuePeriod)];
exper.worlds{WORLD}.objects{WallID}.name = 'WallCue';

%% Compute texture of the identical walls...

NBANDS = 50; %% say number of grays...
NSHAPES = NBANDS+2; % plus black and white...
COLORS = linspace(0,200,(NSHAPES))'/255;
COLORS = repmat(([COLORS;flipud(COLORS(1:NSHAPES-1))]),1,3);
NSHAPES = size(COLORS,1); 
exper.worlds{WORLD}.objects{WallID}.texture.shapes = {};
iShape =  numel(exper.worlds{WORLD}.objects{WallID}.texture.shapes);

while iShape  < NSHAPES
iShape = iShape+1;
tmpShape = numel(exper.worlds{WORLD}.objects{WallID}.texture.shapes)+1;

exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}  = [shapeRectangle] ;
if iShape == 1 %| iShape == NSHAPES
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.x =  [0 (1/(NSHAPES-1))/2];
else
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.x = ...
    [exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape-2}.x(2) , ...
    exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape-2}.x(2) +  1/(NSHAPES-1)  ];
end;
if exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.x(2)>1;exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.x(2)=1; end;
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.y = [0 1];
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.name = ['shape_' num2str(iShape)];

tmpShape = numel(exper.worlds{WORLD}.objects{WallID}.texture.shapes)+1;
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}  = [shapeColor] ;
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.Alpha = Transparency;
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.R = COLORS(iShape,1);
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.G = COLORS(iShape,2);
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.B = COLORS(iShape,3);
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.x = mean(exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape-1}.x);
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.y = mean(exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape-1}.y);
exper.worlds{WORLD}.objects{WallID}.texture.shapes{tmpShape}.name = ['color_' num2str(iShape)];

end;

compute(exper.worlds{WORLD}.objects{WallID}.texture);



cd('C:\Users\Giulio\Dropbox\MATLAB_Shared\VIRMEN\ViRMEn\experiments');
save('exper');
