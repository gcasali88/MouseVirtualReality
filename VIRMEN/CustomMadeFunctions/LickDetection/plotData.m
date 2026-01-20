
function plotData(src,event)
     figure(2);
     plot(event.TimeStamps, event.Data)
     ylim([-13 13]); 
 end