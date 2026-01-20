

%% Test if interpolation works better from an initial normal distribution or log normal one.
clf;
mu = 1;
sigma = 0.4;
NData = 100000;

%% Normal distribution....
pd = makedist('normal','mu',mu,'sigma',sigma);
NDecimals = -3;
%subplot(1,2,1);
ts1 = linspace(0,1,NData) ; 
OriginalData = random(pd,[1 NData]);
%scatter(ts1,OriginalData,'r','filled');xlim([0 .00010]);
ts2 = linspace(0,1,NData*100) ; 
F = griddedInterpolant(ts1,OriginalData,'pchip');
InterpolatedDataNormal = F(ts2);
%hold on ;
%plot(ts2,InterpolatedData,'k')
%axis square;
subplot(2,2,1);histogram(exp(InterpolatedDataNormal));axis square;xlim([0 20])
title(['Interpolated = ' num2str(roundn(mean(exp(InterpolatedDataNormal)),NDecimals))  ' +/- ' num2str(roundn(nanstd(exp(InterpolatedDataNormal)),NDecimals))  ])
subplot(2,2,2);histogram((InterpolatedDataNormal));axis square;xlim([-1 3])
title(['Interpolated = ' num2str(roundn(mean(InterpolatedDataNormal),NDecimals))  ' +/- ' num2str(roundn(nanstd(InterpolatedDataNormal),NDecimals))  ])

%% Lognormal distribution...
pd = makedist('lognormal','mu',mu,'sigma',sigma);
%subplot(1,2,1);
ts1 = linspace(0,1,NData) ; 
OriginalData = random(pd,[1 NData]);
%scatter(ts1,OriginalData,'r','filled');xlim([0 .0010]);

ts2 = linspace(0,1,NData*100) ; 
F = griddedInterpolant(ts1,OriginalData,'pchip');
InterpolatedDataLogNormal = F(ts2);
%hold on ;
%%plot(ts2,InterpolatedData,'k');
%axis square;
%clc;
subplot(2,2,3);histogram((InterpolatedDataLogNormal));axis square;xlim([0 20])
title(['Interpolated = ' num2str(roundn(mean((InterpolatedDataLogNormal)),NDecimals))  ' +/- ' num2str(roundn(nanstd((InterpolatedDataLogNormal)),NDecimals))  ])

subplot(2,2,4);histogram(log(InterpolatedDataLogNormal));axis square;xlim([-1 3])
title(['Interpolated = ' num2str(roundn(mean(log(InterpolatedDataLogNormal)),NDecimals))  ' +/- ' num2str(roundn(nanstd(log(InterpolatedDataLogNormal)),NDecimals))  ])



