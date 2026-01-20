function PlotCorrelationValuesBetweenCompartmentsAcrossSessions(RateMaps)
Vars = daVarsStruct;
OffSet = 0.1;
CorrelationsBetweenDifferentEnvironmentsColor = Vars.SpeedModulation.FloorColor;
CorrelationsBetweenSameEnvironmentsColor = Vars.SpeedModulation.WallColor;
M_Correlations = []; StError_Correlations = [] ;
for iSession = 1 : numel(fields(RateMaps))

eval(['BetweenDifferentEnvironmentsData = RateMaps.Session_' num2str(iSession) '.BetweenCompartmentsCorrelations.CorrelationsBetweenDifferentEnvironments ;' ])
eval(['BetweenSameEnvironmentData =  RateMaps.Session_' num2str(iSession) '.BetweenCompartmentsCorrelations.CorrelationsBetweenSameEnvironments ;' ]);

hold on ;
MakeJitterBar(BetweenDifferentEnvironmentsData,iSession-OffSet,CorrelationsBetweenDifferentEnvironmentsColor,0);
;MakeJitterBar(BetweenSameEnvironmentData,iSession+OffSet,CorrelationsBetweenSameEnvironmentsColor,0);
M_Correlations(iSession,1:2) = [ nanmean(BetweenDifferentEnvironmentsData)  nanmean(BetweenSameEnvironmentData) ]; 
%StError_Correlations(iSession,1:2) = [ StError(BetweenDifferentEnvironmentsData)  StError(BetweenSameEnvironmentData) ]; 

hold off;

end
hold on;
line([0 numel(fields(RateMaps))+1],[0 0 ],'LineStyle','--','Color',[0 0 0]);

plot([1 : numel(fields(RateMaps))],[M_Correlations(:,1)],'Color',CorrelationsBetweenDifferentEnvironmentsColor,'LineWidth',2);
plot([1 : numel(fields(RateMaps))],[M_Correlations(:,2)],'Color',CorrelationsBetweenSameEnvironmentsColor,'LineWidth',2);
title('Correlations');
set(gca,'XTick',[1 : numel(fields(RateMaps))],'XLim',[0 numel(fields(RateMaps))+1] );
xlabel('Trials')
ylabel('Corr');

end

