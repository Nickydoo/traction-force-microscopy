% Builds an error message for the calling function, describing the exception, and
% adding all the callStack errors. Writes the string to a log file in
% "folder".
function outMessage = reportException(folder, exception)

    % Get name of caller function
    [callStack, ~] = dbstack('-completenames', 1);
    callerFuncName = callStack(1).name;

    % Builds error message for the caller function
    errorString = ['Error in function ' callerFuncName '. Message: ' exception.message];
    
    % Adds the error from the callStack
    errorString = [errorString buildCallStack(exception)];

    % Logs the error and returns message
    outMessage = logit(folder,errorString);

end