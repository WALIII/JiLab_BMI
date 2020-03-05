

function JiLab_Wrapper

arduino = JiLab_Setup;

%JiLab_TriggerTest(arduino,10);
try
    
    
% ============================= [ PICK ROIS ]  ============================= %
disp('Take Baseline Data...')
[I, M, ROI, ccimage] = CaBMI_Dendrites;
BMI_Data.ROI = ROI;
BMI_Data.ccimage = ccimage;


    fname = 'E:\Kevin\20200305\testing\test1_018\Image_001_001.raw';
    JiLab_Main(arduino,fname,BMI_Data);
catch
    fclose(arduino);
end

    fclose(arduino);
