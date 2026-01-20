function vr = GainManipulationSettings(vr);
vr.GainManipulation.fidSynch = fopen('GainManipulation.data','w'); %% Open file logging this info...
vr.AnimalDisplacement.fidSynch = fopen('AnimalDisplacement.data','w'); %% Open file logging this info...
vr.PositionPI.fidSynch = fopen('PositionPI.data','w');
vr.PositionPI.pos =[0];
vr.PositionPI.PreviousInstantaneousDisplacement =[0];

vr.GainManipulation.NManipulations = 0; % That is a log of the manipulations
vr.GainManipulation.ts = [0]; % That is the timestamps the manipulations
vr.GainManipulation.ChangeInGainOffset = 1; %% in seconds - it refers to how long between two consecutive changes in the gain manipulation...
vr.GainManipulation.NumberToGenerate = [3];%.*randn(1,100)+0]; %SD 5 range ~22 
vr.GainManipulation.LowUncertaintySigma = [0];%.*randn(1,100)+0]; %SD 2.5 range~7
vr.GainManipulation.MediumUncertaintySigma = [.5];%.*randn(1,100)+0]; %SD 2.5 range~7
vr.GainManipulation.HighUncertaintySigma = [.8];%.*randn(1,100)+0]; %SD 5 range ~22
vr.GainManipulation.Method ='FromLognormal' ; 
vr.GainManipulation.Resolution = 10; %% Sampling rate

eval(['vr.GainManipulation.Gain = vr.GainManipulation.' vr.LevelOfUncertainty 'UncertaintySigma ;' ]);

if strcmp(vr.GainManipulation.Method , 'FromLognormal') ;
vr.GainManipulation.Mean = log(1); % this is the mean of the gain in the lognormal distribution;
else
vr.GainManipulation.Mean = (1);
end

%% on the 9/12/2019 GC changed this into the following..
%% METHOD == 1 ; WOrking on initial log normal distribution ....
if strcmp(vr.GainManipulation.Method , 'FromLognormal') ;
vr.GainManipulation.Value = exp(vr.GainManipulation.Mean) ;
%% on the 9/12/2019 GC changed this into the following, it avoids the gain to get negative..
%vr.GainManipulation.RandomGenerator = makedist('Lognormal','mu',(vr.GainManipulation.Mean),'sigma',vr.GainManipulation.Gain);
vr.GainManipulation.RandomGenerator = makedist('Lognormal','mu',(vr.GainManipulation.Mean),'sigma',vr.GainManipulation.Gain);
vr.GainManipulation.InterpolationMethod = 'pchip'; %% linear or pchip
vr.GainManipulation.NextValue = [ vr.GainManipulation.Value random(vr.GainManipulation.RandomGenerator,1 , vr.GainManipulation.NumberToGenerate   )];
%% METHOD == 2 ; WOrking on initial normal distribution ....
elseif  strcmp(vr.GainManipulation.Method , 'FromNormal') ;
vr.GainManipulation.Value = exp(vr.GainManipulation.Mean) ;
vr.GainManipulation.RandomGenerator = (makedist('normal','mu',(vr.GainManipulation.Mean),'sigma',vr.GainManipulation.Gain));
vr.GainManipulation.InterpolationMethod = 'pchip'; %% linear or pchip
vr.GainManipulation.NextValue = exp([ log(vr.GainManipulation.Value) random(vr.GainManipulation.RandomGenerator,1 , vr.GainManipulation.NumberToGenerate   )]);
end 

vr.GainManipulation.NextTimes = [ 0 [1 : vr.GainManipulation.NumberToGenerate]/(vr.GainManipulation.ChangeInGainOffset) ] ;
%% On the 15/08/2018 GC corrected the bias for the mean gain by using a pchip interpolation of the log data and then returning the values with exp function.
vr.GainManipulation.times = [ 0 : 1/vr.GainManipulation.Resolution : vr.GainManipulation.NumberToGenerate] ;

if strcmp(vr.GainManipulation.Method , 'FromLognormal') ;
F = griddedInterpolant(vr.GainManipulation.NextTimes , log(vr.GainManipulation.NextValue),vr.GainManipulation.InterpolationMethod) ; 
vr.GainManipulation.Gains = F(vr.GainManipulation.times) ;
vr.GainManipulation.Gains = exp(vr.GainManipulation.Gains);
elseif  strcmp(vr.GainManipulation.Method , 'FromNormal') ;
F = griddedInterpolant(vr.GainManipulation.NextTimes , log(vr.GainManipulation.NextValue),vr.GainManipulation.InterpolationMethod) ; 
vr.GainManipulation.Gains = F(vr.GainManipulation.times) ;
vr.GainManipulation.Gains = exp(vr.GainManipulation.Gains);
end;



%%  It was like following until 05/07/2018...
%         vr.GainManipulation.SmmoothingWindow =  [vr.GainManipulation.Resolution*vr.GainManipulation.ChangeInGainOffset] /2 ;
%         vr.GainManipulation.Sigma =  [vr.GainManipulation.Resolution*vr.GainManipulation.ChangeInGainOffset/8] ;
% 
%         vr.GainManipulation.G = fspecial('gaussian',[vr.GainManipulation.SmmoothingWindow ,1],vr.GainManipulation.ChangeInGainOffset*vr.GainManipulation.Sigma);
%         vr.GainManipulation.SmoothedGains = filtfilt(vr.GainManipulation.G,1,vr.GainManipulation.Gains) ;








end
