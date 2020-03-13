function step1_DriftGrating(cyclespersecond, freq, gratingsize, internalRotation)
keyboardFlag=1;
autoSaveFlag=1;
% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL; 
rotateMode = [];


gratingsize = 400;
freq = 0.02;% Frequency of the grating in cycles per pixel: Here 0.01 cycles per pixel:
cyclespersecond = 1;
angle = 0;

% res is the total size of the patch in x- and y- direction, i.e., the
% width and height of the mathematical support:

% Amplitude of the grating in units of absolute display intensity range: A
% setting of 0.5 means that the grating will extend over a range from -0.5
% up to 0.5, i.e., it will cover a total range of 1.0 == 100% of the total
% displayable range. As we select a background color and offset for the
% grating of 0.5 (== 50% nominal intensity == a nice neutral gray), this
% will extend the sinewaves values from 0 = total black in the minima of
% the sine wave up to 1 = maximum white in the maxima. Amplitudes of more
% than 0.5 don't make sense, as parts of the grating would lie outside the
% displayable range for your computers displays:
amplitude = 0.5;
Screen('Preference', 'SkipSyncTests', 1);
% Choose screen with maximum id - the secondary display on a dual-display
% setup for display:
screenid = max(Screen('Screens'));
BackupCluts(screenid);
% screenid=1;


%%
% Open a fullscreen onscreen window on that display, choose a background
% color of 128 = gray, i.e. 50% max intensity:
white = WhiteIndex(screenid);
black = BlackIndex(screenid);
gray = white+black;gray=gray/2;
global win winRect
if isempty(win) || isempty(winRect)
    [win, winRect]= Screen('OpenWindow', screenid, black);
end
try
    ifi = Screen('GetFlipInterval', win);
catch me
     [win, winRect]= Screen('OpenWindow', screenid, black);
end

dotSizePix=50;
dotXpos=winRect(3)-dotSizePix-5;
dotYpos=winRect(4)/2;

filePath='C:\Stimulation\autoSave_parameters';
if exist(filePath)==7
else
    filePath=cd;
end


% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white

%  white = WhiteIndex(win);
%  gray=128;
[xc0,yc0] = RectCenter(winRect);
xc=0;
yc=0;
file='parameters_kevin_will.mat';
contrast=1;
if exist(fullfile(filePath,file))~=0
    load(fullfile(filePath,file));
end
res = [gratingsize gratingsize];
% Make sure the GLSL shading language is supported:
AssertGLSL;

% Retrieve video redraw interval for later control of our animation timing:
ifi = Screen('GetFlipInterval', win);

% Phase is the phase shift in degrees (0-360 etc.)applied to the sine grating:
phase = 0;

% Compute increment of phase shift per redraw:
phaseincrement = (cyclespersecond * 360) * ifi;

% Build a procedural sine grating texture for a grating with a support of
% res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.

