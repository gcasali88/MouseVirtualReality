function exper = ComputeSmoothedTextures(exper,WORLD,OBJECT_ID,Transparency,ColorExtremes,TextureName,UncertaintyLevels,MaintainColor);
%% Function written by GC to compute texture manipulation in virmen for Matlab 2015.
% It takes the following input:

%exper = vr.exper in virme.
%WORLD = index of for the World in exper.world cell to look at 
%OBJECT_ID = index of for the object in exper.world{WORLD} cell to look at 
%Transparency = if NaN the transparency option in virmen is disabled.
%ColorExtremes = The RGB values to use when the 
%TextureName = Name of the texture name as char
%UncertaintyLevels = Two numbers corresponding to the sigmas to use in the Gaussian to compute smoothing. Ex: [0.05 0.1 ];
%MaintainColor = logical (i,e. either 0 or 1). If 1 the original color is
%kept rather than changed. I prefer set this to 0.

%% 
oldTexture = exper.worlds{WORLD}.objects{OBJECT_ID}.texture;
N_Lateral_BANDS = 100; % it will be 100; %% say number of grays...
N_Central_BANDS = 1;%ceil(.10*N_Lateral_BANDS); % it will be 100; %% say number of grays...

UncertaintyLevel = UncertaintyLevels(1); ;
CertaintyLevel = UncertaintyLevels(2); ;

COLORS = [zeros(N_Lateral_BANDS,3)];

[ CertainGaussian ,GaussianPos] = Smooth1DSignal( CertaintyLevel  ) ; %';,CentralBandWidth ) ;
%% When debuggin uncommet the following lines...
%plot(GaussianPos,CertainGaussian,'k')
%hold on ;
[ Gaussian ,GaussianPos] = Smooth1DSignal( UncertaintyLevel  );
%plot(GaussianPos,Gaussian,'r');
%% ReNormalize the Gaussian
Gaussian = Gaussian/max(CertainGaussian); % This way the Gaussians are normalized based on max certainty with peak = 1;


if MaintainColor
Gaussian = Gaussian/max(Gaussian); %% Renormalize otherwise it gets too dark later on...
end;
%% When debuggin uncommet the following lines...
%plot(pos,Gaussian);

for iRGB = 1 : size(ColorExtremes,2)
    NEWPOS = linspace(0,max(GaussianPos)/2,N_Lateral_BANDS) ;
    F = griddedInterpolant(GaussianPos,ColorExtremes(1,iRGB) + Gaussian .* repmat(diff(ColorExtremes(:,iRGB)),1,[numel(Gaussian)])); %transpose(linspace(ColorExtremes(1,iRGB)  ,ColorExtremes(2,iRGB)  ,numel(Gaussian)))) ;
    COLORS(:,iRGB) = F(NEWPOS);
end

%% When debuggin uncommet the following line...
% plot(NEWPOS,COLORS)
clear NEWPOS;
COLORS = COLORS/255;

COLORS = [COLORS;repmat(COLORS(end,:),N_Central_BANDS,1);flipud(COLORS)];
pos = linspace(min(GaussianPos) , max(GaussianPos) , length(COLORS)+1) ; 
%% When debuggin uncommet the following line...
% plot(NEWPOS,COLORS)


NSHAPES = size(COLORS,1); 
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes={};
iShape = 1;


while iShape  <= NSHAPES   
if iShape == NSHAPES-1;
end

tmpShape = numel(exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes)+1;
%% Produce Shape...
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}  = [shapeRectangle] ;
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.x = [pos(iShape) pos(iShape) + mean(diff(pos)) ];%pos(iShape+1)];
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.y = [0 1];
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.name = ['shape_' num2str(iShape)];
if sum(exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.x>1)
end
%% Produce Color...
tmpShape = numel(exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes)+1;
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}  = [shapeColor] ;
if isequal(COLORS(iShape,:),ColorExtremes(1,:)/255)
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.Alpha = 0; %it was 0 ;
else
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.Alpha = 1;
end
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.R = COLORS(iShape,1);
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.G = COLORS(iShape,2);
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.B = COLORS(iShape,3);
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.x = repmat(mean(exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape-1}.x),1,2);
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.y = [0.1 0.9]* max(exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape-1}.y);  %exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape-1}.y;
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape}.name = ['color_' num2str(iShape)];
%scatter(mean(exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape-1}.x),mean(exper.worlds{WORLD}.objects{OBJECT_ID}.texture.shapes{tmpShape-1}.y))
iShape = iShape+1;
end
exper.worlds{WORLD}.symbolic.transparency = {'1'};
exper.worlds{WORLD}.objects{OBJECT_ID}.texture.name = TextureName;
%a = draw(exper.worlds{WORLD}.objects{OBJECT_ID}.texture);
compute(exper.worlds{WORLD}.objects{OBJECT_ID}.texture);

end



