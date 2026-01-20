function [v] = plotDataBaground( src,event )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

nSamples = size(event.Data,1);
subplot(2,1,1);
plot(event.TimeStamps,event.Data);
subplot(2,1,2);
V = repmat(nanmean(event.Data(:,1)-event.Data(:,2)),1,nSamples);
plot(event.TimeStamps,V);
ylim([-2 2]);
%v = event.Data(end) ;% - event.Data(end)


end