[gratingtex,gratingrect] = CreateProceduralSineGrating(win, res(1), res(2), [0 0 0.5 0.0],res(1)/2,contrast);
% [gratingtex2,gratingrect2] = CreateProceduralSineGrating(win, res(1), res(2), [1 1 1 0.0]*1,res(1)/2,contrast);
% Wait for release of all keys on keyboard, then sync us to retrace:
KbReleaseWait;
ListenChar(2);
vbl = Screen('Flip', win);
t0=cputime;
t1=t0;

        
% Animation loop: Repeats until keypress...
endFlag=0;
step=10;
pattern='moving';
blackImg=zeros(winRect(4),winRect(3),3);
% tx=Screen('OpenOffscreenWindow', win, 0, rect);
% tx_black = Screen('MakeTexture',win,blackImg);
% grayImg=zeros(winRect(4),winRect(3),3)+gray;
tx_black=Screen('OpenOffscreenWindow', win, 0, winRect);
tx_gray=Screen('OpenOffscreenWindow', win, gray, winRect);
% tx_black = Screen('MakeTexture',win,blackImg);
% grayImg=zeros(winRect(4),winRect(3),3)+gray;
% tx=Screen('OpenOffscreenWindow', win, 0, rect);
% tx_black = Screen('MakeTexture',win,blackImg);
blackFlag=0;
dotColor=[1 1 1]*white;
rect2=[dotXpos-dotSizePix/2,dotYpos-dotSizePix/2,dotXpos+dotSizePix/2,dotYpos+dotSizePix/2];
currentPatch=1;
ii=1;
% f1, switch between ROIs;
% esc: switch between black and moving grating;
% g: gray background;
% 
ta=datevec(now);
rotatingFlag=1;
movingFlag=1;
%    trashFlag=0;
while endFlag==0
    % Update some grating animation parameters:
    [keyIsDown, ~, keyCode, ~] = KbCheck;
    
    if keyIsDown
        x1=0;y1=0;r1=0;c1=0.1;cycle1=0.01;freq1=0.0001;
        KbReleaseWait;
        kbNameResult = KbName(keyCode);
        if strcmp(kbNameResult,'f11')
            break;
         elseif strcmp(kbNameResult,'f1')
            if currentPatch==1
                currentPatch=2;
            else
                currentPatch=1;
            end
        elseif strcmp(kbNameResult,'pageup') & keyboardFlag==1
            cyclespersecond=cyclespersecond+cycle1;
            phaseincrement = (cyclespersecond * 360) * ifi;
         elseif strcmp(kbNameResult,'pagedown') & keyboardFlag==1
            cyclespersecond=cyclespersecond-cycle1;
            phaseincrement = (cyclespersecond * 360) * ifi;         
         elseif strcmp(kbNameResult,'home') & keyboardFlag==1
            freq=freq+freq1;
          elseif strcmp(kbNameResult,'end') & keyboardFlag==1
            freq=freq-freq1; 
            freq=max([freq,0]);
        elseif strcmp(kbNameResult,'up') & keyboardFlag==1
            y1=-step;
        elseif strcmp(kbNameResult,'down') & keyboardFlag==1
            y1=step;
        elseif strcmp(kbNameResult,'f8')
            if rotatingFlag==0
                rotatingFlag=1;
            else
                rotatingFlag=0;
            end
        elseif strcmp(kbNameResult,'f7')
            if movingFlag==0
                movingFlag=1;
            else
                movingFlag=0;
            end
                        
        elseif strcmp(kbNameResult,'left') & keyboardFlag==1   
            x1=-step;
        elseif strcmp(kbNameResult,'right')  & keyboardFlag==1  
            x1=step;   
        elseif strcmp(kbNameResult,'.>')    & keyboardFlag==1
            r1=step;  
        elseif strcmp(kbNameResult,',<')    & keyboardFlag==1
            r1=-step;           
        elseif strcmp(kbNameResult,']')    & keyboardFlag==1
            contrast=contrast+c1;
            contrast=min([contrast,1]);
            [gratingtex,gratingrect] = CreateProceduralSineGrating(win, res(1), res(2), [0 0 0.5 0.0],res(1)/2,contrast);
        elseif strcmp(kbNameResult,'[')    & keyboardFlag==1
            contrast=contrast-c1;
            contrast=max([contrast,0]);
            [gratingtex,gratingrect] = CreateProceduralSineGrating(win, res(1), res(2), [0 0 0.5 0.0],res(1)/2,contrast);
        elseif strcmp(kbNameResult,'esc') 
            %% switch between moving grating and black background
            blackFlag=~blackFlag;
            if blackFlag
                pattern='black';
            else
                pattern='moving';
            end
        elseif strcmp(kbNameResult,'g') 
            %% change to gray background
            pattern='gray';
        elseif strcmp(kbNameResult,'b') 
            %% change to black background
            pattern='black';blackFlag=true;     
        elseif strcmp(kbNameResult,'m') 
            %% chnage to moving grating
            pattern='moving'; blackFlag=false;            
        elseif strcmp(kbNameResult,'return')|| strcmp(kbNameResult,'y') || strcmp(kbNameResult,'k') || strcmp(kbNameResult,'q') || strcmp(kbNameResult,'f') || strcmp(kbNameResult,'s') || strcmp(kbNameResult,'t') ||strcmp(kbNameResult,'a')||strcmp(kbNameResult,'u')%step2_Yajie_spatialTemporalMaping_v2_shortkey_a
            h.white=white;
            h.screenid=screenid;
            h.win=win;
            h.gratingsize=gratingsize;
            h.gratingtex=gratingtex;
            h.gratingrect=gratingrect;
            h.cyclespersecond=cyclespersecond;
            h.xc2=xc2;
            h.yc2=yc2;
            h.freq=freq;
            h.amplitude=amplitude;
            h.dotXpos=dotXpos;
            h.dotYpos=dotYpos;
            h.dotSizePix=dotSizePix;
            h.dotColor=dotColor;
            h.contrast=contrast;
            h.ifi=ifi;
            h.gray=gray;
            if strcmp(kbNameResult,'return')
                DriftingGrating_step2(h);
            end
            if strcmp(kbNameResult,'k')
                step2_Katharine_DriftingGrating_shorkey_k(h);
            end   
            if strcmp(kbNameResult,'q')
                step2_Kevin_DriftingGrating_shorkey_q(h);
            end   
            if strcmp(kbNameResult,'f')
                step2_Cristina_DriftingGrating_shorkey_f(h);
            end  
            if strcmp(kbNameResult,'y')
                step2_Yajie_DriftingGrating_shorkey_y(h);
            end      
            if strcmp(kbNameResult,'s')
                step2_Yajie_spatialMaping_shortkey_s(h);
            end   
            if strcmp(kbNameResult,'t')
                step2_Yajie_temporalMaping_shortkey_t(h);
            end    
            if strcmp(kbNameResult,'a')
                step2_Yajie_spatialTemporalMaping_v2_shortkey_a_v2(h);
