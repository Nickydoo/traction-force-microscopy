function syncwrite(fileName)

    fileID = -1;
    while fileID == -1
        fileID = fopen(fileName,'r+');
    end
    
    errnum = 1;
    while not(errnum == 0)
        [message,errnum] = ferror(fileID);
    end
    
    fprintf(fileID,'%d',2);
    fclose(fileID);
    
    
end