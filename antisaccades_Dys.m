%----------------------------------------------------------------------
%                       Initialisation
%----------------------------------------------------------------------
% Clear the workspace
close all;
clear all;
sca;

% Screen('Preference', 'SkipSyncTests', 1) % only needed with old screens or weird setups, do not use in lab

ExperimentName='antisaccades_eeg';
% add a subject ID
subjectnumber = 0; % 0 = test

% set the number of trials
numTrials = 8; % needs to be a multiple of 4 (or 8?)
% setup parameter in cm
monitorwidth = 28;    %53 cm in EEG lab
monitorheight = 17.5;     %29.9 cm in EEG lab
monitordistance = 60;   %70 cm in EEG lab

% determine if Eyelink is used
UseEyelink = 1;   %should always be 1 if running the fully setup experiment

%create edf file
datum=clock();
edfNametemp = sprintf('S%s%02d%02d%02d.edf',char(datum(2)+64),datum(3),datum(4),datum(5));
edfName = sprintf('%05d.%s.%04d%02d%02d_%02d%02d%02d.edf',subjectnumber,ExperimentName,datum(1),datum(2),datum(3),datum(4),datum(5),floor(datum(6)));
savePath=['.\', sprintf('%04d\\%02d\\',datum(1),datum(2))];
if exist(savePath,'dir')~=7 
      mkdir('.',savePath);
end

% determine if EEG is used
outp_switch = 1;        %should always be 1 if running the fully setup experiment 
% %% Stimuli List for EEG
start_experiment    =   99;
start_trial         =   9;
target_left         =   3;
target_right        =   2;
prosaccade          =   5;
antisaccade         =   6;
gap                 =   11;
overlap             =   12;
config_io;
address             =   hex2dec('D010');

% Seed the random number generator. Here we use the older way to be compatible with older systems. Newer syntax would be rng('shuffle'). 
rand('seed', sum(100 * clock));

% Set the screen number to the external secondary monitor if there is one connected
screens=Screen('Screens');
screenNumber=max(screens); %Bei manchen Multi-Monitor-Setups st¸rzt MATLAB ab, wenn man keine explizite Screen-Nummer angibt!

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);
background = black;
foreground = white;

% Open the screen to initilize Psychtoolbox
[window, windowRect] = Screen('OpenWindow', screenNumber, background, [], 32, 2, [], [],  kPsychNeed32BPCFloat);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% ifi = 1/120;
% Set the text size
Screen('TextSize', window, 40);
% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels.
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%%% Prepare Eyelink
if UseEyelink==1
      el = ELPH_EyelinkInitDefaults(window,background,foreground); %% Load Default-Values
      ELPH_initEL2(edfNametemp);
      fprintf('EDF wird geˆffnet\n');
      Eyelink('Command','screen_pixel_coords = %d %d %d %d',0,0,screenXpixels-1,screenYpixels-1);
      Eyelink('Message','DISPLAY_COORDS %d %d %d %d',0,0,screenXpixels,screenYpixels);
      Eyelink('Message','%s',sprintf('DISPLAY_SIZE %6.1f %6.1f %6.1f',monitorwidth,monitorheight,monitordistance));
end

%
%--------------------
% Dot information
%--------------------

% Amplitude des Stimulus
angularDeg = 15;
amplitude = tand(angularDeg) * monitordistance * screenXpixels / monitorwidth;

% Set the color of our dots to full white, red and green. Color is defined by red green
% and blue components (RGB).
FixdotColor = [255 255 255];
FixProdotColor = [0 255 0];
FixAntidotColor = [255 0 0];
StimdotColor = [255 255 255];

% Shift for moving fixpoint x-position, values higher than 1 -> right side
% of screen, set to 1.0 for center
fixShift = 1.0;

%Fixationspunkt im Zentrum des Bildschirms
fixXpos=xCenter * fixShift;
fixYpos=yCenter;

% Dot size in pixels
dotSizeDeg = 1;
dotSizePix = tand(dotSizeDeg) * monitordistance * screenXpixels / monitorwidth;
fixSizeDeg = 1;
fixSizePix = tand(fixSizeDeg) * monitordistance * screenXpixels / monitorwidth;

% Farbe Fixationspunkt randomisieren
ColOneTwo = repmat([1,2],1,numTrials/2);
RandCol = ColOneTwo(randperm(numTrials));

% Lage Fixationspunkt randomisieren
PosOneTwo = repmat([1,2],1,numTrials/2);
RandPos = PosOneTwo(randperm(numTrials));