%                 step2_Yajie_spatialTemporalMaping_v2_shortkey_a(h);
            end  
             if strcmp(kbNameResult,'u')
                DriftingGrating_step2b_YajieTwoAngles_shortkey_u(h);
%                 step2_Yajie_spatialTemporalMaping_v2_shortkey_a(h);
            end             
            pattern='moving';      
        end
%         disp(['xc=',num2str(xc),';yc=',num2str(yc)])
        if currentPatch==1
            xc=xc+x1;yc=yc+y1;
            %if r1~=0
                gratingsize=gratingsize+r1;
                res=[gratingsize,gratingsize];
                [gratingtex,gratingrect] = CreateProceduralSineGrating(win,... 
                    res(1), res(2), [0 0 0.5 0.0],res(1)/2,contrast);
            %end
            
            
        else
            dotXpos=dotXpos+x1;
            dotYpos=dotYpos+y1;
            dotSizePix=dotSizePix+r1;
            rect2=[dotXpos-dotSizePix/2,dotYpos-dotSizePix/2,dotXpos+dotSizePix/2,dotYpos+dotSizePix/2];
        end
        save(fullfile(filePath,file), 'rectMain','xc','yc','dotXpos','dotYpos','dotSizePix','freq','cyclespersecond','gratingsize','contrast','rect2','xc0','yc0')
    else
        
        if strcmp(pattern,'moving')
             % Increment phase by 1 degree:
             if movingFlag==1
                  phase = phase + phaseincrement; 
             else
                  phase = phase + 0; 
             end
               
            xc2=xc0-res(1)/2+xc;
            yc2=yc0-res(2)/2+yc;
            rectMain=OffsetRect(gratingrect, xc2, yc2);
            % Draw the grating, centered on the screen, with given rotation 'angle',
            % sine grating 'phase' shift and amplitude, rotating via set
            % 'rotateMode'. Note that we pad the last argument with a 4th
            % component, which is 0. This is required, as this argument must be a
            % vector with a number of components that is an integral multiple of 4,
            % i.e. in our case it must have 4 components:
            Screen('DrawTexture', win, gratingtex, [], rectMain, 180-angle,... 
                [], [], [0 0 1]*white, [], rotateMode, [phase, freq, amplitude, 0]); 
        %     Screen('DrawTexture', win, gratingtex2, [], OffsetRect(gratingrect, xc+600, yc), angle, [], [], [], [], rotateMode, [phase, freq, amplitude, 0]); 
