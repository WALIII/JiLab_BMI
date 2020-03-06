function step2_Kevin_DriftingGrating_shorkey_f(h)
%% spatial frequency=0.0077 cycles/pixel; =0.18HZ/cm in wenzhi's code;
%% speed: 1.56cycles/sec==
% to have arbitrary images, see example here:
% Image(:,:,1) = uint8( zeros(PyscData.Resolution.height,PyscData.Resolution.width));
% Image(:,:,2) = uint8( zeros(PyscData.Resolution.height,PyscData.Resolution.width));
% Image(:,:,3) = uint8( ones(PyscData.Resolution.height,PyscData.Resolution.width)*...
%     OptionsObj.s.ITIbaseline*255);
% PyscData.tx = Screen('MakeTexture',PyscData.win,Image);

filePath='C:\Stimulation\Kevin';
file='20190307_01';
file=fullfile(filePath,[file,'.mat']);
grayFlag=1;
stiDur=0.04;
stiDelay=[2,0];
%% set up period for static & moving grating
staticMovingT=[4 4 0]; % [a b c] each stimulus consists of a sec satic grating, b sec moving grating, and then c sec static grating
% staticMovingT=[4 4 5]; % [a b c] each stimulus consists of a sec satic grating, b sec moving grating, and then c sec static grating

%% set up trial number and angle numbers for each trial
trialNO=10;
angleNO=12;

timePoint2=sum(staticMovingT(1:2));
timePoint3=sum(staticMovingT(1:3));
sequence=zeros(angleNO,trialNO);
for ii=1:trialNO
    tmp=randperm(angleNO);
    sequence(:,ii)=tmp(:);
end
sequence=sequence-1;
sequenceAngle=sequence*360/angleNO;

global win winRect
rotateMode=[];
if nargin==0
     screenid = max(Screen('Screens'));
        white = WhiteIndex(screenid);
        black = BlackIndex(screenid);
        gray = black;%white+black;gray=gray/2;      
        
    if isempty(win) || isempty(winRect)     
  
        [win, winRect]= Screen('OpenWindow', screenid, black);
    end
    try
        ifi = Screen('GetFlipInterval', win);
    catch me
         [win, winRect]= Screen('OpenWindow', screenid, 0);
         ifi = Screen('GetFlipInterval', win);
    end
    
    contrast=1;
    cyclespersecond=4;%%was 3.1y
    dotSizePix=160;
    dotXpos=1805;
    dotYpos=530;
    freq=0.0046;
    gratingsize=870;
    xc2=505;yc2=125;
    dotColor=[1 1 1]*255;
    amplitude=0.5;
%     gray=128;
    [gratingtex,gratingrect] = CreateProceduralSineGrating(win, gratingsize, gratingsize, [0 0 0.5 0.0],gratingsize/2,contrast);
else
    screenid=h.screenid;
    gray=h.gray;
    white=h.white;
    win=h.win;
    gratingsize=h.gratingsize;
    xc2=h.xc2;
    yc2=h.yc2;
    freq=h.freq;
    amplitude= h.amplitude;
    dotXpos=h.dotXpos;
    dotYpos=h.dotYpos;
    dotSizePix=h.dotSizePix;
    dotColor=h.dotColor;
    gratingtex=h.gratingtex;
    gratingrect=h.gratingrect;  
    cyclespersecond=h.cyclespersecond;
    ifi=h.ifi;
