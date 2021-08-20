% Analysing Loic images

%% Initialisation

clear
clc
close all
set(0,'DefaultFigureWindowStyle','docked');
%% Path

inputFolder = uigetdir('D:\work\loic\joannies cancer\');
outputFolder = [inputFolder filesep 'Analyis\'];
mkdir(outputFolder)

%% Loading files
% manually load and change table names.
%load(fullfile([inputFolder filesep 'Images8bit\'],['dataImage' filesList(it).name '.mat']), 'table'); 
table_L = table;
table_M = table;
table_S = table;


%% ttest

[h1, p1]   = ttest2(table_S.Area, table_M.Area);
[h2, p2]   = ttest2(table_S.Area, table_L.Area);
[h3, p3]   = ttest2(table_M.Area, table_L.Area);

%% Figures histo

figure(), histogram(table_S.Area,10)
figure(), histogram(table_M.Area,10)
figure(), histogram(table_L.Area,10)

%% Old Matlab

figure(), hist(table_S.Area,10)
figure(), hist(table_M.Area,10)
figure(), hist(table_L.Area,10)

%% Selected cells. 
select_S = table_S.Area(table_S.Area <= prctile(table_S.Area,33));
select_M = table_M.Area(table_M.Area >= prctile(table_M.Area,34) & table_M.Area <= prctile(table_M.Area,66));
select_L = table_L.Area(table_L.Area >= prctile(table_L.Area,67));
%select_Lcentro = table

%% ttest selected cells

[h4, p4]   = ttest2(select_S, select_M);
[h5, p5]   = ttest2(select_S, select_L);
[h6, p6]   = ttest2(select_M, select_L);

[h7, p7]   = ttest2(select_S, table_S.Area);
[h8, p8]   = ttest2(select_M, table_M.Area);
[h9, p9]   = ttest2(select_L, table_L.Area);

%% Old Matlab selected cells

figure(), hist(select_S,10)
figure(), hist(select_M,10)
figure(), hist(select_L,10)
