

function JiLab_Wrapper

arduino = JiLab_Setup;

%JiLab_TriggerTest(arduino,10);
try
    fname = 'E:\Kevin\20200226\test1_056\Image_001_001.raw';
    JiLab_Main(arduino,fname);
catch
    fclose(arduino);
end

    fclose(arduino);
