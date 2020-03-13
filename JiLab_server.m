
% Set up server side:
% On the computee that will dispaly the drifting grating images:

t = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');

fopen % this will wait until a connection is recieveed 

for i = 1: 10 % for 10 itterations..
i = 1;
while i == 1;
    if t.BytesAvailable >1;
        a= fread(t, t.BytesAvailable);
        disp([num2str(a(1)+a(2)), '  degrees for ', num2str(a(3)),' seconds']);
        i = 2;
    end
end
pause(a(3)); % pause for the amount of time in the time field (optional)
disp('...done');
end

% close connection
fclose(t);


