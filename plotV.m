function plotV(data)

persistent pax
if isempty(pax) || ~isvalid(pax)
    pax = polaraxes(figure(1));
end

[~,n] = size(data);
for i = 1:n
    gca = pax;
    polarplot(data(2,i)+pi/2,data(1,i),'.',MarkerSize=40);
    hold on;
end
hold off;

rlim(pax,[0 3]);
thetaticks(0:45:315);
thetaticklabels({'ES','NE','NO','NW','WE','SW','SO','SE'});