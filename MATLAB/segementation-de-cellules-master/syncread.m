function sync = syncread(fileName)

        fileID = fopen(fileName,'r');
        if fileID==-1
            sync = 2;
        else
            sync = fscanf(fileID,'%d') ;
            fclose(fileID);
        end
    
end