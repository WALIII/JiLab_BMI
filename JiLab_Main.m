    function [BMI_Data] = JiLab_Main(arduino,fname,BMI_Data)
% JiLab_Main.m

% Main function for delegating BMI scripts


np = size(BMI_Data.ccimage,1)%512; % pixel resolution
fr = 15; % frame rate hz
nf = 10000; % number of frames
fileID = -1;
max_time = 10000;

% Initialize workspace variables
BMI_Data.condition = 1;
BMI_Data.time = [];
BMI_Data.Frame = zeros(515,512);
BMI_Data.frame_idx = 1;
BMI_Data.Tstart = tic; % timing vector

% continue waiting for file to be created
while fileID < 0
    fileID = fopen(fname,'r','l');
    pause(0.1)
end
t = 0;
% Cursor Plotting
h = animatedline('Color','k','LineWidth',3); % Cursor
h1 = animatedline('Color','g','LineWidth',1); % E1a
h2 = animatedline('Color','g','LineWidth',1); % E1b
h3 = animatedline('Color','r','LineWidth',1); % E2a
h4 = animatedline('Color','r','LineWidth',1); % E2b

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
        means = squeeze(sum(sum(data(:,:,:),1)));
        out = find(means==0,1);
        if out == 1
        else


% ============================= [ BMI SECTION]  ============================= %
            % Main BMI function:
            BMI_Data.BMIready =1;
            BMI_Data.time_idx(counter) = toc(tStart); % how often are we waiting per frame. For timeing rconstruction

            [CURSOR, BMI_Data] = JiLab_Cursor(BMI_Data,data(:,:,out-1),counter)


% ============================= [ Water Delivery]  ============================= %


if BMI_Data.condition == 1; % reward eligibility
    if CURSOR> BMI_Data.reward_threshold
        fdbk = 1;
        while fdbk
            disp('HIT!');
            BMI_Data.condition = 2;

            fprintf(arduino,'%c',char(99)); % send answer variable content to arduino
            fdbk = 0;
        end
    end
elseif BMI_Data.condition == 2
    disp(' Waiting to drop below threshold...')
    if CURSOR< BMI_Data.reset_threshold
        disp ( 'Resetting Cursor')
        BMI_Data.condition = 1;
    end
end
% ============================= [ Arduino Communication]  ============================= %


%             out_pixel =  mean(data(:,:,out-1),'all');

           addpoints(h,i,double(CURSOR));

      addpoints(h1,i,double(BMI_Data.ROI_norm(1,counter))+2);
      addpoints(h2,i,double(BMI_Data.ROI_norm(2,counter))+4);
      addpoints(h3,i,double(BMI_Data.ROI_norm(3,counter))-2);
      addpoints(h4,i,double(BMI_Data.ROI_norm(4,counter))-4);
      drawnow update
          drawnow


        end
% ============================= [ Timing Ratchet ]  ============================= %

        i = i+(out-1);
        if out ~= 2
            disp(['whoops! out = ' num2str(out) ', i = ' num2str(i)]);
        end
        isave(counter) = i;
        counter = counter+1;

% ============================= [ End Function ]  ============================= %

        if counter>100;
            if sum(diff(isave(end-20:end)))<1
                disp('end detected');
                break
            end
        end

    end
end
close all
