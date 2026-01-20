function [ret] = ProduceTemporalLickPlot(VR,varargin)
if numel(varargin)==0;
    FlagFigure=1;
    BinSize=10;
%     WorldWithRewardArea = [];
elseif numel(varargin)==1;
    FlagFigure = varargin{1} ;  
    BinSize = 10;
elseif numel(varargin)==2;
    FlagFigure = varargin{1} ;  
    BinSize = varargin{2} ;  

%     WorldWithRewardArea = [];
% elseif numel(varargin)==2;
%     FlagFigure = varargin{1} ;    
% WorldWithRewardArea = varargin{2} ;   
end

%LickTs = VR.Virmen.vr.PhotoLickDetection.LickTimeStamps ; 
% LickTs = VR.Licking.Voltage < VR.Virmen.vr.PhotoLickDetection.VoltageThreshold ;
% 
% LickTs = VR.Licking.ts(find(diff(LickTs)==1)+1) ;
% [crosscorr,y]  = calcXCH(LickTs,LickTs);
%% Produce Histogram of the interspike interval...

if FlagFigure
TimeWindow = 500;    

logical = (VR.Licking.Voltage < VR.Virmen.vr.PhotoLickDetection.VoltageThreshold);
Indices = 1+find(diff(logical)==1);
%tmp(Indices) =1;
%subplot(4,1,3);
%plot(VR.Licking.ts,tmp);
%xlim([XMin XMax]);
%set(gca,'XTick',VR.Licking.ts)

LickTs = VR.Licking.ts(Indices) ;
%subplot(4,1,4);
ret = hist_perc(diff(LickTs)*1000,BinSize,[0 TimeWindow],1) ;
xlabel('time (ms)');ylabel('count (ratio)');
title('Interlick interval');



% l = plot(y,crosscorr,'Color',[0 0 0],'LineWidth',[2]) ;
% xlim([-TimeWindow TimeWindow])
% hold on ;
% line([0 0],[get(gca,'YLim')],'Color','r','LineWidth',[2]) ;
% xlabel(['time (ms)']);
% set(gca,'YTick',[],'XTick',[-TimeWindow:TimeWindow/4:TimeWindow])
% title('Lick Autocorrelation');
% axis square;

end
%  if ~isempty(WorldWithRewardArea);
%    RewardedArea = [...
%      VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.y - ...
%      VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.GoalCue}.height/2 , ...
%      VR.Virmen.vr.exper.worlds{WorldWithRewardArea}.objects{VR.Virmen.vr.worlds{WorldWithRewardArea}.objects.indices.EndPipe}.y(1) ];
%     
%     hold on ; 
%     
%     line([RewardedArea(1) RewardedArea(2); RewardedArea(1) RewardedArea(2)],[get(gca,'YLim');get(gca,'YLim')])
%          
%  end;
% 
% 
% figure(2);subplot(2,1,1);
% plot(VR.Licking.ts,VR.Licking.Voltage);
% xlim([4 10])
% figure(2);subplot(2,1,2);
% LickTs = VR.Licking.Voltage < VR.Virmen.vr.PhotoLickDetection.VoltageThreshold ;
% FilteredLicks = zeros(numel(LickTs),1);
% FilteredLicks(find(diff(LickTs)==1)+1) = 1;
% plot(VR.Licking.ts,FilteredLicks ) ;
% xlim([4 10])
% 


%end
end