clear all

np = 512; % pixel resolution
fr = 15; % frame rate hz
nf = 10000; % number of frames
fname = 'E:\Kevin\20200226\test1_039\Image_001_001.raw';
fileID = -1;
% continue waiting for file to be created
while fileID < 0
    fileID = fopen(fname,'r','l');
    pause(0.1)
end
t = 0;
h = animatedline;
%axis([0,100,0,1])

% timing counters...
tStart = tic;
cursorTic = tic;
trigger_time = tic;

i = 0;
counter = 1;
out_pixel2 = [];
while toc(tStart) < 10000
    if toc(cursorTic) > 1/fr
        cursorTic = tic;
        fseek(fileID,2*np*np*(i),'bof');
        data = fread(fileID,np*np*5,'uint16');
        data = reshape(data,[np np 5]);
        means = squeeze(mean(data(1,:,:)));
        out = find(means==0,1);
        if out == 1
        else
            
            out_pixel =  mean(data(:,:,out-1),'all');
            
            addpoints(h,i,out_pixel);
            drawnow
            
            % trigger things:
            
            % running zscore of data
            
            out_pixel2 = cat(1,out_pixel2, out_pixel);
            out_pixel_z = zscore(out_pixel2);
            val = out_pixel_z(end);
            if val>2.5 %&& toc(trigger_time)>0.2
                t = t+1;
                disp(['TRIGGER' num2str(t)]);
%                 fdbk = 1;
%                 while fbdk
%                     fprint( arduino, '%c',char(99));
%                     fbdk = 0;
%                 end
             %   trigger_time = tic; % debounce
            end
            
            
        end
        i = i+(out-1);
        if out ~= 2
            disp(['whoops! out = ' num2str(out) ', i = ' num2str(i)]);
        end
        isave(counter) = i;
        counter = counter+1;
        if counter>30;
            if sum(diff(isave(end-20:end)))<1
                disp('end detected');
                break
            end
        end
        
    end
end
close all