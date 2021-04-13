function [] = ELPH_initEL2(filename)

%%% Von Einhäuser-Gruppe übernommen (auf anderes Setup angepasst)
%%% Initiiert die Eyelink-Routinen

% open link
if ~Eyelink('isconnected');
    Eyelink('initialize','PsychEyelinkDispatchCallback');
end


status = Eyelink('OpenFile', filename);
if status~=0
	Eyelink('Shutdown');
    clear mex;
	error('Cannot create %s (error: %d)- eyelink shutdown', status,filename);
end


% send standard parameters
Eyelink('command', ['add_file_preamble_text ','EL2, DiagSNARC, PNH, original name PNH']);
Eyelink('command', 'calibration_type = HV9');
Eyelink('command', 'saccade_velocity_threshold = 30');
Eyelink('command', 'saccade_acceleration_threshold = 8000');
Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,BUTTON,BLINK,SACCADE');
Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA,HREF,GAZERES,STATUS');
% Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS');

Eyelink('command', 'button_function 5 ''accept_target_fixation''');
Eyelink('command', 'sample_rate = %d',500);
Eyelink('command', 'corneal_mode = NO'); % 
Eyelink('command', 'binocular_enabled = YES');
Eyelink('command', 'cal_repeat_first_target = YES');
Eyelink('command', 'val_repeat_first_target = YES');
Eyelink('command', 'use_ellipse_fitter = NO'); % no = centroid, yes = ellipse 

%%%%%%%%%%% kleiner Monitor Einstellungen
%%% Physical position of LED markers in millimeters. Measured with right
%%% and up from screen center being positiv, and left and down being
%%% negative. Order:
% 1    3
% 2    4
Eyelink('command', 'marker_phys_coords=-440,460, -440,-460, 440,460, 440,-460');
%%% Measure the distance of the visible part of the display screen edge
%%% relative to the center of the screen (in millimeters) 
%%% <left>, <top>, <right>, <bottom>
Eyelink('command', 'screen_phys_coords=-525.0,295.0,525.0,-295.0');
Eyelink('command', 'screen_pixel_coords=0,0,1920,1080');
Eyelink('command', 'simulation_screen_distance=470'); % (in mm)
Eyelink('command', 'calibration_area_proportion = 0.4 0.4'); % notwendig, da sonst sehr weit am Rand des Blickfeldes





% %%%%%%%%%%% alte Standardeinstellungen
% %%% Physical position of LED markers in millimeters. Measured with right
% %%% and up from screen center being positiv, and left and down being
% %%% negative. Order:
% % 1    3
% % 2    4
% Eyelink('command', 'marker_phys_coords=-380,690, -380,-690, 380,690, 380,-690');
% %%% Measure the distance of the visible part of the display screen edge
% %%% relative to the center of the screen (in millimeters) 
% %%% <left>, <top>, <right>, <bottom>
% Eyelink('command', 'screen_phys_coords=-800,600,800,-600');
% Eyelink('command', 'screen_pixel_coords=0,0,1152,864');
% Eyelink('command', 'simulation_screen_distance=1140'); %(in mm)

% %%%%%%%%%%% kleiner Monitor Einstellungen
% %%% Physical position of LED markers in millimeters. Measured with right
% %%% and up from screen center being positiv, and left and down being
% %%% negative. Order:
% % 1    3
% % 2    4
% Eyelink('command', 'marker_phys_coords=-234,171, -234,-67, 227,172, 227,-69');
% %%% Measure the distance of the visible part of the display screen edge
% %%% relative to the center of the screen (in millimeters) 
% %%% <left>, <top>, <right>, <bottom>
% Eyelink('command', 'screen_phys_coords=-200.0,152.5,200.0,-152.5');
% Eyelink('command', 'screen_pixel_coords=0,0,1024,768');
% Eyelink('command', 'simulation_screen_distance=710'); % (in mm)




% Snd('Open'); %%% Open Sound Device! Notwendig???