% gap/overlap condition randomisieren 
GapOneTwo = repmat([1,2],1,numTrials/2);
RandGap = GapOneTwo(randperm(numTrials));

%----------------------------------------------------------------------
%                       Online Eye Tracking
%----------------------------------------------------------------------

%Grˆﬂe der tracking fenster
fix_degwindowX = 4;
fix_windowX = tand(fix_degwindowX) * monitordistance * screenXpixels / monitorwidth;
fix_degwindowY = 4;
fix_windowY = tand(fix_degwindowY) * monitordistance * screenXpixels /monitorheight;
% sac_windowX = 8; alt, variables Fenster im Trial
% sac_windowY = 8;

%Delay f¸r die ‹berpr¸fung. Testperson braucht eine Vorlauffzeit zum Fixieren
%sonst bricht der Trial sofort ab. Delay in Sekunden -> Frames
% fix_delay = round(0.5 / ifi);  %0.5s bedeutet die letzten 500 ms Fixation m¸ssen stimmen
% sacc_delay = round(2.5 / ifi);  %2.5s bedeutet die letzten 500 ms muss das Sakkadenziel fixiert werden
fix_time = round(0.5 / ifi); %500 ms muss Fixation stimmen
sacc_time = round(0.5 / ifi); %innerhalb von 500 ms soll das Ziel gesehen werden
sacc_time_fix = round(0.5 / ifi); %wenn gesehen, 500 ms anschauen

%Pixel per Degree - vertical
pixperdegY = tand(1) * monitordistance * screenYpixels / monitorheight;

%Pixel per Degree - horizontal
pixperdegX = tand(1) * monitordistance * screenXpixels / monitorwidth;

%Bestimme Fix-Window f¸r Online-‹berpr¸fung der Augenposition
fixwindow = [round(fixXpos - fix_windowX/2) round(fixXpos + fix_windowX/2) round(fixYpos - fix_windowY/2) round(fixYpos + fix_windowY/2)];


%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

% Inter-Stimulus Intervall
intStimSecs = 1;
intStimFrames = round(intStimSecs / ifi);

% Dauer des Stimulus
stimTimeSecs = 1;
stimTimeFrames = round(stimTimeSecs / ifi);

% Dauer des Gap
%will be randomized later
 gapgapTime = 0.2;
 overlapgapTime = 0;
% gapTimeFrames = round(gapTimeSecs / ifi);

% Dauer des Overlap
% will be randomized later
gapoverlapTime = 0;
overlapoverlapTime = 0.2;
%overlapTimeFrames = round(overlapTimeSecs / ifi);

% Dauer des Vorbereitungspunktes rot oder gr¸n zur vorbereitung auf Aufgabe
grTimeSecs = 1.0;
grTimeFrames = round(grTimeSecs / ifi);
% Numer of frames to wait before re-drawing
waitframes = 1;

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
space = KbName('space');

%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

%%% EL Kalibration;
if UseEyelink==1
      Eyelink('Message','start experiment');
      Eyelink('Message','Calibration');
      fprintf('Kalibration wird gestartet');
      ELPH_dotrackersetup(el);
      eye_used=Eyelink('EyeAvailable'); %get eye thats tracked
      if eye_used == el.BINOCULAR
            eye_used = el.LEFT_EYE;
      end
end

if outp_switch == 1
        outp(address, start_experiment)
end

% Preallocating space for time measurement
timeFixationTotal(numTrials) = 0;
timeFixationFactor(numTrials) = 0;
timeStimulusTotal(numTrials) = 0;
timeStimulusFactor(numTrials) = 0;


