% Set up client side:
% On the thorlabs computer ( sending data)


t = tcpip('10.142.12.30',30000,'NetworkRole','client');

fopen(t); 

% Send data:
data(1) = 50; data(2) = 0; data(3) = 1; fwrite(t,data)

% close connection
fclose((t);
