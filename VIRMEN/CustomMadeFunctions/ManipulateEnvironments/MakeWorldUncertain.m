function vr = MakeWorldUncertain(vr);

Vars = daVarsStruct ;

vr.VisualUncertainty.Properties = [];

vr.VisualUncertainty.Properties.Transparecny = NaN;
%vr.VisualUncertainty.Properties.LightestColor = 255 ; %% You may think about changing it to differentiate the environments even more...
%Properties.UncertaintyWorlds = [1 : 3];
vr.VisualUncertainty.Properties.UncertaintySigmas = Vars.VR.VisualUncertainty.Properties.UncertaintySigmas; ;  %  it was [0.05 0.12  .20 ];
vr.VisualUncertainty.Properties.UncertaintlyLevels = Vars.VR.VisualUncertainty.Properties.UncertaintlyLevels ; 
vr.VisualUncertainty.Properties.UncertaintlyLevel = vr.VisualUncertainty.Properties.UncertaintySigmas(find(strcmp(vr.VisualUncertainty.Properties.UncertaintlyLevels,vr.LevelOfUncertainty )));

vr.VisualUncertainty.Properties.MaintainColor = 0;

vr.VisualUncertainty.Properties.Walls.Width = 200;
vr.VisualUncertainty.Properties.Walls.Top = 30;
vr.VisualUncertainty.Properties.Walls.Bottom = -30;

vr.VisualUncertainty.Properties.Ceiling.Width = vr.VisualUncertainty.Properties.Walls.Width;
vr.VisualUncertainty.Properties.Ceiling.Elevation = vr.VisualUncertainty.Properties.Walls.Top;
vr.VisualUncertainty.Properties.Ceiling.Height = 50;


vr.VisualUncertainty.Properties.Objects.A.ObjectID = 1;
vr.VisualUncertainty.Properties.Objects.A.Size = 500;

vr.VisualUncertainty.Properties.Objects.B.ObjectID = 2;
vr.VisualUncertainty.Properties.Objects.B.Size = 500;

vr.VisualUncertainty.Properties.Objects.C.ObjectID = 3;
vr.VisualUncertainty.Properties.Objects.C.Size = 200;

vr.VisualUncertainty.Properties.Objects.D.ObjectID = 4;
vr.VisualUncertainty.Properties.Objects.D.Size = 200;

%%                                                    World X       World Y        World Z
vr.VisualUncertainty.Properties.LocationTable =     { 'A'           'C'             'B'  ;...    LEFT
                                                      'B'           'A'             'C'  ;...    RIGHT
                                                      'C'           'B'             'A'  ;...   TOP
                                                      'D'           'D'             'D'   };
vr.VisualUncertainty.Properties.TextureTable = {'BlackToBlue'   'BlackToYellow'   'BlackToWhite'     ;...    LEFT
                                                'BlackToGrey'   'BlackToBordeaux' 'BlackToBlack'  ;...    RIGHT
                                                'BlackToGreen'  'BlacToCyan'      'BlackToOrange'     ;...    TOP
                                                'BlackToPink'   'BlacToLavanda'   'BlackToPurple'     };...} ;...  TOP

vr.VisualUncertainty.Properties.ColorTable={};
vr.VisualUncertainty.Properties.ColorTable(:,:,1) = {[84  255  250] ,  [ 255 255 204]  ,  [ 255 255 255]}; %% The black blue was [0  0 255];
vr.VisualUncertainty.Properties.ColorTable(:,:,2) = {[224 224 224] , [ 255  0  255]  ,  [ 0  0 0]};
vr.VisualUncertainty.Properties.ColorTable(:,:,3) = {[ 0  255  0 ] , [  0  255 255]  ,      [ 255 128 0]};  %...  TOP
vr.VisualUncertainty.Properties.ColorTable(:,:,4) = {[ 255  204  229] , [  204  204 255]  , [ 127 0 255]};  %...  TOP





vr.WorldNames = {};
for iWorld = 1 : numel(vr.exper.worlds);   
vr.WorldNames{iWorld} = vr.exper.worlds{iWorld}.name ;
end;

vr.WorldIndex = find(strcmp(vr.WorldNames,vr.NameOfTheWorld)) ;
%vr.exper.worlds{vr.WorldIndex}.transparency = vr.VisualUncertaintyProperties.Transparecny;


%% Compute texture of the identical walls...

ObjectsToChange = fields(vr.VisualUncertainty.Properties.Objects);

for iObject = 1 : numel(ObjectsToChange);
if strcmp(class( vr.exper.worlds{vr.WorldIndex}.objects{iObject})  ,'objectIdenticalWalls')  ;
    vr.exper.worlds{vr.WorldIndex}.objects{iObject}.bottom =vr.VisualUncertainty.Properties.Walls.Bottom;;
    vr.exper.worlds{vr.WorldIndex}.objects{iObject}.top = vr.VisualUncertainty.Properties.Walls.Top;
    vr.exper.worlds{vr.WorldIndex}.objects{iObject}.width = vr.VisualUncertainty.Properties.Walls.Width ;
    
elseif strcmp(class( vr.exper.worlds{vr.WorldIndex}.objects{iObject})  ,'objectFloor')  ;

    vr.exper.worlds{vr.WorldIndex}.objects{iObject}.width = vr.VisualUncertainty.Properties.Ceiling.Width ; 
    vr.exper.worlds{vr.WorldIndex}.objects{iObject}.elevation =vr.VisualUncertainty.Properties.Ceiling.Elevation;;
    vr.exper.worlds{vr.WorldIndex}.objects{iObject}.height = vr.VisualUncertainty.Properties.Ceiling.Height;
    
end

ColorExtremes = cell2mat(vr.VisualUncertainty.Properties.ColorTable(:,vr.WorldIndex,find(strcmp(vr.VisualUncertainty.Properties.LocationTable(:,vr.WorldIndex),ObjectsToChange{iObject}))) );

ColorExtremes = [ vr.exper.worlds{vr.currentWorld}.backgroundColor *255;ColorExtremes];

TextureName = char(vr.VisualUncertainty.Properties.TextureTable(find(strcmp(vr.VisualUncertainty.Properties.LocationTable(:,vr.WorldIndex),ObjectsToChange{iObject})),vr.WorldIndex)) ;
eval(['vr.exper.worlds{vr.WorldIndex}.objects{vr.VisualUncertainty.Properties.Objects.' ObjectsToChange{iObject} '.ObjectID}.name = [' char(39)  ObjectsToChange{iObject}    '_'  num2str(vr.WorldIndex) char(39) ']  ; ' ]);
eval(['vr.exper = ComputeSmoothedTextures(vr.exper,vr.WorldIndex,vr.VisualUncertainty.Properties.Objects.' ObjectsToChange{iObject} '.ObjectID,vr.VisualUncertainty.Properties.Transparecny ,[ColorExtremes],TextureName,[vr.VisualUncertainty.Properties.UncertaintlyLevel vr.VisualUncertainty.Properties.UncertaintySigmas ],vr.VisualUncertainty.Properties.MaintainColor );' ]);
eval(['compute(vr.exper.worlds{vr.WorldIndex}.objects{vr.VisualUncertainty.Properties.Objects.' ObjectsToChange{iObject} '.ObjectID}.texture);' ]);
end

end