% Animation loop: we loop for the total number of trials
for trial = 1:numTrials
    
      if outp_switch == 1
            outp(address, start_trial)
       end
      
      %
      HideCursor; %Mauszeigen ausblenden
      
      %Kommunikation mit dem Eyelink-Rechner
      if UseEyelink==1
            trialText=sprintf('TRIALID %d-%d',trial,numTrials);
            Eyelink('Message','%s',trialText); %%% Geht nicht direkt, keine Ahnung warum???
            Eyelink('Command','record_status_message "%s Trial %d von %d"',edfName,trial,numTrials);
            Eyelink('StartRecording');
            WaitSecs(0.05); %%% kurzes Warten auf Eyelink
            Eyelink('Message','start recording');
      end
      
      trialStart = GetSecs(); %Trialstart f¸r sp‰ter speichern - tempor‰re Variable
      
      % Flashposition (horizontale) randomisieren
      if RandPos(trial) == 1
            dotXposDeg = xCenter + amplitude;
            stimPos = {'right'};
      else
            dotXposDeg = xCenter - amplitude;
            stimPos = {'left'};
      end
      dotXpos = dotXposDeg;
      
      % Flashposition (vertikale) = 0∞
      dotYposDeg = 0;
      dotYpos = yCenter;
      
      % share randomization with eyelink
      if UseEyelink == 1 & dotXposDeg == xCenter + amplitude
            Eyelink('Message', 'right');
      elseif UseEyelink == 1 & dotXposDeg == xCenter - amplitude
            Eyelink('Message', 'left');
      end
      
      % same for EEG
       if  outp_switch == 1 & dotXposDeg == xCenter + amplitude
            outp(address, target_right);
      elseif outp_switch == 1 & dotXposDeg == xCenter - amplitude
            outp(address, target_left);
      end
      
      % Farbe Fixationspunkt randomisieren
      if RandCol(trial) == 1
            dotFixColor = FixProdotColor;
            proanti = {'pro'};
      else
            dotFixColor = FixAntidotColor;
            proanti = {'anti'};
      end
      dotColor = round(dotFixColor);
      
      % Benachrichtigung an EyeLink ob Fixationspunk gr¸n oder rot
      if UseEyelink == 1 & dotFixColor == FixProdotColor
            Eyelink('Message', 'pro');
      elseif UseEyelink == 1 & dotFixColor == FixAntidotColor
            Eyelink('Message', 'anti');
      end
        % same for EEG
       if  outp_switch == 1 & dotFixColor == FixProdotColor
            outp(address, prosaccade);
      elseif outp_switch == 1 & dotFixColor == FixAntidotColor
            outp(address, antisaccade);
       end
      
       
      % randomize gap/overlap condition
      if RandGap(trial) == 1
            gapTimes = gapgapTime;
            overlapTimes = gapoverlapTime;
            gapoverlap = {'gap'};
      else
            gapTimes = overlapgapTime;
            overlapTimes = overlapoverlapTime;
            gapoverlap = {'overlap'};
      end
       gapTimeSecs = gapTimes;
       overlapTimeSecs = overlapTimes;
       gapTimeFrames = round(gapTimeSecs / ifi);
       overlapTimeFrames = round(overlapTimeSecs / ifi);
      
      % share randomization with eyelink
      if UseEyelink == 1 & gapTimeSecs == gapgapTime
            Eyelink('Message', 'gap');
      elseif UseEyelink == 1 & gapTimeSecs == overlapgapTime
            Eyelink('Message', 'overlap');
      end
        % same for EEG
       if  outp_switch == 1 & gapTimeSecs == gapgapTime
            outp(address, gap);
      elseif outp_switch == 1 & 1 & gapTimeSecs == overlapgapTime
            outp(address, overlap);
       end
      
      % Bestimme Saccaden Fenster Breite 10x10∞
      sac_degwindowX = 10;
      sac_degwindowY = 10;
      sac_windowX = tand(sac_degwindowX) * monitordistance * screenXpixels / monitorwidth;
      sac_windowY = tand(sac_degwindowY) * monitordistance * screenYpixels / monitorwidth;
      
      %Bestimme Sacc-Window f¸r Online-‹berpr¸fung der Augenposition
      sacwindow = [round(dotXpos - sac_windowX/2) round(dotXpos + sac_windowX/2) round(dotYpos - sac_windowY/2) round(dotYpos + sac_windowY/2)];
      
      KbReleaseWait;
      
      vbl = Screen('Flip', window);
      %Initialisierung von skip_trial f¸r die online-Fixkontrolle
      skip_trial = 0;
      % Wenn dieser Wert nicht ¸berschrieben wird durch 0 oder 1, war dieser
      % Trial ung¸ltig
      localization = 0;
      % Markierung f¸r Zielfixation, wird 0 wenn Ziel nicht korrekt fixiert
      target_fixation = 1;
      
      % Now we present the pres interval with fixation point minus one frame
      % because we presented the fixation point once already when getting a
      % time stamp, initial fixation
      
      % presentation Inter-Stimulus Intervall
      Screen('FillRect', window, background, windowRect);
      Screen('Flip', window);
      WaitSecs(intStimSecs);
      
      % Zeitmessung der first Fixation - STARTPUNKT
      timeStartFirstFixation = GetSecs();
      
      outcome=0;
      
      
      %% ----------------------------------------------------------------------
      %                       Fixation
      %---------------------------------------------------------------------
      
      for frame = 1: grTimeFrames
            % Zeitmessung der vollen Fixation inkl. die FirstFixationWaittime - STARTPUNKT
            timeStartFixation = GetSecs();
            
            % gr¸ner oder roter Fixationspunkt wird pr‰sentiert (randomisiert)
            Screen('DrawDots', window, [fixXpos fixYpos], fixSizePix, dotColor, [], 2);
            Screen('DrawDots', window, [fixXpos fixYpos], 2, background, [], 2);
            
            %Online Eye-Tracking - Fixation
            if UseEyelink == 1
                  outcome = checkeyepos_v3(fixwindow,screenXpixels,screenYpixels,fixXpos,fixYpos,FixdotColor,1,eye_used);
                  if outcome == 0
                        disp(['Trial ' num2str(trial) ': Fixation interrupted!'])
                        Eyelink('Message','BAD_EYE');
                        skip_trial = 1;
                        localization = NaN;
                        %                 break;
                  end
            end
            
            %Keyboardabfrage zum vorzeitigen Abbrechen der Messung per ESC-Taste. Gemessene Trials bis dahin werden gespeichert
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyCode(escapeKey)
                  if UseEyelink == 1
                        Eyelink('StopRecording');
                        Eyelink('Message','stop experiment');
                  end
                  
                  %Daten speichern
                  if trial ~= 1
                        save([savePath edfName(:,1:size(edfName,2)-3) 'mat'],'data');
                  end
                  
                  %%% Eyelink beenden:
                  if UseEyelink == 1
                        WaitSecs(1);
                        Eyelink('CloseFile');
                        fprintf('EDF wird geschlossen\n');
                        WaitSecs(0.5);
                        % Eyelink-Datein speichern
                        Eyelink('ReceiveFile',edfNametemp,[savePath,edfName]);
                        Eyelink('Shutdown');
                  end

                  ShowCursor;
                  sca;
                  return
            end
            
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
      end
      timeEndFixation = GetSecs();
      
      % presentation Gap
      timeStartGap = GetSecs();
      Screen('FillRect', window, background, windowRect);
      Screen('Flip', window);
      WaitSecs(gapTimeSecs);    

      %% -------------------------------------------------------------------
      %                       Stimulus presentation
      %----------------------------------------------------------------------
      % add overlap
      for frame = 1 : overlapTimeFrames
      % Zeitmessung des Stimulus - STARTPUNKT
            timeStartStimulus = GetSecs();
            
            % Draw Fixdot and Stimdot simultanously 
            Screen('DrawDots', window, [fixXpos fixYpos], fixSizePix, dotColor, [], 2);
            Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, StimdotColor, [], 2);
            Screen('DrawDots', window, [dotXpos dotYpos], 2, background, [], 2);
      end
      
       % Stimdot only 
      for frame = 1 : stimTimeFrames
            
            % Zeitmessung des Stimulus - STARTPUNKT
           % timeStartStimulus = GetSecs();
            
            % Draw Stimdot
            Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, StimdotColor, [], 2);
            Screen('DrawDots', window, [dotXpos dotYpos], 2, background, [], 2);
            
            %Online Eye-Tracking - gesehen oder nicht
            if UseEyelink == 1
                  outcome = checkeyepos_v3(sacwindow,screenXpixels,screenYpixels,dotXpos,dotYpos,FixdotColor,1,eye_used);
                  % if outcome == 0 && frame >= sacc_delay
                  if frame <= (grTimeFrames + gapTimeFrames + stimTimeFrames)
                        if outcome == 1 && localization==0
                              disp(['Trial ' num2str(trial) ': Target seen!'])
                              localization = 1;
                        end
                  else
                        if outcome == 0
                              disp(['Trial ' num2str(trial) ': Fixation on target interrupted!'])
                              Eyelink('Message','BAD_EYE');
                              skip_trial = 1;
                              target_fixation = 0;
                              %                     break;
                        end
                  end
            end
            
            if frame == grTimeFrames + gapTimeFrames + stimTimeFrames && localization == 0
                  skip_trial = 1;
                  disp(['Trial ' num2str(trial) ': Target not seen, END trial!'])
                  %             break;
            end
            
            %Keyboardabfrage zum vorzeitigen Abbrechen der Messung per
            %ESC-Taste. Gemessene Trials bis dahin werden gespeichert
            [keyIsDown,secs,keyCode] = KbCheck;
            if keyCode(escapeKey)
                  if UseEyelink == 1
                        Eyelink('StopRecording');
                        Eyelink('Message','stop experiment');
                  end
                  
                  %Daten speichern
                  if trial ~= 1
                        save([savePath edfName(:,1:size(edfName,2)-3) 'mat'],'data');
                  end
                  
                  %%% Eyelink beenden:
                  if UseEyelink == 1
                        WaitSecs(1);
                        Eyelink('CloseFile');
                        fprintf('EDF wird geschlossen\n');
                        WaitSecs(0.5);
                        % Eyelink-Datein speichern
                        Eyelink('ReceiveFile',edfNametemp,[savePath,edfName]);
                        Eyelink('Shutdown');
                  end
                  
                  ShowCursor;
                  sca;
                  return
            end
            
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            
      end          
      
      % Status message about correct trials
      if skip_trial == 0
            disp(['Trial ' num2str(trial) ' korrekt!'])
            if UseEyelink==1
                  Eyelink('Message','Trial_correct');
            end
      end
      
      timeEndStimulus = GetSecs();
      
      %% ----------------------------------------------------------------------
      %                       Saving data
      %----------------------------------------------------------------------
      
      % Save predefined values    
      data(trial).angularDeg = angularDeg;
      data(trial).dotSizeDeg = dotSizeDeg;
      data(trial).fixSizeDeg = fixSizeDeg;
      data(trial).stimTimeSecs = stimTimeSecs;
      data(trial).gapTimeSecs = gapTimeSecs;
      data(trial).grTimeSecs = grTimeSecs;
      data(trial).monitorwidth = monitorwidth;
      data(trial).monitorheight = monitorheight;
      data(trial).monitordistance = monitordistance;
      data(trial).resolutionX = screenXpixels;
      data(trial).resolutionY = screenYpixels;
      data(trial).fixPos(1:2) = [fixXpos, fixYpos];                           % Record and save the fixdot coordinates
      data(trial).dotPos(1:2) = [dotXpos, dotYpos];                           % Record and save the actual position in px   
      
      % Save measured/calculated values
      data(trial).proanti = proanti;
      data(trial).stimPos = stimPos;
      data(trial).trialStart = trialStart;                                        
      data(trial).timeStartFixation = timeStartFixation; 
      ata(trial).timeEndFixation = timeEndFixation;
      data(trial).timeGapTotal = timeStartGap; 
      data(trial).timeStimulusTotal = timeStartStimulus;
      data(trial).timeEndStimulus = timeEndStimulus;
      
      if UseEyelink == 1
            %%% Eyelink-Befehle:
            Eyelink('Message','stop recording');
            data(trial).trialStop = GetSecs();
            WaitSecs(0.05); %%% Warten auf Eyelink
            Eyelink('StopRecording');
            WaitSecs(0.05); %%% Warten auf Eyelink
      else
            data(trial).trialStop = GetSecs(); %%% Endzeit des Trials auch dann speichern, wenn Eyelink nicht verwendet wird
      end
      
      data(trial).dotSeen = localization;
      data(trial).trialSkipped = skip_trial;
      data(trial).target_fixation = target_fixation;
      data(trial).frameLantecy = frame*ifi;    % Record and save duration of entire trial by using frame number
      
      % Driftcorrection, zum aktiven Start des n‰chsten Trials (hier jeden
      % Trial)
      if UseEyelink == 1 && mod(trial,1) == 0 && trial ~= numTrials
            Eyelink('DriftCorrStart',xCenter,yCenter,1,1,1);
      end
      
end

%% ----------------------------------------------------------------------
%                       Clean up
%----------------------------------------------------------------------
if UseEyelink == 1
      Eyelink('StopRecording');
      Eyelink('Message','stop experiment');
end

%Daten speichern
save([savePath edfName(:,1:size(edfName,2)-3) 'mat'],'data');

%%% Eyelink beenden:
if UseEyelink == 1
      WaitSecs(1);
      Eyelink('CloseFile');
      fprintf('EDF wird geschlossen\n');
      WaitSecs(0.5);
      % Eyelink-Datein speichern
      Eyelink('ReceiveFile',edfNametemp,[savePath,edfName]);
      Eyelink('Shutdown');
end


% End of experiment screen. We clear the screen once they have made their
% response
%DrawFormattedText(window, 'Experiment Finished \n\n Press Any Key To Exit',...
%      'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;
pause off;
sca;
