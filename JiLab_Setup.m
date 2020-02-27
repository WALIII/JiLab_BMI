function arduino = JiLab_Setup
% initial script to connect to arduino and .raw files


% conncet to Arduino Through Serial
arduino=serial('/dev/cu.usbmodem14201','BaudRate',9600); % create serial communication object on port COM4
fopen(arduino); % initiate arduino communication
