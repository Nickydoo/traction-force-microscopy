%% Figure 1 - a, b, c - cell count 
% Joannie Roy June 2017 for Article with Brian & Dr Siegel
% I only keep 1ug/ml data

clear, clc, close all, set(0,'DefaultFigureWindowStyle','docked');

%% Path
%resDir = uigetdir('C:\Users\joannie\', 'Select result folder');
resDir = 'C:\Users\joannie\Dropbox (Biophotonics)\NeutroBrianPaper\Figures'; % this is where the figures are saved

%% Data C3a
% see interpretingBrianStill_All_vJune2017. 
% this version is: percent of cells on both side of a well. 

CC_L_1000A  = 100*([188/(188+121) 60/(60+51) 121/(73+121) 77/(77+24) 245/(245+114) 119/(119+47) 174/(174+128) 153/(153+55) 19/(19+25) 449/(449+555) 111/(111+207)]);
CC_L_1000V  = 100*([121/(188+121) 51/(60+51) 73/(73+121) 24/(77+24) 114/(245+114) 47/(119+47) 128/(174+128) 55/(153+55) 25/(19+25) 555/(449+555) 207/(111+207) ]);
CC_H_1000A  = 100*([133/(133+104) 179/(179+154) 61/(61+71) 210/(197+210) 206/(432+206) 69/(69+92) 451/(451+417) 150/(150+102) ]);
CC_H_1000V  = 100*([104/(133+104) 154/(179+154) 71/(61+71) 197/(197+210) 432/(432+206) 92/(69+92) 417/(451+417) 102/(150+102) ]);

mCC_L_1000A = mean(CC_L_1000A);
mCC_L_1000V = mean(CC_L_1000V);
mCC_H_1000A = mean(CC_H_1000A);
mCC_H_1000V = mean(CC_H_1000V);

sCC_L_1000A = std(CC_L_1000A);
sCC_L_1000V = std(CC_L_1000V);
sCC_H_1000A = std(CC_H_1000A);
sCC_H_1000V = std(CC_H_1000V);

tableC3aM  = [mCC_L_1000A; mCC_L_1000V; mCC_H_1000A; mCC_H_1000V];
tableC3aS  = [sCC_L_1000A; sCC_L_1000V; sCC_H_1000A; sCC_H_1000V];

% ttest Cell Count
[h1, p1]   = ttest2(CC_L_1000A, CC_L_1000V);
[h2, p2]   = ttest2(CC_H_1000A, CC_H_1000V);

%% C3a + inhibitor 1uM
CC_L_inh_A  = 100*([99/(99+90) 228/(228+254) 158/(158+77) 18/(18+2) 9/(9+28) 12/(12+9) 19/(19+6) 92/(92+42) 5/(5+5) 64/(135+64) 22/(22+35) 38/(36+38) 72/(72+69)]);
CC_L_inh_V  = 100*([90/(99+90) 254/(228+254) 77/(158+77) 2/(18+2) 28/(9+28) 9/(12+9) 6/(19+6) 42/(92+42) 5/(5+5) 135/(135+64) 35/(35+22) 36/(36+38) 69/(72+69)]);
CC_H_inh_A  = 100*([38/(54+38) 237/(228+237) 234/(234+284) 33/(33+3) 5/(5+25) 77/(77+12) 2/(2+48) 26/(26+18) 17/(17+2) 59/(59+91) 39/(39+43) 50/(50+24)]);
CC_H_inh_V  = 100*([54/(54+38) 228/(228+237) 284/(234+284) 3/(33+3) 25/(5+25) 12/(77+12) 48/(2+48) 18/(26+18) 2/(17+2)  91/(91+59) 43/(39+43) 24/(50+24)]);

mCC_L_inh_A = mean(CC_L_inh_A);
mCC_L_inh_V = mean(CC_L_inh_V);
mCC_H_inh_A = mean(CC_H_inh_A);
mCC_H_inh_V = mean(CC_H_inh_V);

sCC_L_inh_A = std(CC_L_inh_A);
sCC_L_inh_V = std(CC_L_inh_V);
sCC_H_inh_A = std(CC_H_inh_A);
sCC_H_inh_V = std(CC_H_inh_V);

table_inh_M  = [mCC_L_inh_A; mCC_L_inh_V; mCC_H_inh_A; mCC_H_inh_V];
table_inh_S  = [sCC_L_inh_A; sCC_L_inh_V; sCC_H_inh_A; sCC_H_inh_V];

% ttest Cell Count
[h3, p3]   = ttest2(CC_L_inh_V, CC_L_inh_A);
[h4, p4]   = ttest2(CC_H_inh_V, CC_H_inh_A);

%% Cond. Media + inhibitor 1uM
CC_L_inhCM_A  = 100*([54/(54+79) 161/(161+70) 4/(4+45) 40/(40+8) 7/(30+7) 31/(31+84) 78/(78+9) 8/(8+8) 133/(133+30) 28/(28+29) 64/(64+55)]);
CC_L_inhCM_V  = 100*([79/(54+79) 70/(161+70) 45/(4+45) 8/(40+8) 30/(30+7) 84/(31+84) 9/(78+9) 8/(8+8) 30/(133+30) 29/(28+29) 55/(64+55)]);
CC_H_inhCM_A  = 100*([147/(147+115) 234/(234+221) 65/(65+22) 90/(90+14) 7/(7+9) 18/(18+105) 36/(36+14) 111/(111+71) 27/(27+32) 16/(16+29) 27/(27+47)]);
CC_H_inhCM_V  = 100*([115/(147+115) 221/(234+221) 22/(65+22) 14/(90+14) 9/(7+9) 105/(18+105) 14/(36+14) 71/(71+111) 32/(32+27) 29/(16+29) 47/(27+47)]);

mCC_L_inhCM_A = mean(CC_L_inhCM_A);
mCC_L_inhCM_V = mean(CC_L_inhCM_V);
mCC_H_inhCM_A = mean(CC_H_inhCM_A);
mCC_H_inhCM_V = mean(CC_H_inhCM_V);

sCC_L_inhCM_A = std(CC_L_inhCM_A);
sCC_L_inhCM_V = std(CC_L_inhCM_V);
sCC_H_inhCM_A = std(CC_H_inhCM_A);
sCC_H_inhCM_V = std(CC_H_inhCM_V);

table_inhCM_M  = [mCC_L_inhCM_A; mCC_L_inhCM_V; mCC_H_inhCM_A; mCC_H_inhCM_V];
table_inhCM_S  = [sCC_L_inhCM_A; sCC_L_inhCM_V; sCC_H_inhCM_A; sCC_H_inhCM_V];

% ttest Cell Count
[h5, p5]   = ttest2(CC_L_inhCM_V, CC_L_inhCM_A);
[h6, p6]   = ttest2(CC_H_inhCM_V, CC_H_inhCM_A);

%% Peptide

%CC_L_PA   = 100*([43/(43+21) 55/(55+38) 69/(69+51) 54/(54+30) 122/(122+65) 54/(54+27) 174/(174+83) 194/(194+50) 361/(361+384) 331/(331+525)]);
%CC_L_PV  = 100*([21/(43+21) 38/(55+38) 51/(69+51) 30/(54+30) 65/(122+65) 27/(54+27) 83/(174+83) 50/(194+50) 384/(361+384) 525/(331+525)]);

%CC_H_PA   = 100*([5/(11+5) 22/(22+8) 55/(55+32) 38/(38+1) 63/(63+52) 67/(67+54) 42/(42+21) 75/(75+186) 155/(155+142) 568/(568+312) 418/(418+394)]);
%CC_H_PV  = 100*([11/(11+5) 8/(22+8) 32/(55+32) 1/(38+1) 52/(63+52) 54/(67+54) 21/(42+21) 186/(186+75) 142/(155+142) 312/(568+312) 394/(394+418)]);

% excluding 11Oct2017
CC_L_PA   = 100*([43/(43+21) 55/(55+38) 69/(69+51) 54/(54+30) 194/(194+50) 361/(361+384) 331/(331+525)]);
CC_L_PV  = 100*([21/(43+21) 38/(55+38) 51/(69+51) 30/(54+30) 50/(194+50) 384/(361+384) 525/(331+525)]);

CC_H_PA   = 100*([5/(11+5) 22/(22+8) 55/(55+32) 38/(38+1) 63/(63+52) 67/(67+54) 42/(42+21) 568/(568+312) 418/(418+394)]);
CC_H_PV  = 100*([11/(11+5) 8/(22+8) 32/(55+32) 1/(38+1) 52/(63+52) 54/(67+54) 21/(42+21) 312/(568+312) 394/(394+418)]);


mCC_L_PA = mean(CC_L_PA);
mCC_L_PV = mean(CC_L_PV);
mCC_H_PA = mean(CC_H_PA);
mCC_H_PV = mean(CC_H_PV);

sCC_L_PA = std(CC_L_PA);
sCC_L_PV = std(CC_L_PV);
sCC_H_PA = std(CC_H_PA);
sCC_H_PV = std(CC_H_PV);

table_mP  = [mCC_L_PA; mCC_L_PV; mCC_H_PA; mCC_H_PV];
table_sP  = [sCC_L_PA; sCC_L_PV; sCC_H_PA; sCC_H_PV];

% ttest Cell Count
[h7, p7]   = ttest2(CC_L_PA, CC_L_PV);
[h8, p8]   = ttest2(CC_H_PA, CC_H_PV);

%% C.M. Liver

CC_L_liA  = 100*([100/(100+47)  71/(115+71) 178/(178+114) 164/(164+67) 545/(545+530) 395/(395+315) 380/(380+285) 374/(374+212) 517/(517+336) 322/(341+322) 43/(43+1) 48/(79+48) 47/(47+12) 134/(28+134) 279/(279+258) 180/(180+142)]); 
CC_L_liV = 100*([47/(100+47) 115/(115+71) 114/(178+114) 67/(164+67) 530/(545+530) 315/(395+315) 285/(380+285) 212/(374+212) 336/(517+336) 341/(341+322) 1/(43+1) 79/(79+48) 12/(47+12) 28/(134+28) 258/(279+258) 142/(180+142)]);

CC_H_liA  = 100*([22/(22+2) 10/(19+10) 28/(28+6) 20/(50+20) 288/(374+288) 164/(183+164) 134/(134+36) 162/(162+137) 209/(230+209) 260/(260+135) 41/(53+41) 80/(80+75) 42/(57+42) 1/(23+1) 8/(8+8) 25/(25+95) 298/(298+204) 215/(215+397) 133/(133+108) 117/(117+120)]);
CC_H_liV = 100*([2/(22+2) 19/(19+10) 6/(28+6) 50/(50+20) 374/(374+288) 183/(183+164) 36/(134+36) 137/(162+137) 230/(230+209) 135/(260+135) 53/(53+41) 75/(80+75) 57/(57+42) 23/(23+1) 8/(8+8) 95/(25+95) 204/(298+204) 397/(215+397) 108/(133+108) 120/(120+117)]);

mCC_L_liA = mean(CC_L_liA);
mCC_L_liV = mean(CC_L_liV);
mCC_H_liA = mean(CC_H_liA);
mCC_H_liV = mean(CC_H_liV);

sCC_L_liA = std(CC_L_liA);
sCC_L_liV = std(CC_L_liV);
sCC_H_liA = std(CC_H_liA);
sCC_H_liV = std(CC_H_liV);

table_liM  = [mCC_L_liA; mCC_L_liV; mCC_H_liA; mCC_H_liV];
table_liS  = [sCC_L_liA; sCC_L_liV; sCC_H_liA; sCC_H_liV];

% ttest Cell Count
[h9, p9]   = ttest2(CC_L_liA, CC_L_liV);
[h10, p10] = ttest2(CC_H_liA, CC_H_liV);

%% C.M. Lung 

CC_L_luA  = 100*([546/(546+275) 434/(434+180) 52/(86+52) 45/(124+45) ]);
CC_L_luV = 100*([275/(546+275) 180/(434+180) 86/(86+52) 124/(124+45)]); 

CC_H_luA  = 100*([183/(316+183) 94/(297+94) 65/(144+65) 74/(74+37)]);
CC_H_luV = 100*([316/(316+183) 297/(297+94) 144/(144+65) 37/(74+37)]);

mCC_L_luA = mean(CC_L_luA);
mCC_L_luV = mean(CC_L_luV);
mCC_H_luA = mean(CC_H_luA);
mCC_H_luV = mean(CC_H_luV);

sCC_L_luA = std(CC_L_luA);
sCC_L_luV = std(CC_L_luV);
sCC_H_luA = std(CC_H_luA);
sCC_H_luV = std(CC_H_luV);

table_luM  = [mCC_L_luA; mCC_L_luV; mCC_H_luA; mCC_H_luV];
table_luS  = [sCC_L_luA; sCC_L_luV; sCC_H_luA; sCC_H_luV];

% ttest Cell Count
[h11, p11]   = ttest2(CC_L_luA, CC_L_luV);
[h12, p12] = ttest2(CC_H_luA, CC_H_luV);

%% C5a 0.1ug/ml = environ 10nM

CC_L_C5aA   = 100*([75/(75+61) 207/(207+29) 274/(274+201) 245/(245+177) 162/(162+111) 253/(253+137)]);
CC_L_C5aV   = 100*([61/(75+61) 29/(207+29) 201/(274+201) 177/(245+177) 111/(162+111) 137/(253+137)]);

CC_H_C5aA   = 100*([231/(231+18) 146/(146+79) 480/(480+358) 200/(200+50) 173/(173+68) 230/(230+140)]);
CC_H_C5aV   = 100*([18/(231+18) 79/(146+79) 358/(358+480) 50/(200+500) 68/(173+68) 140/(140+230)]);

mCC_L_C5aA = mean(CC_L_C5aA);
mCC_L_C5aV = mean(CC_L_C5aV);
mCC_H_C5aA = mean(CC_H_C5aA);
mCC_H_C5aV = mean(CC_H_C5aV);

sCC_L_C5aA = std(CC_L_C5aA);
sCC_L_C5aV = std(CC_L_C5aV);
sCC_H_C5aA = std(CC_H_C5aA);
sCC_H_C5aV = std(CC_H_C5aV);

table_mC5a  = [mCC_L_C5aA; mCC_L_C5aV; mCC_H_C5aA; mCC_H_C5aV];
table_sC5a  = [sCC_L_C5aA; sCC_L_C5aV; sCC_H_C5aA; sCC_H_C5aV];

% ttest Cell Count
[h13, p13]   = ttest2(CC_L_C5aA, CC_L_C5aV);
[h14, p14]   = ttest2(CC_H_C5aA, CC_H_C5aV);

%% C5a 0.1ug/ml + inh (anti-C3aR)

CC_L_C5aInhA   = 100*([86/(86+96) 45/(45+2) 150/(150+145) 204/(204+56) 59/(59+18) 78/(78+60)]);
CC_L_C5aInhV   = 100*([96/(86+96) 2/(45+2) 145/(150+145) 56/(204+56) 18/(59+18) 60/(78+60)]);
CC_H_C5aInhA   = 100*([232/(232+31) 115/(115+5) 356/(356+97) 113/(113+19) 116/(116+27)]);
CC_H_C5aInhV   = 100*([31/(232+31) 5/(115+5) 97/(356+97) 19/(113+19) 27/(116+27)]);

mCC_L_C5aInhA = mean(CC_L_C5aInhA);
mCC_L_C5aInhV = mean(CC_L_C5aInhV);
mCC_H_C5aInhA = mean(CC_H_C5aInhA);
mCC_H_C5aInhV = mean(CC_H_C5aInhV);

sCC_L_C5aInhA = std(CC_L_C5aInhA);
sCC_L_C5aInhV = std(CC_L_C5aInhV);
sCC_H_C5aInhA = std(CC_H_C5aInhA);
sCC_H_C5aInhV = std(CC_H_C5aInhV);

table_mC5aInh = [mCC_L_C5aInhA; mCC_L_C5aInhV; mCC_H_C5aInhA; mCC_H_C5aInhV];
table_sC5aInh  = [sCC_L_C5aInhA; sCC_L_C5aInhV; sCC_H_C5aInhA; sCC_H_C5aInhV];

% ttest Cell Count
[h15, p15]   = ttest2(CC_L_C5aInhA, CC_L_C5aInhV);
[h16, p16]   = ttest2(CC_H_C5aInhA, CC_H_C5aInhV);

%% Figure C3a LDNs
%couleur = [1 0 0; 250/255 128/255 114/255; 0 0 1; 65/255 105/255 225/255]; % red, salmon, blue, royal blue

figure(1),
y = [tableC3aM(1), tableC3aM(2);...
    table_inh_M(1),table_inh_M(2);...
    table_liM(1), table_liM(2);...
    table_inhCM_M(1), table_inhCM_M(2);...
    table_mC5a(1), table_mC5a(2);...
    table_mC5aInh(1), table_mC5aInh(2)];
% std
errY = [std(CC_L_1000A)/sqrt(length(CC_L_1000A)),std(CC_L_1000V)/sqrt(length(CC_L_1000V));...
    std(CC_L_inh_A)/sqrt(length(CC_L_inh_A)),std(CC_L_inh_V)/sqrt(length(CC_L_inh_V));...
    std(CC_L_liA)/sqrt(length(CC_L_liA)),std(CC_L_liV)/sqrt(length(CC_L_liV));...
    std(CC_L_inhCM_A)/sqrt(length(CC_L_inhCM_A)),std(CC_L_inhCM_V)/sqrt(length(CC_L_inhCM_V));...
    std(CC_L_C5aA)/sqrt(length(CC_L_C5aA)),std(CC_L_C5aV)/sqrt(length(CC_L_C5aV));...
    std(CC_L_C5aInhA)/sqrt(length(CC_L_C5aInhA)),std(CC_L_C5aInhV)/sqrt(length(CC_L_C5aInhV))];
h = barwitherr(errY, y);% Plot with errorbars

%set(gca,'XTickLabel',{'C3a', 'C3a + inh.', 'C.M. + inh.'})
set(gca,'XTickLabel',{'C3a', 'C3a + inh.', 'M.C.','M.C. + inh.', 'C5a', 'C5a + +inh.'})
set(gca,'XTickLabelRotation',45)
%legend('Agonist','Vehicle')
legend('Agoniste','Véhicule')
%ylabel('Cell Out (%)')
ylabel('Cellules (%)')
set(h(1),'FaceColor','r');
%set(h(2),'FaceColor','w');
%set(h(2),'FaceColor',[250/255 128/255 114/255]); % salmon
set(h(2),'FaceColor',[255/255 165/255 0/255]); % orange

ax = gca;
ax.YLim = [0 90];
ax.YTickMode = 'manual';
ax.YTick = [0 25 50 75 100];
ax.FontSize = 14;

%hold on, plot(tableC3aM(1:6,:)) %this allows to place the stars for significance. 
hold on, plot([tableC3aM(1), tableC3aM(2), table_inh_M(1), table_inh_M(2), table_liM(1),table_liM(2), table_inhCM_M(1), table_inhCM_M(2), table_mC5a(1), table_mC5a(2), table_mC5aInh(1), table_mC5aInh(2)]);
H = sigstar({[1,2],[3,4],[5,6],[7,8],[9,10],[11,12]},[p1,p3,p9,p5,p13,p15]);  
axis square

% to do manually: remove the plot and move the brackets and stars. and font
% xdata = [0.75 0.75 1.25 1.25; 1.75 1.75 2.25 2.25; 2.75 2.75 3.25 3.25] %
% ydata = [71 72 72 71]
% stars = [1,71] [2,72] [3,71] font Helvetica 14 to check
print([resDir filesep 'LDN_C3a_v3'],'-dtiff','-r0') 
saveas(gcf, [resDir filesep 'LDN_C3a_v3'  '.fig'])
print([resDir filesep 'LDN_C3a_v3F'],'-dtiff','-r0') 
saveas(gcf, [resDir filesep 'LDN_C3a_v3F'  '.fig'])

%% Figure C3a HDNs
%couleur = [1 0 0; 250/255 128/255 114/255; 0 0 1; 65/255 105/255 225/255]; % red, salmon, blue, royal blue

figure(2),
y = [tableC3aM(3),tableC3aM(4);...
    table_inh_M(3),table_inh_M(4);...
    table_liM(3), table_liM(4);...
    table_inhCM_M(3), table_inhCM_M(4);...
    table_mC5a(3), table_mC5a(4);...
    table_mC5aInh(3), table_mC5aInh(4)];
% std
errY = [std(CC_H_1000A)/sqrt(length(CC_H_1000A)),std(CC_H_1000V)/sqrt(length(CC_H_1000V));...
    std(CC_H_inh_A)/sqrt(length(CC_H_inh_A)),std(CC_H_inh_V)/sqrt(length(CC_H_inh_V));...
    std(CC_H_liA)/sqrt(length(CC_H_liA)),std(CC_H_liV)/sqrt(length(CC_H_liV));...
    std(CC_H_inhCM_A)/sqrt(length(CC_H_inhCM_A)),std(CC_H_inhCM_V)/sqrt(length(CC_H_inhCM_V)); ...
    std(CC_H_C5aA)/sqrt(length(CC_H_C5aA)),std(CC_H_C5aV)/sqrt(length(CC_H_C5aV));...
    std(CC_H_C5aInhA)/sqrt(length(CC_H_C5aInhA)),std(CC_H_C5aInhV)/sqrt(length(CC_H_C5aInhV))];
   
h = barwitherr(errY, y);% Plot with errorbars

set(gca,'XTickLabel',{'C3a', 'C3a + inh.', 'C.M.','C.M. + inh.', 'C5a', 'C5a + +inh.'})
%set(gca,'XTickLabel',{'C3a', 'C3a + inh.', 'M.C.','M.C. + inh.', 'C5a', 'C5a + +inh.'})
set(gca,'XTickLabelRotation',45)
legend('Agonist','Vehicle')
%legend('Agoniste','Véhicule')
ylabel('Cell Out (%)')
%ylabel('Cellules (%)')
set(h(1),'FaceColor','b');
%set(h(2),'FaceColor','w');
set(h(2),'FaceColor',[0/255 191/255 255/255]); %deep sky blue

ax = gca;
ax.YLim = [0 90];
ax.YTickMode = 'manual';
ax.YTick = [0 25 50 75 100];
ax.FontSize = 14;

%hold on, plot(tableC3aM(7:12,:)) %this allows to place the stars for significance. 
hold on, plot([tableC3aM(3), tableC3aM(4), table_inh_M(3), table_inh_M(4), table_liM(3),table_liM(4), table_inhCM_M(3), table_inhCM_M(4), table_mC5a(3), table_mC5a(4), table_mC5aInh(3), table_mC5aInh(4)]);

H = sigstar({[1,2],[3,4],[5,6],[7,8],[9,10],[11,12]},[p2,p4,p10,p6,p14,p16]);  
axis square

% to do manually: remove the plot and move the brackets and stars. and font
% xdata = [0.75 0.75 1.25 1.25; 1.75 1.75 2.25 2.25; 2.75 2.75 3.25 3.25] %
% ydata = [77 78 78 77]
% stars = [1,71] [2,72] [3,71] font Helvetica 14
% print([resDir filesep 'LDN_PercentOut'],'-dtiff','-r0') 
%saveas(gcf, [resDir filesep 'HDN_C3a_v3'  '.fig'])
%print([resDir filesep 'HDN_C3a_v3'],'-dtiff','-r0') 
%saveas(gcf, [resDir filesep 'HDN_C3a_v3F'  '.fig'])
%print([resDir filesep 'HDN_C3a_v3F'],'-dtiff','-r0')   

%% Figure 1c ratio Agonist/Vehicle

% a = CC_L_li./CC_L_liA;
% b = CC_H_li./CC_H_liA;
% c = CC_L_lu./CC_H_luA;
% d = CC_H_lu./CC_H_luA;
% e = CC_L_P./CC_L_PA;
% f = CC_H_P./CC_H_PA;
% 
% figure(3),
% y = [mean(a), mean(b); mean(c), mean(d); mean(e), mean(f)]; 
% errY = [std(a)/sqrt(length(a)), std(b)/sqrt(length(b)); std(c)/sqrt(length(c)), std(d)/sqrt(length(d)); std(e)/sqrt(length(e)), std(f)/sqrt(length(f))];
% h = barwitherr(errY, y);% Plot with errorbars
% 
% % ttest Cell Count
% [h7, p7] = ttest2(a,b); % n = 13
% [h8, p8] = ttest2(c,d); % n =  4
% [h9, p9] = ttest2(e,f); % n =  4
% 
% hold on, plot([mean(a), mean(b), mean(c), mean(d), mean(e), mean(f)]); %this allows to place the stars for significance. 
% H = sigstar({[1,2],[3,4],[5,6]},[p7,p8,p9]);  
% 
% set(gca,'XTickLabel',{'Liver C.M.','Lung C.M.','WKYMVm'})
% %set(gca,'XTickLabel',{'Foie M.C.','Poumon M.C,','WKYMVm'})
% set(gca,'XTickLabelRotation',45)
% legend('LDNs','HDNs')
% ylabel('Ratio Agonist/Vehicle')
% %ylabel('Ratio Agoniste/Véhicule')
% set(h(1),'FaceColor','r');
% set(h(2),'FaceColor','b');
% 
% ax = gca;
% ax.YLim = [0 13];
% ax.YTickMode = 'manual';
% ax.YTick = [0 2 4 6 8 10 12];
% ax.FontSize = 14;
% 
% axis square
% % to do manually: remove the plot and move the brackets and stars. and font
% % xdata = [0.75 0.75 1.25 1.25; 1.75 1.75 2.25 2.25; 2.75 2.75 3.25 3.25] %
% % ydata = [8.1 8.2 8.2 8.1 12.1 12.2 12.2 12.1]
% % stars = [1,8.6] [2,8.6] [3,12.6] font Helvetica 14
% %  print([resDir filesep 'ratio'],'-dtiff','-r0') 
% %  saveas(gcf, [resDir filesep 'ratio'  '.fig'])
% %  print([resDir filesep 'ratioF'],'-dtiff','-r0') 
% %  saveas(gcf, [resDir filesep 'ratioF'  '.fig'])
% 
% %% table ratio
% 
% tableRatio = nan(6,15);
% tableRatio(1,1:(size(a,2))) = a;
% tableRatio(2,1:(size(b,2))) = b;
% tableRatio(3,1:(size(c,2))) = c;
% tableRatio(4,1:(size(d,2))) = d;
% tableRatio(5,1:(size(e,2))) = e;
% tableRatio(6,1:(size(f,2))) = f;
% tableRatio = tableRatio';
% moyenne = nanmean(tableRatio);
% mediane = nanmedian(tableRatio);
% 
% %% table raw LDNs
% cc_L_li  = ([100 71 178 164 545 395 380 374 517 322 43 48 47]); 
% cc_L_liA = ([47 115 114 67 530 315 285 212 336 341 1 79 12]);
% cc_L_lu  = ([546 434 52 45 ]);
% cc_L_luA = ([275 180 86 124]); 
% cc_L_P   = ([43 55 69 54]);
% cc_L_PA  = ([21 38 51 30]);
% 
% tableCountLDNs = nan(15,6);
% tableCountLDNs(1:(size(cc_L_li,2)),1) = cc_L_li;
% tableCountLDNs(1:(size(cc_L_liA,2)),2) = cc_L_liA;
% tableCountLDNs(1:(size(cc_L_lu,2)),3) = cc_L_lu;
% tableCountLDNs(1:(size(cc_L_luA,2)),4) = cc_L_luA;
% tableCountLDNs(1:(size(cc_L_P,2)),5) = cc_L_P;
% tableCountLDNs(1:(size(cc_L_PA,2)),6) = cc_L_PA;
% moyenneLDNs = nanmean(tableCountLDNs);
% medianeLDNs = nanmedian(tableCountLDNs);
% [h, p] = ttest2(tableCountLDNs(:,1),tableCountLDNs(:,2)); 
% 
% %% table raw HDNs
% cc_H_li  = ([22 10 28 20 288 164 134 162 209 260 41 80 42 1 8]);
% cc_H_liA = ([2 19 6 50 374 183 36 137 230 135 53 75 57 23 8]);
% cc_H_lu  = ([183 94 65 74]);
% cc_H_luA = ([316 297 144 37]);
% cc_H_P   = ([5 22 55 38 63 67 42]);
% cc_H_PA  = ([11 8 32 1 52 54 21]);
% 
% tableCountHDNs = nan(15,6);
% tableCountHDNs(1:(size(cc_H_li,2)),1)  = cc_H_li;
% tableCountHDNs(1:(size(cc_H_liA,2)),2) = cc_H_liA;
% tableCountHDNs(1:(size(cc_H_lu,2)),3)  = cc_H_lu;
% tableCountHDNs(1:(size(cc_H_luA,2)),4) = cc_H_luA;
% tableCountHDNs(1:(size(cc_H_P,2)),5)   = cc_H_P;
% tableCountHDNs(1:(size(cc_H_PA,2)),6)  = cc_H_PA;
% moyenneHDNs = nanmean(tableCountHDNs);
% medianeHDNs = nanmedian(tableCountHDNs);

