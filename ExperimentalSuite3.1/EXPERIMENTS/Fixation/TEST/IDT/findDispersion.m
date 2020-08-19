
% dispersion is defined as the maximum radial distance of any POR from
% the centroid of the set of PORs within the current temporal window
function [dispersion,r, centroid] = findDispersion( X, Y )
    % find centeroid coordinates
    centerX = mean(X);
    centerY = mean(Y);
    % determine distance of each point from centroid
   distance = sqrt((X-centerX).^2 + (Y-centerY).^2);
   r=max(distance);
    distance2 = ((max(X)-min(X))+(max(Y)-min(Y)))/2;
  % dispersion=max((max(X)-min(X))+(max(Y)-min(Y)));
   
    % dispersion radius =  maximum distance of any tuple from the centroid of all tuples within the fixation
    dispersion = max(distance2);
    centroid = [centerX centerY];
end