%              Screen('DrawDots', win, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
            Screen('FillOval',win,dotColor,rect2);
            textMessage(winRect,contrast,win,freq,cyclespersecond,angle)
            if currentPatch==2
                Screen('FrameOval', win, [1,0,0]*white,... 
                    [dotXpos-dotSizePix*0.6 dotYpos-dotSizePix*0.6,...
                    dotXpos+dotSizePix*0.6 dotYpos+dotSizePix*0.6]);
            else
                Screen('FrameOval', win, [1,0,0]*white, rectMain);
            end    
        %     Screen('CopyWindow',movie(i),win,rect,rect);
            % Show it at next retrace:
            vbl = Screen('Flip', win, vbl + .5 * ifi);  
            
            tb=datevec(now);
            if ii==1
                t1=vbl;
                ii=2;
            end
        elseif strcmp(pattern,'black')
            Screen('DrawTextures', win, tx_black)
            textMessage(winRect,contrast,win,freq,cyclespersecond,angle)

            vbl = Screen('Flip', win, vbl + .5 * ifi);              
        elseif strcmp(pattern,'gray')
            Screen('DrawTextures', win, tx_gray)
            textMessage(winRect,contrast,win,freq,cyclespersecond,angle)
            vbl = Screen('Flip', win, vbl + .5 * ifi);               
        end
    end
    t2=vbl;
    if t2-t1>=1
        phase=mod(phase,360);
        if rotatingFlag==1
            angle = mod(angle+45,360);
        end
        t1=vbl;
    end       
    
    
end
ListenChar(0); 
% We're done. Close the window. This will also release all other ressources:
% sca;
RestoreCluts;
sca;
if autoSaveFlag==1
    formatIn='yyyymmdd_HHMMSS_FFF';
    save(fullfile(filePath,['parameters_KevinGrating',datestr(now,formatIn),'.mat']),... 
        'xc','yc','dotXpos','dotYpos','dotSizePix','freq',...
        'cyclespersecond','gratingsize','contrast','rect2')
else
end
function textMessage(winRect,contrast,win,freq,cyclespersecond,angle)
try
    intensity=80;
    color=[1,0,0];
yy0=winRect(4)-300; xx0=20;
text1=['contrast=',num2str(contrast)];
[nx, ny, textbounds] = DrawFormattedText(win, text1,xx0,yy0,color*intensity);
% ny=ny0;
text2=['angle=',num2str(angle)];
[nx, ny, textbounds] = DrawFormattedText(win, text2,xx0,ny+50,color*intensity);  

text1=['spatial fre=',num2str(freq,'%06.4f'),'cycles/pixel (default:0.0079 or 0.0041)'];
[nx, ny, textbounds] = DrawFormattedText(win, text1,xx0,ny+50,color*intensity);           
text3=['temporal fre=',num2str(cyclespersecond),'cycles/s (default: 1.54)'];
[nx, ny, textbounds] = DrawFormattedText(win, text3,xx0,ny+50,color*intensity);      
             
text4=['b: black; g: gray; m: moving; f1: switching ROI; f7: static/moving; f8: rotaton; f11: stop step1; f12 stop step2;'];
[nx, ny, textbounds] = DrawFormattedText(win, text4,xx0,ny+50,color*intensity);      
text5=['< >: size; []: contrast; home/end: sptial fre; pageup/pagedown: temproal fre; enter: run step2'];
[nx, ny, textbounds] = DrawFormattedText(win, text5,xx0,ny+50,color*intensity);       
catch me
%     display('error text')
end
%                        vbl = Screen('Flip', win, vbl + .5 * ifi);   
             

% save parameters         
% Bye bye!
% return;
