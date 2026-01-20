function vr = SignalEventGreaterThanThreshold(src, event,vr)
%a = fir1(10,[0.007 0.013],'stop')
%y2 = filter(a,1,event.Data(:,1))
data =(event.Data);
data = data - repmat(nanmean(data),size(data,1),1);
Flag=0;
if Flag==1;
subplot(2,2,1);
plot(data);
%subplot(2,3,2);data = sgolayfilt(data,2,);plot(data)
subplot(2,2,2);
data = abs(data);plot(data);
subplot(2,2,3);
Values = nanmean(data) ;
Values = repmat(Values,size(event.Data,1),1);
v = Values(:,1)-Values(:,2);
plot(v);ylim([-0.1 0.1]);

subplot(2,2,4);
vr.LickDetection.t = repmat(trapz(v),size(event.Data,1),1);
plot(vr.LickDetection.t );ylim([-20 20]);
% subtraction = event.Data(:,1)-event.Data(:,2);
% v = trapz(subtraction) ;
% v =repmat(v,1,size(event.Data,1)) ;
% plot(v);ylim([-2 2]);
end
% if trapz(t(1) )> vr.LickDetection.Threshold 
 %[vr] = SaveLickDetection(vr);
% end
end
