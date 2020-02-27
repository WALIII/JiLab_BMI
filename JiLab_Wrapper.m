function JiLab_Wrapper

 arduino = JiLab_Setup;
 
 JiLab_TriggerTest(arduino,10);
 
 fclose(arduino);