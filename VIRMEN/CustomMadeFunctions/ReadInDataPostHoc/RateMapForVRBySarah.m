function RateMap = RateMapForVRBySarah(VR,Tetrode,Cell,SmoothingFactor,BinSize,SpikeColor,RateMapLineWidth,Boundaries,Compartments,ForEachCompartmentVisits,Flag) ;

if sum(isnan(VR.pos.xy_cm(:,1))) ~= length(VR.pos.xy_cm) %changed vr.pos to vr.position


 Vars = daVarsStruct;
  %VR.pos.xy_cm(find(VR.pos.speed< Vars.pos.minSpeed),:) = NaN ;

 in_UNsm_rm = make_in_struct_for_rm (VR,Tetrode,Cell,Vars.pos.sampleRate,[SmoothingFactor/SmoothingFactor],[BinSize],[Vars.rm.binSizeDir],0,'rate',0,0);
 in = in_UNsm_rm;RateMap = GetRateMap ( in); 
 RateMap.map = imgaussfilt(RateMap.map,SmoothingFactor);

 if strcmp(VR.Virmen.vr.Experiment,'FixingPoint');
    ProduceRM(RateMap.map)
   set(gca,'XTick',[],'YTick', [] ) ; 
 else
%PosExtrema = round(FindExtremesOfArray(VR.pos.xy_cm(:,1))) ;
%PosToRm = ([PosExtrema(1):BinSize:PosExtrema(2)])+BinSize/2 ;
%PosToRm(PosToRm > PosExtrema(2))=[];
PosExtrema = (FindExtremesOfArray(VR.position.xy_cm(:,1))) ; %changed vr.pos to vr.position
PosExtrema = [floor(PosExtrema(1)) ceil(PosExtrema(2))];
PosToRm = ([PosExtrema(1):BinSize:PosExtrema(2)])+BinSize/2 ;
PosToRm = PosToRm(PosToRm<=max(PosExtrema));
PosToRm= PosToRm(1:length(RateMap.map));
RateMap.Position = PosToRm ; %changed RateMap.Pos to Ratemap.Position
if Flag
plot(PosToRm,flipud(RateMap.map(1:numel(PosToRm))'),'Color',SpikeColor,'LineWidth',RateMapLineWidth);
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


eval(['RateMap.Compartments.' ForEachCompartmentVisits{iVisit} '= RateMap.map ( FindElementsWithMultipleBoundaries(RateMap.Pos, Boundaries(iVisit,:),' char(39) 'inside' char(39) ') )  ;' ])

end
%end

if Flag
for iBound = 1: numel(Boundaries)
 hold on;
line([Boundaries(iBound) Boundaries(iBound)],[FindExtremesOfArray(get(gca,'YLim'))],...
    'Color','k','LineStyle','--');
end
set(gca,'XTick',unique([sort(Boundaries(1:2:end)) Boundaries(end) ]),'YTick',round([min(VR.pos.ts(:,1)) : Vars.VR.Display.YTickForSpikePlot : max(VR.pos.ts(:,1)) ]));
xlabel('position (cm)'); ylabel('FR (Hz)'); %changed label pos to position
set(gca,'XLIM',[0 max(get(gca,'XLIM'))])
title([ 'Rate map' ]);YTicks = [  ceil(max(RateMap.map))  ] ;
if YTicks == 0;YTicks = 1; end;
set(gca,'YTick',[0   YTicks],'YLim',[0 YTicks]);  
end
 end
 
else
    title('');axis off;RateMap = [];
 
end
end