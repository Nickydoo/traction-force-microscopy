% Incorporated as part of vesicle tracking software
% Javier Mazzaferri
% Hopital Maisonneuve-Rosemont, Centre de Recherche
% www.biophotonics.ca
% Date[JM]: April 25, 2013 (11:01)
% Version JM: V_01.02.00

% This function computes the parameters of the gyration tensor of a
% trajectory in pTrack

function [R12,R22,RG2,ang,a2,A2] = compute_gyration_tensor(x,y)

msk = ~isnan(x) & ~isnan(y);

x = x(msk);
y = y(msk);

xm  = mean(x);    
x2m = mean(x.*x); 

ym  = mean(y);    
y2m = mean(y.*y); 

xym = mean(x.*y); 

%Tensor elements
Txx = x2m - xm*xm;
Txy = xym - xm*ym;
Tyy = y2m - ym*ym;

aux1 = Txx + Tyy;
aux2 = sqrt((Txx-Tyy)^2 + 4 * Txy^2);

%RESULTS
R12 = (aux1 + aux2) / 2; % long axis

R22 = (aux1 - aux2) / 2; % short axis

RG2 = R12 + R22;

ang = atan(2 * Txy / (Txx-Tyy)) / 2 * 180 / pi;

a2 = R22 / R12;

A2 = (R12 - R22)^2 / (R12 + R22)^2;

end
