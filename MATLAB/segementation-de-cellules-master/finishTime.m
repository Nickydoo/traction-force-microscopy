finished=false;

% finishHour = 11;
% finishMinutes = 45;
%finishHour=inputdlg('Enter the HOUR at which tracking should start', 'finishHour', 25);
%finishMinutes=inputdlg('Enter the MINUTES at which tracking should start', 'finishMinutes', 61);

prompt = {'Enter the HOUR at which tracking should start:','Enter the MINUTES at which tracking should start:'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'7','00'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
finishHour    = str2num(answer{1,1});
finishMinutes = str2num(answer{2,1});

cnt = 1;

while ~finished

if hour(datetime) == finishHour
   if minute(datetime) >= finishMinutes
        finished = true;
    end
end

cnt = cnt+1

end
