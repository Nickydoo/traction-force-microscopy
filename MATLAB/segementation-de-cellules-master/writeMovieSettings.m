function writeMovieSettings(folder)

fileID = fopen(fullfile(folder,'movieSettings.m'),'w');
fprintf(fileID,'%s movie settings \n','%');

dims = [1 35];
nsamples = inputdlg({'number of samples'},'number of samples',dims,{'1'});
nsamples = str2num(nsamples{:});

for idx = 1:nsamples
    %inputs 
    prompt = {'settings(x).sampleName';... %1
        'settings(x).thisIsForControle';... %2
        'settings(x).captureFastCells';... %3
        'settings(x).pSpeed';... %4
        'settings(x).pSpeed';... %5
        'settings(x).nSorting'}; %6
    dlgtitle = ['x = ' num2str(idx)] ;
    definput = {'sample name',...
        'false',...
        'true',...
        '95',...
        '5',...
        '0'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    
    %write to a function
    fprintf(fileID,'\n settings(%d).sampleName = ''%s''; \n',idx,answer{1});
    fprintf(fileID,'settings(%d).date = ''%s''; \n',idx,datestr(date,'yyyymmdd'));
    fprintf(fileID,'settings(%d).thisIsForControle = %s; %s\n',idx,answer{2},'%captures all the cells');
    fprintf(fileID,'settings(%d).captureFastCells = %s; \n',idx,answer{3});
    fprintf(fileID,'if settings(%d).captureFastCells; \n',idx);
    fprintf(fileID,'    settings(%d).pSpeed = %s; %s\n',idx,answer{4},'%5 for slow, 95 for fast');
    fprintf(fileID,'else \n')
    fprintf(fileID,'    settings(%d).pSpeed = %s; %s\n',idx,answer{5},'%5 for slow, 95 for fast');
    fprintf(fileID,'end \n')
    fprintf(fileID,'settings(%d).nSorting  = %s; %s\n',idx,answer{4},'%-1 = controle    0 = parental    1,2,3,4=n tri');
    
end

fclose(fileID);