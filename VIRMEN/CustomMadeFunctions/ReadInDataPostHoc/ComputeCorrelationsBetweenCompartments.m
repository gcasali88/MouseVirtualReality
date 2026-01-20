function RateMap =ComputeCorrelationsBetweenCompartments(RateMap,VR)

BetweenCompartmentsCorrelations = [];
CorrelationsBetweenDifferentEnvironments=[];
CorrelationsBetweenSameEnvironments=[];
Compartments = fields(RateMap.VR.Compartments);

RateMap.VR.Correlations =[];

for iField = 1 : numel(Compartments)
    for jField = 1 : numel(Compartments)
    eval(['in.x  =    RateMap.VR.Compartments.' Compartments{iField} ';' ]);
    eval(['in.y  =    RateMap.VR.Compartments.' Compartments{jField} ';' ]);
    in.PLOT_ON = 0;
    in.x = in.x(1:min([length(in.x) length(in.y)]));
    in.y = in.y(1:min([length(in.x) length(in.y)]));
    ret = CorrelateXYAndRegression(in);
    RateMap.VR.Correlations(iField , jField) = ret.r; clear in ret;
    if iField == jField  ; RateMap.VR.Correlations(iField , jField) = NaN;end
end
    
end


RateMap.VR.Correlations(find(triu(RateMap.VR.Correlations)==0)) = NaN ;
h = ProduceRM(RateMap.VR.Correlations,[-1 1]);
set(gca,'XTick', [1:numel(Compartments)],'XTickLabel',Compartments, 'YTick', [1:numel(Compartments)],'YTickLabel',Compartments);
title('Pair comparisons');

if numel(Compartments) > 1
Comparisons = nchoosek(1:numel(Compartments),2) ;


WorldNames = {};
for iCompartment = 1 : numel(Compartments);
WorldNames{iCompartment} =  char(Compartments{iCompartment}(1));
end

[~,~,RepeatedWorlds] = unique(WorldNames);

[n] = hist_perc(RepeatedWorlds,1,0.5:numel(WorldNames)+0.5,0);
[~,id] = max(n.z); 

RepeatedWorld = WorldNames(RepeatedWorlds(id))  ;

RepeatedWorldsIndices = (find(strcmp(WorldNames ,RepeatedWorld) )) ; 

tmpCorrelations = RateMap.VR.Correlations;

CorrelationsBetweenSameEnvironments = tmpCorrelations(RepeatedWorldsIndices(1),RepeatedWorldsIndices(2)) ; 

tmpCorrelations(RepeatedWorldsIndices(1),RepeatedWorldsIndices(2)) = NaN;

CorrelationsBetweenDifferentEnvironments = reshape(tmpCorrelations,[],1);
CorrelationsBetweenDifferentEnvironments;
else
  CorrelationsBetweenDifferentEnvironments = NaN;  
  CorrelationsBetweenSameEnvironments = NaN;  
end
% if strcmp(VR.Virmen.vr.Experiment,'Multicompartment')
% CorrelationsBetweenDifferentEnvironments=[CorrelationsBetweenDifferentEnvironments; ...
% nancorr( RateMap.VR.Compartments.A_1(1: min([length(RateMap.VR.Compartments.A_1) length(RateMap.VR.Compartments.B_1)])), RateMap.VR.Compartments.B_1(1: min([length(RateMap.VR.Compartments.A_1) length(RateMap.VR.Compartments.B_1)])) ,'Pearson') ; ...
% 
% nancorr( RateMap.VR.Compartments.A_1(1: min([length(RateMap.VR.Compartments.A_1) length(RateMap.VR.Compartments.B_2)])), RateMap.VR.Compartments.B_2(1: min([length(RateMap.VR.Compartments.A_1) length(RateMap.VR.Compartments.B_2)])) ,'Pearson') ; ...
% 
% nancorr( RateMap.VR.Compartments.A_1(1: min([length(RateMap.VR.Compartments.A_1) length(RateMap.VR.Compartments.C_1)])), RateMap.VR.Compartments.C_1(1: min([length(RateMap.VR.Compartments.A_1) length(RateMap.VR.Compartments.C_1)])) ,'Pearson') ; ...
% 
% nancorr( RateMap.VR.Compartments.B_1(1: min([length(RateMap.VR.Compartments.B_1) length(RateMap.VR.Compartments.C_1)])), RateMap.VR.Compartments.C_1(1: min([length(RateMap.VR.Compartments.B_1) length(RateMap.VR.Compartments.C_1)])) ,'Pearson') ; ...
% 
% nancorr( RateMap.VR.Compartments.B_2(1: min([length(RateMap.VR.Compartments.B_2) length(RateMap.VR.Compartments.C_1)])), RateMap.VR.Compartments.C_1(1: min([length(RateMap.VR.Compartments.B_2) length(RateMap.VR.Compartments.C_1)])) ,'Pearson') ] ;
% 
% CorrelationsBetweenSameEnvironments = nancorr( RateMap.VR.Compartments.B_1(1: min([length(RateMap.VR.Compartments.B_1) length(RateMap.VR.Compartments.B_2)])), RateMap.VR.Compartments.B_2(1: min([length(RateMap.VR.Compartments.B_1) length(RateMap.VR.Compartments.B_2)])) ,'Pearson') ; 
% end



BetweenCompartmentsCorrelations.CorrelationsBetweenDifferentEnvironments = CorrelationsBetweenDifferentEnvironments;
BetweenCompartmentsCorrelations.CorrelationsBetweenSameEnvironments = CorrelationsBetweenSameEnvironments;

RateMap.VR.BetweenCompartmentsCorrelations = BetweenCompartmentsCorrelations;

end




