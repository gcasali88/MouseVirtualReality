function [ Gaussian , pos ] = Smooth1DSignal( GaussianSIGMA , SIGNAL ,SIZE )
% This function aims to return a smoothed signal after 
% Gaussian smoothing with a standard deviation as input.
% Note the sum of area of the smoothed gaussian and initial data should be the same.

% If SIGMA == 0 , then the function returns a squarewave. By increasing SIGMA,
% the gaussian gets wider and lower.

% This function was initially created to normalize the intensity/brightness of the cues shown in VR,
% with increasing SIGMAS across worlds - i.e. make the environment more uncertain.
if ~exist('WIDTH','var'); SIGNAL = .10; end;  %% Compatible with ComputeSmoothedTextures function...
if ~exist('SIZE','var'); SIZE = .40; end;  %% Compatible with ComputeSmoothedTextures function...



LIMIT = 5;

%WIDTH = LIMIT*SIGNAL ;

BinSize= .001;
pos = [-LIMIT:BinSize: LIMIT];

height = 1;
CentreID = ceil(numel(pos)/2);
Centre = pos(CentreID);

%Rectangle = zeros(numel(pos),1);
%Rectangle(FindElementsWithMultipleBoundaries(pos,[pos(CentreID)-WIDTH pos(CentreID)+WIDTH],'inside')) = height;
%plot(pos,Rectangle,'k');
%areaRectangle = round(trapz(Rectangle));


% SIGMAS = [0:1:25]/100;
% COLORS = jet(numel(SIGMAS));
% clf;
% for iLine = 1 : numel(SIGMAS);

%hold on ;
%SIGMA = SIGMAS(iLine);%20/100;
SIGMA = numel(FindElementsWithMultipleBoundaries(pos,[pos(CentreID)-GaussianSIGMA pos(CentreID)+GaussianSIGMA],'inside'));

SIZE = SIZE*2+1;
SIZE = numel(FindElementsWithMultipleBoundaries(pos,[pos(CentreID)-SIZE pos(CentreID)+SIZE],'inside'));


Gaussian = fspecial('gaussian',[1 SIZE ],SIGMA)   ;

pos = linspace(0 , 1 , numel(Gaussian)) ; 


%Gaussian = imgaussfilt(Rectangle,SIGMA,'FilterSize', SIZE);
%plot(pos,Gaussian,'Color',[COLORS(iLine,:)]);

%areaGaussian = round( trapz(Gaussian));

%isequal(areaGaussian,areaRectangle);
%hold off;

% figure(1);clf;
% plot(pos,Gaussian) ; 
% hold on ;
% plot(pos,Rectangle,'r');axis square;

end


