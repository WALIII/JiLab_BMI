function JiLab_Main(arduino,fname)
% JiLab_Main.m

% Main function for delegating BMI scripts


np = 512; % pixel resolution
fr = 15; % frame rate hz
nf = 10000; % number of frames
fileID = -1;
max_time = 10000;

% continue waiting for file to be created
while fileID < 0
    fileID = fopen(fname,'r','l');
    pause(0.1)
end
t = 0;
h = animatedline;

% timing counters...
tStart = tic;
cursorTic = tic;
trigger_time = tic;

i = 0;
counter = 1;
out_pixel2 = [];
while toc(tStart) < max_time;
    if toc(cursorTic) > 1/fr
        cursorTic = tic;
        fseek(fileID,2*np*np*(i),'bof');
        data = fread(fileID,np*np*5,'uint16');
        data = reshape(data,[np np 5]);
        means = squeeze(mean(data(1,:,:)));
        out = find(means==0,1);
        if out == 1
        else

% ============================= [ BMI SECTION]  ============================= %
            % Main BMI function:
            data.toc(counter) = toc(tStart); % how often are we waiting per frame. For timeing rconstruction
            [CURSOR, data] = JiLab_Cursor(data(:,:,out-1),ROI,data,counter)

% ============================= [ Water Delivery]  ============================= %

             data.hit(counter) =0; % hit counter
            if condition == 1; % reward eligibility
            if data.cursor(:,1)> 2.5
                Cursor_A = 999;
                disp('HIT')
                condition = 2;
                data.hit(counter) =1;
            end
            elseif condition == 2
              disp(' Waiting to drop below threshold...')
              data.hit(counter) =-1;
              if data.cursor(:,1)<1
                disp ( 'Resetting Cursor')
                condition = 1;
              end
            end

% ============================= [ Arduino Communication]  ============================= %


%             out_pixel =  mean(data(:,:,out-1),'all');
%
% %             addpoints(h,i,out_pixel);
% %             drawnow
%
%             % trigger things:
%
%             % running zscore of data
%
%             out_pixel2 = cat(1,out_pixel2, out_pixel);
%             out_pixel_z = zscore(out_pixel2);
%             val = out_pixel_z(end);
%             if val>2.5 %&& toc(trigger_time)>0.2
%                 t = t+1;
%                 disp(['TRIGGER' num2str(t)]);
%                 fdbk = 1;
%                 while fdbk
%                     fprintf( arduino, '%c',char(99));
%                     fdbk = 0;
%                 end
%               %  trigger_time = tic; % debounce
%             end


        end
% ============================= [ Timing Ratchet ]  ============================= %

        i = i+(out-1);
        if out ~= 2
            disp(['whoops! out = ' num2str(out) ', i = ' num2str(i)]);
        end
        isave(counter) = i;
        counter = counter+1;

% ============================= [ End Function ]  ============================= %

        if counter>30;
            if sum(diff(isave(end-20:end)))<1
                disp('end detected');
                break
            end
        end

    end
end
close all
