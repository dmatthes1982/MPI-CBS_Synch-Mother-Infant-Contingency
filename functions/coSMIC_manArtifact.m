function [ cfgAllArt ] = coSMIC_manArtifact( cfg, data )
% COSMIC_MANARTIFACT - this function could be use to is verify the
% automatic detected artifacts remove some of them or add additional ones
% if required.
%
% Use as
%   [ cfgAllArt ] = coSMIC_manArtifact(cfg, data)
%
% where data has to be a result of COSMIC_SEGMENTATION
%
% The configuration options are
%   cfg.threshArt = output of COSMIC_AUTOARTIFACT (see file coSMIC_dxx_05a_autoart_yyy.mat)
%   cfg.manArt    = output of COSMIC_IMPORTDATASET (see file coSMIC_dxx_01b_manart_yyy.mat)
%   cfg.dyad      = number of dyad (only necessary for adding markers to databrowser view) (default: []) 
%
% This function requires the fieldtrip toolbox.
%
% See also COSMIC_SEGMENTATION, COSMIC_DATABROWSER, COSMIC_AUTOARTIFACT, 
% COSMIC_IMPORTDATASET

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
threshArt = ft_getopt(cfg, 'threshArt', []);
manArt    = ft_getopt(cfg, 'manArt', []);
dyad      = ft_getopt(cfg, 'dyad', []);

% -------------------------------------------------------------------------
% Initialize settings, build output structure
% -------------------------------------------------------------------------
cfg             = [];
cfg.dyad        = dyad;
cfg.channel     = {'all', '-V1', '-V2'};
cfg.ylim        = [-100 100];
cfgAllArt.mother = [];                                       
cfgAllArt.child = [];

% -------------------------------------------------------------------------
% Check Data
% -------------------------------------------------------------------------

fprintf('\n<strong>Search for artifacts with mother...</strong>\n');
cfg.part = 'mother';
cfg.threshArt = threshArt.mother.artfctdef.threshold.artifact;
cfg.manArt    = manArt.mother.artfctdef.xxx.artifact;
ft_warning off;
coSMIC_easyArtfctmapPlot(cfg, threshArt);                                   % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];                                             % --> first figure will be placed on the left side of figure 2
cfgAllArt.mother = coSMIC_databrowser(cfg, data);                           % show databrowser view in figure 2
close all;                                                                  % figure 1 will be closed with figure 2
cfgAllArt.mother = keepfields(cfgAllArt.mother, {'artfctdef', 'showcallinfo'});
  
fprintf('\n<strong>Search for artifacts with child...</strong>\n');
cfg.part = 'child';
cfg.threshArt = threshArt.child.artfctdef.threshold.artifact;
cfg.manArt    = manArt.child.artfctdef.xxx.artifact;
ft_warning off;
coSMIC_easyArtfctmapPlot(cfg, threshArt);                                   % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];                                             % --> first figure will be placed on the left side of figure 2
cfgAllArt.child = coSMIC_databrowser(cfg, data);                            % show databrowser view in figure 2
close all;                                                                  % figure 1 will be closed with figure 2
cfgAllArt.child = keepfields(cfgAllArt.child, {'artfctdef', 'showcallinfo'});
  
ft_warning on;

end
