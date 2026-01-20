function [ daVars ] = daVarsStruct( );
%DAVARS Variable structure for anlaysis of DA data subsequently adapted
%from Giulio Casali for FW data...
%%%POSITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
daVars.pos.sampleRate = 50 ; % Hertz
daVars.pos.maxSpeed = 4; %Speeds above this are considered to be jumpy (m/s) NOTE UNITS - used by postprocess_pos_data
daVars.pos.minSpeed = 2; %Speeds below this are consider to be stationary (cm/s) NOTE UNITS - not sure where this is used
daVars.pos.boxCar =0.4; %Position smoothing boxcar width (s)
daVars.pos.maxCuttingSpeed =50; % cm/s positions removed from speed theta relationships
daVars.pos.maxSpeedThetaBin = 20;% cm/2, maximum bin value for speed-theta correlation;
%daVars.pos.XThreshold = 10; %in centimeters
%daVars.pos.ZThreshold = 10; %in centimeters 
% --- Trajectory filters - used to determine which trajectories (paths
% through field) are analysed
daVars.pos.trjMinSpd=2.5; %Minimum speed during trajectory - to excluded stops [5]
daVars.pos.trjSpd=12; %Mean speed should exceed this [15] cm/s
daVars.pos.trjDst=8; %Traj must be longer than this [8]cm
daVars.pos.trjDstMax=50; %Traj must be shorter than this [50]cm %EDIT JONAS
daVars.pos.trjTort=1.25; %Tortuosity must be <= this [1.25]
daVars.pos.ThresholdToRemove = 10 ;%in cm.
daVars.pos.AutoCorrelationTimeWindow = 500 ; %in ms
daVars.pos.MaxEnvironmentSize = 120; %cm%
%%% RATEMAPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
daVars.rm.binSizePos=8; %Size of bin - 8 is equal to old Tint
daVars.rm.binSizePosCm=2; %Size of bins in cm - used with reference to pix/m
daVars.rm.UNsmthKernPos= 1; % makes an unsmoothed kernel
daVars.rm.smthKernPos=5; %Size of box car kernel used to produce smooth rm/ bins
daVars.rm.GaussianSigma = 1;
daVars.rm.GaussianHsize = 5;
daVars.rm.binSizeDir=360/60; %Size of polar bins in deg
daVars.rm.smthKernDir=5; %Size of box car kernel used to smooth polar plot/ bins
daVars.rm.rmFldArea=35; %min required bins for a valid field
daVars.rm.rmPlaceCellsFieldsAreas = 60; %in cm^2
daVars.rm.rmGridCellsFieldsAreas =  60; %in cm^2
daVars.rm.rmGridCellsFieldsMinimumNumberSpikes = 0.01; %of the whole number od spikes...
daVars.rm.rmPlaceCellsFieldsMinimumNumberSpikes = 0.1; %of the whole number od spikes...
daVars.rm.rmPlaceCellsMinimumFieldDistance = 30 ; %cm;
daVars.rm.rmGridCellsMinimumFieldDistance =  5 ; %cm;
daVars.rm.ThresholdMultiplicator = 1.5; % This is the value you want to use to Multiply the mean rate map to get the field Cut off
daVars.rm.PeakPercentageThreshold = 0.2; %Percentage thresholded from the peak of firing, this method is well established for Place Cells, not so much for Grid maybe...
daVars.rm.RateMapPercentileThreshold = 75;%Percentile from the smoothed map to take as threshold;
daVars.rm.PlaceCellsMinimumPeakRate = 1; % in Hertz for Place cells, all the firing fields must exibit a peak greater than this.
daVars.rm.PlaceCellsMinimumAverageFirRate= 0.1;
daVars.rm.PlaceCellsMaximumAverageFirRate= 5;
daVars.rm.PlaceCellsWaweformWidth= 2.5;
daVars.rm.PlaceCellsMinimumSpatialModulationbitsbitsSpike= 0.5;
daVars.rm.GridCellsMinimumPeakRate = 1;  % in Hertz for Grid cells, all the firing fields must exibit a peak greater than this.
daVars.rm.GaussianSmoothingFilter = [0.0025    0.0125    0.0200    0.0125    0.0025;0.0125    0.0625    0.1000    0.0625    0.0125;0.0200    0.1000    0.1600    0.1000    0.0200;0.0125    0.0625    0.1000    0.0625    0.0125; 0.0025    0.0125    0.0200    0.0125    0.0025];
daVars.rm.Alpha = 200; % for adaptibe binning this is the standard parameter;
daVars.rm.MeanFiringRateForGCDetection = 3 ; 
daVars.rm.PeakFiringRateThreshold = 0.95 ;
daVars.rm.MinimumCorrelationValueForSacFieldDetection=0.2;
daVars.rm.MinimumCorrelationValueForStripeScoreDetection=0.2;
daVars.rm.FieldCoverageThreshold = 0.5;
daVars.rm.RateCoverageThreshold = 0.5;
daVars.rm.MinimumGridScaleThreshold = 25;
%%% EEG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Controls which eeg channels to load options are as follows
daVars.eeg.eeg2load='all';
% --- Power spec variables
daVars.eeg.sampleRate =250;
daVars.eeg.psSmth= [2, 0.1875]; %Smooth ps with this kern
daVars.eeg.psThRat = [7,11]; %Range to look for theta in Hz
daVars.eeg.psThMouse = [6,10]; %Range to look for theta in Hz
daVars.eeg.psMaxF = 25; %Max freq - truncate beyond this
daVars.eeg.psxmax = 125; %Max frequency to work out s2n
daVars.eeg.psS2Nw = 2; %With of s2n in hz - half each side of peak
daVars.eeg.speedBinLengthCm = [2];
daVars.eeg.speedBins = [3:daVars.eeg.speedBinLengthCm:daVars.pos.maxSpeedThetaBin ];
daVars.eeg.minThetaRun = [10]; % in seconds, minimum run length to be included in the analysis
daVars.eeg.NBinsOfSpikingThetaModulation = 5 ;
daVars.eeg.TroughLimits = [0.05 0.07];
daVars.eeg.PeakLimits = [0.100 0.140];
%---Parameters for Maxima Detection
daVars.Maxima.ToDeleteMaximaWithinWavelenghtThreshold = 0.30;; % if two Maxima within X ray , the lowest one is removed...
daVars.Maxima.ThresholdForSingleField = 0.35; % MINIMUM FIRING RATE of the local maxima
daVars.Maxima.MaxThresholdForSingleField = 0.50; % MAXFIRING RATE REDUCTION from the local maxima
% --- Phase analysis
daVars.eeg.remPercAmp =5; %Remove eeg values with amp below this proportion (i.e. 5 is lowest 5% )
% --- Regression
daVars.eeg.regNIt=10000; %Number of shuffles to get p value [1000 ] the latter
% takea about 10x longer
daVars.Flag.RemoveNaNsFrom = 1;
daVars.Flag.DontRemoveNaNsFrom = 0;
daVars.PhasePrecession.intrThetaModulationThreshold = 5;
daVars.PhasePrecession.LFPThetaModulationThreshold = 10;
daVars.PhasePrecession.binSizePosCm = [.5];
%%
daVars.Shuffling.ShufflesNumber = 400;
daVars.Shuffling.MinShift = 30;
daVars.Shuffling.SpeedSmoothingWindow = 0.260;%in seconds...
daVars.Shuffling.GridnessPrcThreshold = 99;
daVars.Shuffling.FloorGridnessThreshold=0.29964;
daVars.Shuffling.WallGridnessThreshold=0.32298;
daVars.Shuffling.OpenFieldGridnessThreshold=0.25054;
daVars.Shuffling.SpeedModulationPrcThreshold = 99;
daVars.Shuffling.FloorSpeedModulationThreshold=0.89759;
daVars.Shuffling.WallSpeedModulationThreshold=0.91409;
daVars.Shuffling.OpenFieldSpeedModulationThreshold=0.90836;
daVars.Shuffling.FloorSpeedModulationRAWThreshold=0.040021;
daVars.Shuffling.WallSpeedModulationRAWThreshold=0.039924;
daVars.Shuffling.OpenFieldSpeedModulationRAWThreshold=0.039007;
daVars.Shuffling.SpeedModulationSlopePrcThreshold = 99;
daVars.Shuffling.FloorSpeedModulationSlopeThreshold=0.046677;
daVars.Shuffling.WallSpeedModulationSlopeThreshold=0.043254;
daVars.Shuffling.OpenFieldSpeedModulationSlopeThreshold=0.055987;
daVars.Shuffling.DirectionalModulationPrcThreshold = 99;
daVars.Shuffling.FloorDirectionalModulationThreshold=0.19261;
daVars.Shuffling.WallDirectionalModulationThreshold=0.51286;
daVars.Shuffling.OpenFieldDirectionalModulationThreshold=0.16801;
daVars.Shuffling.SpatialModulationbitsbitsSpikePrcThreshold = 99;
daVars.Shuffling.FloorSpatialModulationbitsbitsSpike=1.7522;
daVars.Shuffling.WallSpatialModulationbitsbitsSpike=4.2239;
daVars.Shuffling.OpenFieldSpatialModulationbitsbitsSpike=2.1372;
daVars.Shuffling.MapCorrelationPrcThreshold = 95;
daVars.Shuffling.FloorMapCorrelationThreshold=0.13719;
daVars.Shuffling.WallMapCorrelationThreshold=0.18693;
daVars.Shuffling.OpenFieldMapCorrelationThreshold=0.11349;
%%
daVars.SpeedModulation.MinimumThresholdFiringRate = 0.5;
daVars.SpeedModulation.MaximumThresholdFiringRate =2;
daVars.SpeedModulation.DirectionalBins = 4;
daVars.SpeedModulation.DirectionalBinsLabels = {'East','North','West','South','All'};
daVars.SpeedModulation.LagExtrema= 0.400 ;
daVars.SpeedModulation.FloorColor=  [1 0 0] ;
daVars.SpeedModulation.WallColor=  [0 1 1] ;
daVars.SpeedModulation.OpenFieldColor= [ 255 178 102]/255;
daVars.SpeedModulation.FloorShadeColor=  [255 204 204]/255; ;
daVars.SpeedModulation.WallShadeColor=  [ 204 255 255]/255; ;
daVars.SpeedModulation.OpenFieldShadeColor=  [ 255 229 204]/255; ;
daVars.SpeedModulation.MinimumPercentageForRepresentativeData= 1 ;
daVars.SpeedModulation.FWColor = [11 250 35]/255;
daVars.SpeedModulation.FOFColor = [234 250 11]/255;
daVars.SpeedModulation.OFWColor = [1 138 14]/255;
daVars.SpeedModulation.SpeedByHeadingSmoothingFilter.SpeedBinSize = 1;
daVars.SpeedModulation.SpeedByHeadingSmoothingFilter.HSpeedBinSize = 12;
daVars.SpeedModulation.SpeedByHeadingSmoothingFilter.DirBinSize = 3;
daVars.SpeedModulation.SpeedByHeadingSmoothingFilter.HDirBinSize = 36;
daVars.SpeedModulation.SpeedByHeadingSmoothingFilter.Sigma = 5;
daVars.Cell.GridCell.color = 'r'; % For spike Plots use red;
daVars.Cell.PlaceCell.color = 'g';% For spike Plots use green
daVars.Cell.GridCell.LineStyle = '-';
daVars.Cell.SpeedCell.LineStyle = '--';
daVars.Cell.LFP.LineStyle = ':';
daVars.Display.FloorWallColors = {daVars.SpeedModulation.FloorColor ,daVars.SpeedModulation.WallColor };
daVars.Display.FloorWallOpenFieldColors = {daVars.SpeedModulation.FloorColor ,daVars.SpeedModulation.WallColor , daVars.SpeedModulation.OpenFieldColor };
daVars.Display.FloorAndWallColor = [30 253 67]/255; 
daVars.Display.FloorAndWallNegativeColor = [192 192 192]/255; 
daVars.Display.FloorAndWallPositiveColor = [191 126 188]/255; 
daVars.Display.LineColor = 'k';
daVars.Display.DotType = 'filled';
daVars.Display.DotColor = 'k';
daVars.Display.ThetaAnalysisFontSize = 5;
daVars.Display.PegboardNaiveAnimals = [148 252 144]/255;
daVars.Display.PegboardRobinAnimals = [206 126 235]/255;
daVars.Display.PegboardExperiencedAnimals = [245 252 144]/255;
daVars.Display.PegboardHorizontalAnimals = [255 184 75]/255;
daVars.Display.PegboardDiagonalAnimals = [51 255 255]/255;
daVars.Display.MECColor = 'y';
daVars.Display.HPCColor = daVars.Cell.PlaceCell.color;
daVars.SpeedFrequency.BinsSize = 6;
daVars.SpeedFrequency.BinsCents = [5 11 17] ;
%% Info for VR

daVars.VR.Display.LickColor = [0 1 0];
daVars.VR.Display.SpikeColor = [1 0 0];
daVars.VR.Display.TrackColor = [0 0 0];
daVars.VR.Display.RewardColor = [0 1 1];
daVars.VR.Display.InsideRewardAreaLick = [0 1 0];
daVars.VR.Display.OutsideRewardAreaLick = [1 0 0];


end
