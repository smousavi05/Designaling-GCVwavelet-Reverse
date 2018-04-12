%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The following is a demo to run the modified version of GCV Designaling 
%   algorithm for removing the signal for preprocessing ambient noise data
%   presented in:
%
%   Mousavi, S. M., and C. A. Langston (2017). Automatic Noise-Removal/
%   Signal-Removal Based on the General-Cross-Validation Thresholding in 
%   Synchrosqueezed domains, and its application on earthquake data, 
%   Geophysics.82(4), V211-V227 doi: 10.1190/geo2016-0433.1
%
%   Mousavi, S. M., and C. A. Langston, (2016a). Fast and novel microseismic 
%   detection using time-frequency analysis. SEG Technical Program Expanded 
%   Abstracts 2016: pp. 2632-2636. doi: 10.1190/segam2016-13262278.1                                                                                                                                                               
%
%  The modified version runs on contineous wavelet transform and just include
%  pre-processing and the main thresholding steps based on GCV and softThresholding.
%  Thus it is faster than the original algorithm. This algorithm does not rely on any
%  arrival time estimation. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------- 
%   S. Mostafa Mousavi 
%   mmousavi@stanford.edu
%   Last time modified: November, 22, 2017
%---------------------------------------------------------------------------

%%%   Copyright (c) 2015 S. Mostafa Mousavi
%%%   All rights reserved.
%%%   This software is provided for non-commercial research purposes only. 
%%%   No warranty is implied by this distribution. Permission is hereby granted
%%%   without written agreement and without license or royalty fees, to use, 
%%%   copy, modify, and distribute this code and its documentation, provided 
%%%   that the copyright notice in its entirety appear in all copies of this 
%%%   code, and the original source of this code, 

clear all
close all

% Parameters for Calculate the wavelet transform -
opt.type = 'morlet';         % Type od the mother wavelet used for CWT calculation: 'morlet' 'shannon' 'mhat' 'hhat'
opt.padtype = 'symmetric';   % padded via symmetrization
opt.rpadded = 1;
opt.nv = 16;                 % Number of voices. You can sellect 8,16,32,64.

% Guassian correction factor. This corrects the uncertainties for the 
% estimation of the guassianity and amplifies the pre-processing effects.
% It should be selected highh enough to remove the strong noises outside
% of the signal's frequency band but not too high to remove signal's energy. 
% value of 1.0 means no correction. 
opt.gc=3;

 
%load('syntNoisy3_z.mat');
% data.noisy = syntNoisy3_z;
% data.t = linspace(0,(100),length(data.noisy));
% data.dt = 0.01;

% Read the noisy data 
[data.t,data.noisy,data.hdr] = read_sac('XD.A01..BHZ.064.SAC');
data.dt = data.hdr.times.delta        % delta
d1 = data.noisy;

% Since thecurrent version of the code can not handel overlapping winows we
% implement the algorithm by repeating the process using two windows of
% different sizes (one larger than the largest event in the waveform and one
% smaller window which its lenght is not a multiplication of the larger window size)
% however this makes the code slower but so far this is the easiest
% soloution

% processing long duration data is done in moving window fasion
opt.wsiz = 500; % wondow size (sec), needs to be longer than the length of typical events that you have in your data

tic
dn =gcvThreshR(data,opt);
toc

data.noisy = dn.xgcv;

opt.wsiz = 55; % wondow size (sec), needs to be longer than the length of typical events that you have in your data
 
tic
dn =gcvThreshR(data,opt);
toc

figure, 
subplot(2,1,1),
plot(d1, 'b');
grid on
title('Noisy Record ','Rotation',0,'FontSize',14);
xlabel({'Sample'},'FontSize',12); 
ylabel('Amplitude (count)','FontSize',12)


subplot(2,1,2),
plot(dn.xgcv, 'b');
grid on
title('Noise ','Rotation',0,'FontSize',14);
xlabel({'Sample'},'FontSize',12); 
ylabel('Amplitude (count)','FontSize',12)