end
phaseincrement = (cyclespersecond * 360) * ifi;
%% gamma correction
fileGamma='C:\Stimulation\gammaTable_OLED.mat';
 [oldtable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable',win);
if exist(fileGamma)~=0
   load(fileGamma);
   table=gammaTable*[1 1 1];
   [oldtable, success] = Screen('LoadNormalizedGammaTable',win ,table);    
   
end


phaseInitial=0;


breakID=0;
rect=OffsetRect(gratingrect, xc2, yc2);

[x1,y1]=RectCenter(rect);
grayRGB=[0 0 1]*gray;
grayRGB
whiteRGB=[1 1 1]*white;
rect2=[dotXpos-dotSizePix/2,dotYpos-dotSizePix/2,dotXpos+dotSizePix/2,dotYpos+dotSizePix/2];

filePath0='C:\Stimulation\autoSave_log';
if exist(filePath0)==7
else
    mkdir(filePath0);
end
formatIn0='yyyymmdd_';
global trialID_step2
if isempty(trialID_step2)
    trialID_step2=1;
else
    trialID_step2=trialID_step2+1;
end
file0=[datestr(now,formatIn0),num2str(trialID_step2,'%02d'),];
formatIn='yyyymmdd_HHMMSS';
file0=[file0,'_',datestr(now,formatIn),'_Cristina.mat'];
file0Save=file0;
file0=fullfile(filePath0,file0);
timeStamp=zeros(angleNO*trialNO+1,6);
timeStampInternal=zeros(angleNO*trialNO+1,1);
save(file0);
save(file);
try
    filePathServer='\\10.254.8.27\jilab\Data\stimulus autoLog';
    fileServer=fullfile(filePathServer,file0Save);
    save(fileServer)
catch me
end
tt=1;
if grayFlag==1
    Screen('FillOval',win,grayRGB,rect);
%     Screen('DrawDots', win, [x1 y1], gratingsize, [1,1,1]*gray, [], 2);
%                     vbl = Screen('Flip', win, vbl + .5 * ifi);   
    vbl = Screen('Flip', win);     
    t1=vbl;
    ta=datevec(now);
    timeStamp(1,:)=ta; timeStampInternal(tt)=vbl;tt=tt+1;%timeStamp(tt,:)=datevec(now);tt=tt+1;
    trashT=zeros(2,1);
    for jj=1:trialNO
        for ii=1:angleNO
            phase=phaseInitial;
            kk=1;
            t2=vbl;
            angleOrientation=sequenceAngle(ii,jj);
%             [keyIsDown, ~, keyCode, ~] = KbCheck;
             
%             if keyIsDown
%         %         x1=0;y1=0;r1=0;c1=0.1;cycle1=0.1;freq1=0.05;
%                 KbReleaseWait;
%                 kbNameResult = KbName(keyCode);
%                 if strcmp(kbNameResult,'f12')
%                     breakID=1;
%                 break;
%                 end
%             else
                while kk==1
                    [keyIsDown, ~, keyCode, ~] = KbCheck;
                    if keyIsDown
%                         KbReleaseWait;
                        kbNameResult = KbName(keyCode);
                        if strcmp(kbNameResult,'f12')
                            breakID=1; trialID_step2=trialID_step2-1;return;
%                         break;
                        end
                    end
%                         tb=datevec(now);
                        if t2-t1<=staticMovingT(1) || (t2-t1<=timePoint3 && t2-t1>timePoint2)
                            Screen('FillOval',win,grayRGB,rect);
                            vbl = Screen('Flip', win, vbl + .5 * ifi); 
                             t2=vbl;%trashT(1)=trashT(2);trashT(2)=t2;disp([trashT(2)-trashT(1)])
                        elseif t2-t1<=timePoint2
                            Screen('DrawTexture', win, gratingtex, [],rect , 180-angleOrientation, [], [], [0 0 1]*white, [], rotateMode, [phase, freq, amplitude, 0]); 
                            vbl = Screen('Flip', win, vbl + .5 * ifi);
                            t2=vbl;
                           phase = phase + phaseincrement; 
                        else
                            kk=0;
                            timeStamp(tt,:)=datevec(now);timeStampInternal(tt)=vbl;tt=tt+1;
                            disp(['tiralID=',num2str(jj,'%02d'),'angleID=',num2str(ii,'%02d'),'angle=',num2str(angleOrientation),';taking time (s)', num2str(t2-t1)]);
%                             disp(['vb=',num2str(t2-t1),'cputime=',num2str(etime(tb,ta))]);
                            t1=vbl;continue;
%                             ta=tb;
                        end
                        if t2-t1>=stiDelay(1) && t2-t1<=stiDelay(1)+stiDur
                            Screen('FillOval',win,whiteRGB,rect2);
%                             Screen('DrawDots', win, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
                        end
                         if t2-t1>=stiDelay(2)+staticMovingT(1) && t2-t1<=stiDelay(2)+staticMovingT(1) +stiDur
                             Screen('FillOval',win,whiteRGB,rect2);
%                             Screen('DrawDots', win, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
                         end
%                     end
                end
                
        end
    end    
else
    Screen('DrawTexture', win, gratingtex, [], OffsetRect(gratingrect, xc2, yc2), sequenceAngle(1,1), [], [], [], [], rotateMode, [phaseInitial, freq, amplitude, 0]); 
    vbl = Screen('Flip', win);     
    t1=vbl;
    ta=datevec(now);
    timeStamp(tt,:)=datevec(now);timeStampInternal(tt)=vbl;tt=tt+1;
    for jj=1:trialNO
        for ii=1:angleNO
            phase=phaseInitial;
            kk=1;
            angleOrientation=sequenceAngle(ii,jj);
            [keyIsDown, ~, keyCode, ~] = KbCheck;
%             if keyIsDown
%         %         x1=0;y1=0;r1=0;c1=0.1;cycle1=0.1;freq1=0.05;
%                 KbReleaseWait;
%                 kbNameResult = KbName(keyCode);
%                 if strcmp(kbNameResult,'f12')
%                     breakID=1;
%                 break;
%                 end
%             else
                while kk==1
                    [keyIsDown, ~, keyCode, ~] = KbCheck;
                    if keyIsDown
%                         KbReleaseWait;
                        kbNameResult = KbName(keyCode);
                        if strcmp(kbNameResult,'f12')
                            breakID=1; trialID_step2=trialID_step2-1;return;
%                         break;
                        end
                    end
%                     else
                        Screen('DrawTexture', win, gratingtex, [], OffsetRect(gratingrect, xc2, yc2), 180-angleOrientation, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]); 
                        vbl = Screen('Flip', win, vbl + .5 * ifi); 
                        t2=vbl;
%                         tb=datevec(now);
                        if t2-t1<=staticMovingT(1) || (t2-t1<=timePoint3 && t2-t1>timePoint2)
                            phase = phase + 0; 
                        elseif t2-t1<=timePoint2
                           phase = phase + phaseincrement; 
                        else
                            kk=0;
                            timeStamp(tt,:)=datevec(now);timeStampInternal(tt)=vbl;tt=tt+1;
                            disp(['tiralID=',num2str(jj,'%02d'),'angleID=',num2str(ii,'%02d'),'angle=',num2str(angleOrientation),';taking time (s)', num2str(t2-t1)]);
%                             disp(['vb=',num2str(t2-t1),'cputime=',num2str(etime(tb,ta))]);
                            t1=vbl;continue;
%                             ta=tb;
                        end
                        if t2-t1>=stiDelay(1) && t2-t1<=stiDelay(1)+stiDur
                             Screen('FillOval',win,whiteRGB,rect2);
                        end
                         if t2-t1>=stiDelay(2)+staticMovingT(1) && t2-t1<=stiDelay(2)+staticMovingT(1) +stiDur
                            Screen('FillOval',win,whiteRGB,rect2);
                         end
%                     end
                end
                
        end
    end

end
[oldtable, success] = Screen('LoadNormalizedGammaTable',win ,oldtable);
try

    matObj=matfile(file0,'Writable',true);
    matObj.timeStamp=timeStamp;
    matObj.timeStampInternal=timeStampInternal;
    matObj=matfile(file,'Writable',true);
    matObj.timeStamp=timeStamp;
    matObj.timeStampInternal=timeStampInternal;
    matObj=matfile(fileServer,'Writable',true);
    matObj.timeStamp=timeStamp;
    matObj.timeStampInternal=timeStampInternal;
%     fileServer
catch me
end
