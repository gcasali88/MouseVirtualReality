function SpikePlotForVR(VR,Tetrode,Cell,SpikeColor,SpikeDotSize,TrackColor,TrackLineSize,Boundaries,PosType,ExperimentType);
if ~exist('PosType');PosType = '';end;
if isempty(PosType);PosType = '';end;
Vars = daVarsStruct;
%VR.pos.xy_cm(find(VR.pos.speed< Vars.pos.minSpeed),:) = NaN ;

SpikeIndices =  find(VR.tetrode(Tetrode).cut == Cell)  ;
SpikeTs = VR.tetrode(Tetrode).ts(SpikeIndices) ;
SpikePos = VR.tetrode(Tetrode).pos_sample(SpikeIndices);
SpikePos(~SpikePos) = 1;
if strcmp(ExperimentType,'FixingPoint');
plot(VR.pos.xy_cm(:,1),VR.pos.xy_cm(:,2),'Color' ,TrackColor, 'LineWidth' ,TrackLineSize);
hold on ;
plot(VR.pos.xy_cm(SpikePos,1),VR.pos.xy_cm(SpikePos,2),'.','Color' ,SpikeColor, 'LineWidth' ,SpikeDotSize);
xlabel('pos (a.u.)'); ylabel('pos (a.u.)');
hold on ;
set(gca,'DataAspectRatio',[1 1 1]);axis tight ;


else
eval(['plot(VR.pos.' PosType 'xy_cm(:,1),VR.pos.Trial,' char(39) '.' char(39) ', ' char(39) 'Color' char(39) ',TrackColor, ' char(39) 'LineWidth' char(39) ',TrackLineSize/10);' ])
hold on ;
eval(['plot(VR.pos.' PosType 'xy_cm(SpikePos,1),VR.pos.Trial(SpikePos),' char(39) '.' char(39) ',' char(39) 'Color' char(39) ',SpikeColor, ' char(39) 'LineWidth' char(39) ',5*SpikeDotSize);' ]);
xlabel('pos (cm)'); ylabel('Trial #');axis tight;hold on ;
Trials = unique(VR.pos.Trial);
Trials = Trials(~isnan(Trials)) ;

if isfield(VR.Virmen,'vr') & isfield(VR.Virmen.vr, 'WorldNameWithReward') & isfield(VR.Virmen.vr, 'LevelOfUncertainty') 
t = title([VR.Virmen.vr.WorldNameWithReward ',' VR.Virmen.vr.LevelOfUncertainty ' uncertainty']);
end   



for iBound = 1: numel(Boundaries)
 hold on;
%line([Boundaries(iBound) Boundaries(iBound)],[FindExtremesOfArray(VR.pos.ts)],...
    %'Color','k','LineStyle','--');
line([Boundaries(iBound) Boundaries(iBound)],[0 max(VR.pos.Trial)+1],...
    'Color','k','LineStyle','--');

end


axis tight ;
%set(gca,'XTick',round([min(VR.pos.xy_cm(:,1)) : Vars.VR.Display.XTickForSpikePlot : max(VR.pos.xy_cm(:,1)) ]),'YTick',round([min(VR.pos.ts(:,1)) : Vars.VR.Display.YTickForSpikePlot : max(VR.pos.ts(:,1)) ]));
%set(gca,'XTick',unique([sort(Boundaries(1:2:end)) Boundaries(end) ]),'YTick',round([min(VR.pos.ts(:,1)) : Vars.VR.Display.YTickForSpikePlot : max(VR.pos.ts(:,1)) ]));
if isempty(Trials);
title('No trials');set(gca,'XTick',unique([sort(Boundaries(1:2:end)) Boundaries(end) ]),'YTick',[Trials],'YLim',[0 1]);
else  
set(gca,'XTick',unique([sort(Boundaries(1:2:end)) Boundaries(end) ]),'YTick',[Trials],'YLim',[0 max(Trials)+1]);
end


end


set(gca,'Layer','top');
end
    