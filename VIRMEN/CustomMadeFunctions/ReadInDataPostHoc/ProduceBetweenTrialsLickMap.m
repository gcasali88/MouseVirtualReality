function ret =  ProduceBetweenTrialsLickMap(VR,varargin)
    
if numel(varargin)==0;
    FlagFigure=1;
FieldToPlot = 'map';
WorldWithRewardArea = [];
elseif numel(varargin)==1;
    FlagFigure=1;
FieldToPlot = varargin{1};;
WorldWithRewardArea = [];
elseif numel(varargin)==2;
    FlagFigure={1};
    FieldToPlot=varargin{1};
    WorldWithRewardArea = varargin{2};
% elseif numel(varargin)==3;
%     FlagFigure=varargin{1};
%     FieldToPlot=varargin{2};
%     WorldWithRewardArea = varargin{3}
end

    AllSessionLick = ProduceMapOfLicking(VR,0);



    Vars = daVarsStruct;
    NumOfTrials = max(VR.pos.Trial) ; 
    
    GreatRateMap = [];
    
for iTrial = 1 : max(VR.pos.Trial)-1 ;
    
    tmpTrial = VR;
    TmpToDelete = find(VR.pos.Trial ~= iTrial) ; 
    %tmpTrial.pos.xy_cm(:,2) = 1 ; 
    tmpTrial.pos.xy_cm(TmpToDelete,:) = NaN ; 
     
    tmpLickMap  = NaN(size(AllSessionLick.map));
    tmp = ProduceMapOfLicking(tmpTrial,0,FieldToPlot);
    PosForSession = [1 : size(tmp.dwell,2)];
    
    eval([ 'tmpLickMap(PosForSession) =tmp.' FieldToPlot ' ;' ]);
    eval(['GreatRateMap = [GreatRateMap; tmpLickMap];' ]);
    clear tmpLickMap  tmp PosForSession
    
end

clear in ;
in.bins = [1:size(GreatRateMap,2)] ; 
in.meanFreqPerBin = nanmean(GreatRateMap,1) ; 
in.semFreqPerBin = StError(GreatRateMap,1) ; 
in.linecolor = [0 0 0] ;
in.shadecolor = Vars.VR.Display.LickColor ;
ret = XYSemArea(in) ; 
    
    
    
    axis tight square;
    set(gca,'XTickLabel', strread(num2str([get(gca,'XTick')*Vars.rm.binSizePosCm]),'%s')')
    xlabel('pos (cm)'); ylabel('Lick (Hz)');
    %ylim([0 max(RateMap.map)]);
    title([ 'Lick probability map' ]);
    YTicks = [  ceil(max(in.meanFreqPerBin + in.semFreqPerBin))  ] ;if YTicks == 0;YTicks = 1; end;
    %if YTicks < 1
    %set(gca,'YTick',[1],'YLim',[0 1])   
    %else
    set(gca,'YTick',[0 YTicks],'YLim',[0 YTicks])
    
    




if ~isempty(WorldWithRewardArea);
if isfield(VR.Virmen.vr,'RewardWindowWidth')
RewardWindowWidth = VR.Virmen.vr.RewardWindowWidth;
else
RewardWindowWidth = 40;
end
RewardedArea = [...
    VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y - ...
    VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2 - (RewardWindowWidth/2), ...
    VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y - ...
    VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2 + (RewardWindowWidth/2)];
 hold on ;   
 hArea = area(RewardedArea/Vars.rm.binSizePosCm,[ max(get(gca,'YLim')) max(get(gca,'YLim'))]) 
 set(hArea,'FaceColor',Vars.SpeedModulation.FloorShadeColor,'EdgeColor',Vars.SpeedModulation.FloorShadeColor)
 uistack(hArea,'bottom' );
 
 hReward = area( [nanmean(VR.Virmen.Reward.pos)-StError(VR.Virmen.Reward.pos)  nanmean(VR.Virmen.Reward.pos)+StError(VR.Virmen.Reward.pos) ] /Vars.rm.binSizePosCm,[ max(get(gca,'YLim')) max(get(gca,'YLim'))]) 
 set(hReward,'FaceColor',Vars.SpeedModulation.FloorShadeColor,'EdgeColor',Vars.SpeedModulation.FloorColor)
 l=line([nanmean(VR.Virmen.Reward.pos) nanmean(VR.Virmen.Reward.pos)]/Vars.rm.binSizePosCm,[ 0 max(get(gca,'YLim'))],'Color','r','LineWidth',2);
 
 end;

   
 %nanmean(VR.Virmen.Reward.pos   )
    
end
