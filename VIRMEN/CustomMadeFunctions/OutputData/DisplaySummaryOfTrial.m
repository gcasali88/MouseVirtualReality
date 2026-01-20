clf;
figure(1);
LEGEND = [];LEGENDNames = [];
if strcmp(vr.Experiment,'FixingPoint')
t =plot(Data.pos.xy(:,1),Data.pos.xy(:,2));    
xlabel('x (a.u.)');ylabel('y (a.u.)');
hold on ;
plot(Data.vr.circle.xp,Data.vr.circle.yp,'r');
ylim([Data.vr.WallYLimits]);
xlim([Data.vr.WallXLimits]);
set(gca,'DataAspectRatio',[1 1 1])
else    
t =plot(Data.pos.pos,Data.pos.ts);
xlabel('position (cm)');
ylabel('time (s)');
hold on ;
end;
set(t,'Color','k');
if ~isnan(t.XData);
    LEGEND=[LEGEND ;t];
    LEGENDNames{end+1} = 'Track' ;
end;

%% scatter Axona Synch time points...
if strcmp(vr.Experiment,'FixingPoint') ; 
Ax.XData = NaN;
else    
Ax = scatter(Data.AxonaSynch.pos,Data.AxonaSynch.ts,'c','filled');
end
if ~isnan(Ax.XData);
    LEGEND=[LEGEND ;Ax];
    LEGENDNames{end+1} = 'Axona';
end;
%% scatter licks by means of raw voltage.....
if  strcmp(Data.vr.PhotoLickDetection.Model,'5V')
    PhotoLicking = find(Data.Licking.PhotoDetection.Voltage > Data.vr.PhotoLickDetection.VoltageThreshold);
elseif     strcmp(Data.vr.PhotoLickDetection.Model,'12V')
    PhotoLicking = find(Data.Licking.PhotoDetection.Voltage < Data.vr.PhotoLickDetection.VoltageThreshold);
end
PhotoLicking(PhotoLicking>length(Data.pos.ts)) = [];

if strcmp(vr.Experiment,'FixingPoint') ; 
ls = scatter(Data.pos.xy(PhotoLicking,1),Data.pos.xy(PhotoLicking,2));
else
ls = scatter(Data.pos.pos(PhotoLicking),Data.pos.ts(PhotoLicking));
end
set(ls,'MarkerEdgeColor','g','SizeData',2);clear PhotoLicking;
%% ... and licking events....
if strcmp(vr.Experiment,'FixingPoint') ; 
l = scatter(Data.Licking.PhotoLicking.xy(:,1),Data.Licking.PhotoLicking.xy(:,2),'g','filled');
%i=2;l = scatter(Data.Licking.PhotoLicking.xy(i,1),Data.Licking.PhotoLicking.xy(i,2),'g','filled');
else
l = scatter(Data.Licking.PhotoLicking.pos,Data.Licking.PhotoLicking.ts,'g','filled');
end
if sum(~isnan(l.XData))>0;
    LEGEND=[LEGEND; l];
    LEGENDNames{end+1} = 'PhotoLick' ;
end;

%% scatter rewards...
if strcmp(vr.Experiment,'FixingPoint') ; 
r = scatter(Data.Reward.xy(:,1),Data.Reward.xy(:,2),'r','filled');
else
r = scatter(Data.Reward.pos,Data.Reward.ts,'r','filled');
end
if ~isnan(r.XData);
    LEGEND=[LEGEND;r];
     LEGENDNames{end+1} ='Reward';
end
%%
% BatteryLicking = find(Data.Licking.BatteryDetection.Voltage< Data.vr.BatteryLickDetection.VoltageThreshold);
% bs = scatter(Data.pos.pos(BatteryLicking),Data.pos.ts(BatteryLicking));set(bs,'MarkerEdgeColor','b','SizeData',2);clear BatteryLicking;
% %% ... and licking events in a given window....
% bl = scatter(Data.Licking.BatteryLicking.pos,Data.Licking.BatteryLicking.ts,'b','filled');
% if sum(~isnan(bl.XData))>0;
%     LEGEND=[LEGEND; bl];
%     LEGENDNames(end+1) ={'BatteryLick'};
% end;


%% Scatter Errors (i.e. when white box was shown...)
if exist('Data.vr.WhiteWallPosOnset')
    Error = scatter(Data.vr.WhiteWallPosOnset,Data.vr.WhiteWallTimeOnset,'k','filled');
    if sum(~isnan(Error.XData))>0;
        LEGEND=[LEGEND; Error];
        LEGENDNames(end+1) ={'Error'};
    end;
end
%% Insert legend...
hold off;
if ~strcmp(vr.Experiment,'FixingPoint') ; 
axis tight;axis square;
end
if ~isempty(LEGEND)
legend(LEGEND,LEGENDNames,'box','off','Location','NorthEastOutside');
end
%%
% figure(2);plot(Data.Licking.PhotoDetection.ts,Data.Licking.PhotoDetection.Voltage)
% hold on ;
% plot(Data.Licking.BatteryDetection.ts,Data.Licking.BatteryDetection.Voltage)
% 
% ylim([0 15]);
% 
% scatter([Data.Reward.ts],3*ones(size(Data.Reward.ts,1),1),'g','filled')
% scatter([Data.Licking.BatteryLicking.ts],Data.vr.BatteryLickDetection.VoltageThreshold*ones(size(Data.Reward.ts,1),1),'r','filled')







%% Draw boundaries if any...
if ~strcmp(vr.Experiment,'FixingPoint')

Boundaries=Data.pos.pos(find(diff(Data.pos.Environment)~=0)+1);
Boundaries = unique(round(Boundaries/10)*10);
if numel(Boundaries>0)
for iBound = 1: numel(Boundaries)
 hold on;

line([Boundaries(iBound) Boundaries(iBound)],[min(Data.pos.ts) max(Data.pos.ts)],...
    'Color','k','LineStyle','--');
end
end;
end;
TitleFig = [ Data.vr.RatName(1:end-1) '_' Data.vr.Day(1:end-1) '_VR_' Data.vr.Experiment '_Session_' Data.vr.Session(1:end-1) ] ;
saveas(gcf,TitleFig,'pdf');




