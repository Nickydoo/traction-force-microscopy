%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPARE TRACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1) looks for every track you are looking for
% 2) puts all info (name, date, passage, etc) in a structure by
% caracteristic
% 3) does a violin plot!!

clear all; close all; clc

%%
workingOnMachineLearning = true;
workingOnPersonalComputer = false;
% samples = {'3','3.1','3.1c','3.1.1'};
% date = {'20190930'};
% samples = {'3.1','3.1c','3.2','3.2c'};
% date = {'20190920'};
% samples = {'3','3.2','3.2c'};
% date = {'20191002'};
%date = {'20190930','20190807'};
% samples = {'1.2','1.2-TGFb','3','3-TGFb'};
% date = {'20191002'};
% samples = {'3','3.1c','3.2c','3.1.1','3.1','3.2','3-TGFb'};
% samples = {'3.1','3.2','3.1.1'};
% date = {};
samples = {'3','3.1','3.1-TGFb','3.2','3.2-TGFb','3-TGFb'};
% date = {'20191013'};
% samples = {'3','3.1','3.2','3.1c','3.2c'};
% samples = {'3','3-TGFb'};
date = {'20191013'};


if workingOnMachineLearning
    mainFolder = 'P:\Desktop\Dropbox (Biophotonics)\Backup Axotom';
elseif workingOnPersonalComputer
    mainFolder = 'C:\Users\Nicolas\Dropbox (Biophotonics)\Backup Axotom';
end

folders = findFoldersWithTheseSamples(mainFolder,samples,date);

[categories,dmax,velNorm,velocidad] = createStructures2violinplot(folders,samples);

uniqueCat = unique(categories);

%%
%gaussienne sur toute la population
GMMtot = fitgmdist([log10(dmax) log10(velocidad)],1);

figure
h = gscatter(log10(dmax),log10(velocidad),categories);
g = gca;
% hold on
% gmPDF = @(x1,x2)reshape(pdf(GMMtot,[x1(:) x2(:)]),size(x1));
% fcontour(gmPDF,[g.XLim g.YLim])
% title('{\bf Scatter Plot and Fitted Gaussian Mixture Contours}')
% hold off
coeff = pca([(dmax) (velocidad)]);
coeffLog = pca([log10(dmax) log10(velocidad)]);

partiePrincipaleLog = [log10(dmax) log10(velocidad)]*coeffLog(:,1);
partiePrincipale = [(dmax) (velocidad)]*coeff(:,1);
%% gaussienne :)
%x = -2:0.01:3;
x = 0:0.1:160;
for idx = 1:numel(uniqueCat)
    pos = strcmp(categories,uniqueCat{idx});
    test = [log10(dmax(pos)) log10(velocidad(pos))];
%     [PDF, xPDF] = ksdensity(test);
    k = 1;
%     f = fit(xPDF',PDF','gauss2');
%     p = fitdist(test,'poisson');
%     logNorm = fitdist(test,'lognormal');
%     logmu(idx) = logNorm.mu;
%     lambda(idx) = p.lambda;
%     stdP(idx) = p.std;
    gm2dist = fitgmdist(test,k);
    whatCluster{idx} = cluster(gm2dist,test);

    for ik = 1:k
        clusters{k*idx-(k-ik)} = test(whatCluster{idx}==ik);
        nCluster(k*idx-(k-ik)) = sum(whatCluster{idx}==ik);
    end
% 
%     a(idx,:) = [f.a1 f.a2]; %amp
%     b(idx,:) = [f.b1 f.b2]; %mu
%     c(idx,:) = [f.c1 f.c2]; %sqrt(2) sigma
    muGmDist{idx} = gm2dist.mu;
    sigmaGmDist{idx} = squeeze([gm2dist.Sigma]);
    
    muDmax(idx) = mean(dmax(pos),'omitnan');
    muVelocidad(idx) = mean(velocidad(pos),'omitnan');
    muPartieP(idx) = mean(partiePrincipale(pos),'omitnan');
    stdDmax(idx) = std(dmax(pos),'omitnan');
    stdVelocidad(idx) = std(velocidad(pos),'omitnan');
    stdPartieP(idx) = std(partiePrincipale(pos),'omitnan');
    
    muDmaxLog(idx) = mean(log10(dmax(pos)),'omitnan');
    muVelocidadLog(idx) = mean(log10(velocidad(pos)),'omitnan');
    muPartiePLog(idx) = mean(partiePrincipaleLog(pos),'omitnan');
    stdDmaxLog(idx) = std(log10(dmax(pos)),'omitnan');
    stdVelocidadLog(idx) = std(log10(velocidad(pos)),'omitnan');
    stdPartiePLog(idx) = std(partiePrincipaleLog(pos),'omitnan');
    
    pertdmax(idx,:) = prctile(dmax(pos),0:100);
    pertspeed(idx,:) = prctile(velocidad(pos),0:100);
  
    mu{idx} = [mean(dmax(pos),'omitnan') mean(velocidad(pos),'omitnan')];
    sigma{idx} = [std(dmax(pos),'omitnan') std(velocidad(pos),'omitnan')];
% figure
% plot(x,f.a1*exp(-((x-f.b1)/f.c1).^2) + f.a2*exp(-((x-f.b2)/f.c2).^2))
% hold on;plot(x,exp(-(x-gm.mu(1)).^2/(2*gm.Sigma(1)^2))+exp(-(x-gm.mu(2)).^2/(2*gm.Sigma(2)^2)))
% title(num2str(idx))
% figure(99)
% hold on
% gmPDF = @(x1,x2)reshape(pdf(gm2dist,[x1(:) x2(:)]),size(x1));
% fcontour(gmPDF,[g.XLim g.YLim])
% hold on
% plot(log10(dmax(pos)),log10(velocidad(pos)),'.')
% title(uniqueCat{idx})
% xlabel('log10(dmax)')
% ylabel('log10(vel)')
end

%%
varNames = {'Sample','mean_dmax','std_dmax','mean_vel','std_vel','mean_PP','std_PP','mean_dmaxLog','std_dmaxLog','mean_velLog','std_velLog','mean_PPLog','std_PPLog'};
resultsRegister = table(uniqueCat,muDmax',stdDmax',muVelocidad',stdVelocidad',muPartieP',stdPartieP',muDmaxLog',stdDmaxLog',muVelocidadLog',stdVelocidadLog',muPartiePLog',stdPartiePLog','variablenames',varNames);

%% Figures
figure
violinplot(log10(dmax),categories)
ylabel('log10(dmax)')

figure
violinplot(log10(velocidad),categories)
ylabel('velocidad')

figure
violinplot([log10(dmax) log10(velocidad)]*coeffLog(:,1),categories)
ylabel('partie principale 1')

figure
violinplot([log10(dmax) log10(velocidad)]*coeffLog(:,2),categories)
ylabel('partie principale 2')

figure
hold on
plot(muDmax,muVelocidad,'.')
% errorbar(muDmax,muVelocidad,stdVelocidad)
% errorbar(muDmax,muVelocidad,stdDmax,'horizontal')
text(muDmax,muVelocidad,uniqueCat)
xlabel('mean(dmax)')
ylabel('mean(vel)')

figure
hold on
plot(muDmaxLog,muVelocidadLog,'.')
% errorbar(muDmaxLog,muVelocidadLog,stdVelocidadLog)
% errorbar(muDmaxLog,muVelocidadLog,stdDmaxLog,'horizontal')
text(muDmaxLog,muVelocidadLog,uniqueCat)
xlabel('mean(log10(dmax))')
ylabel('mean(log10(vel))')


