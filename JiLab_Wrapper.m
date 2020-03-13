

function  [BMI_Data] = JiLab_Wrapper

arduino = JiLab_Setup;



% connect
t = tcpip('169.229.54.112',30000,'NetworkRole','client');
fopen(t);
disp('Connection made!')
pause; % wait for key press

BMI_Data.Orientations = [ 1 2 3 4 5 6 7 8 9 10 11 12];
BMI_Data.hit_counter = 1;
%JiLab_TriggerTest(arduino,10);
try


% ============================= [ PICK ROIS ]  ============================= %
disp('Take Baseline Data...')
[I, M, ROI, ccimage] = CaBMI_Dendrites;
BMI_Data.ROI = ROI;
BMI_Data.ccimage = ccimage;

% Basic inputs:
BMI_Data.reward_threshold = 2.5;
BMI_Data.reset_threshold = 1;


    fname = 'E:\Kevin\20200313\test\test1_001\Image_001_001.raw';
    [BMI_Data] = JiLab_Main(arduino,fname,BMI_Data,t);
catch
    fclose(arduino);
        fclose(t);

end

    fclose(arduino);
    fclose(t);
    % close 
