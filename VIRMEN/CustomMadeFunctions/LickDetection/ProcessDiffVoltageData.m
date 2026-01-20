function t =ProcessDiffVoltageData(data)

% data = abs(data);%(size(data(:,1),1)/2+1:end,:));
% if isempty(data)
%     
%     
% end
%data = [data(:,1)-nanmean(data(:,1))  data(:,2)-nanmean(data(:,2))]
%plot(data);
% Values = nanmean(data) ;
% Values = repmat(Values,size(event.Data,1),1);
v = abs(data(:,1)-data(:,2)) ;

t = trapz(v);
%t = repmat(trapz(v),size(event.Data,1),1);
%plot(vr.LickDetection.t );ylim([-20 20]);


end
