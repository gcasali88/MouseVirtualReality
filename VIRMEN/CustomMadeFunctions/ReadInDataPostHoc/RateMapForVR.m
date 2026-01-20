function RateMap = RateMapForVR(VR,Tetrode,Cell,SmoothingFactor,BinSize,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits,Flag,MapType,PosType,ExperimentType) ;

if ~exist('PosType');PosType = '';end;
if isempty(PosType);PosType = '';end;

if eval(['sum(isnan(VR.pos.' PosType 'xy_cm(:,1))) ~= length(VR.pos.' PosType 'xy_cm); ' ]);


    Vars = daVarsStruct;
    %VR.pos.xy_cm(find(VR.pos.speed< Vars.pos.minSpeed),:) = NaN ;
    eval(['VR.pos.' PosType 'xy_cm(find(VR.pos.' PosType 'xy_cm(:,1) < 0),:) = NaN ;' ]);
    
    in = make_in_struct_for_rm (VR,Tetrode,Cell,Vars.pos.sampleRate,[SmoothingFactor],[BinSize],[Vars.rm.binSizeDir],0,'rate',0,0,PosType);
    
    RateMap = GetRateMap ( in); 
 %RateMap.map = imgaussfilt(RateMap.map,SmoothingFactor);

 if strcmp(ExperimentType,'FixingPoint');
    eval(['ProduceRM(RateMap.' MapType 'Map);']);
   set(gca,'XTick',[],'YTick', [] ) ; 
 else
%PosExtrema = round(FindExtremesOfArray(VR.pos.xy_cm(:,1))) ;
%PosToRm = ([PosExtrema(1):BinSize:PosExtrema(2)])+BinSize/2 ;
%PosToRm(PosToRm > PosExtrema(2))=[];
%PosExtrema = (FindExtremesOfArray(VR.pos.xy_cm(:,1))) ;
%PosExtrema = [0 ceil(PosExtrema(2))];
%PosToRm = ([PosExtrema(1):BinSize:PosExtrema(2)])+BinSize/2 ;
%PosToRm = PosToRm(PosToRm<=max(PosExtrema));
PosToRm = RateMap.minPos(1) : RateMap.binsize(1) : RateMap.maxPos(1) ;
PosToRm= PosToRm(1:length(RateMap.UnSmoothedDwell));
RateMap.Pos = PosToRm ;
if Flag
eval(['plot(PosToRm,flipud(RateMap.' MapType 'Map(1:numel(PosToRm))),' char(39) 'Color' char(39) ', SpikeColor,' char(39) 'LineWidth' char(39) ',RateMapLineWidth);' ])
end
 %% Draw lines for corresponding evnrionemnts...
%Compartments = {'A' 'B' 'C'};
%Compartments = VR.Virmen.vr.EnvironmentSettings.Evironments( find(cellfun(@isempty,strfind(VR.Virmen.vr.EnvironmentSettings.Evironments,'Pipe'))));

%Boundaries = [];
for iVisit = 1 : numel(ForEachCompartmentVisits)
 
% Boundaries = [Boundaries; 10*round(FindExtremesOfArray(VR.pos.xy_cm( ...
%  find(VR.pos.Environment== VR.Virmen.vr.EnvironmentSettings.LabelEnvironment(find(strcmp(VR.Virmen.vr.EnvironmentSettings.Evironments ,Compartments{iEnvironment}))) ...
% & VR.pos.NumberOfVisits == iVisit) ))/10)] ; 
% 


eval(['RateMap.Compartments.' ForEachCompartmentVisits{iVisit} '= RateMap.' MapType 'Map ( FindElementsWithMultipleBoundaries(RateMap.Pos, Boundaries(iVisit,:),' char(39) 'inside' char(39) ') )  ;' ])

end
%end

if Flag
for iBound = 1: numel(Boundaries)
 hold on;
line([Boundaries(iBound) Boundaries(iBound)],[FindExtremesOfArray(get(gca,'YLim'))],...
    'Color','k','LineStyle','--');
end
set(gca,'XTick',unique([sort(Boundaries(1:2:end)) Boundaries(end) ]),'YTick',round([min(VR.pos.ts(:,1)) : Vars.VR.Display.YTickForSpikePlot : max(VR.pos.ts(:,1)) ]));
xlabel('pos (cm)'); ylabel('FR (Hz)');
set(gca,'XLIM',[0 max(get(gca,'XLIM'))])
title([ 'Rate map' ]);
eval(['YTicks = [  ceil(max(RateMap.' MapType 'Map))  ] ;' ]);
if YTicks == 0;YTicks = 1; end;
set(gca,'YTick',[0   YTicks],'YLim',[0 YTicks]);  
end
 end
 
else
    title('');axis off;RateMap = [];
 
end
end