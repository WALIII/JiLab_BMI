function JiLab_TriggerTest(arduino, num2test);


for i = 1:num2test
    % send LED serial command
    % Write cursor state to Speaker
    fdbk = 1;
while fdbk
        pause();
disp('press any key to trigger');

    fprintf(arduino,'%c',char(99)); % send answer variable content to arduino
fdbk = 0;
end
end



