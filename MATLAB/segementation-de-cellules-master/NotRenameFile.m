function outName = NotRenameFile(inName)

%     position = regexp(inName,'(?<=N)([0-9]?)(?=T)','match');
%     myTime   = regexp(inName,'(?<=T)([0-9]+?)(?=\.)','match');
%     
%     if isempty(position) || isempty(myTime)
%         error('Unable to extract position and time from Metamorph file name')
%     end
    
    outName = inName;

end
