function coSMIC_easyTopoplot(cfg , data)
% coSMIC_EASYTOPOPLOT is a function, which makes it easier to plot the
% topographic distribution of the power over the head.
%
% Use as
%   coSMIC_easyTopoplot(cfg, data)
%
%  where the input data have to be a result from coSMIC_PWELCH.
%
% The configuration options are 
%   cfg.part        = participant identifier, options: 'mother' or 'child' (default: 'mother')   
%   cfg.condition   = condition (default: 11 or 'DFreePlay', see coSMIC_DATASTRUCTURE)
%   cfg.freqrange   = limits for frequency in Hz (e.g. [6 9] or 10) (default: 10) 
%
% This function requires the fieldtrip toolbox
%
% See also coSMIC_PWELCH, coSMIC_DATASTRUCTURE

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part        = ft_getopt(cfg, 'part', 'mother');
condition   = ft_getopt(cfg, 'condition', 11);
freqrange   = ft_getopt(cfg, 'freqrange', 10);

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

if ~ismember(part, {'mother', 'child'})                                     % check cfg.part definition
  error('cfg.part has to be either ''mother'' or ''child''.');
end

switch part                                                                 % extract selected participant
  case 'mother'
    data = data.mother;
  case 'child'
    data = data.child;
end

trialinfo = data.trialinfo;                                                 % get trialinfo

condition = coSMIC_checkCondition( condition );                             % check cfg.condition definition    
if isempty(find(trialinfo == condition, 1))
  error('The selected dataset contains no condition %d.', condition);
else
  trialNum = ismember(trialinfo, condition);
end

if numel(freqrange) == 1
  freqrange = [freqrange freqrange];
end

% -------------------------------------------------------------------------
% Generate topoplot
% -------------------------------------------------------------------------
load(sprintf('%s/../layouts/mpi_customized_acticap32.mat', filepath), 'lay');

cfg               = [];
cfg.parameter     = 'powspctrm';
cfg.xlim          = freqrange;
cfg.zlim          = 'maxmin';
cfg.trials        = trialNum;
cfg.colormap      = 'jet';
cfg.marker        = 'on';
cfg.colorbar      = 'yes';
cfg.style         = 'both';
cfg.gridscale     = 200;                                                    % gridscale at map, the higher the better
cfg.layout        = lay;
cfg.showcallinfo  = 'no';

ft_topoplotER(cfg, data);

title(sprintf('Power - %s - Condition %d - Freqrange [%d %d]', ...
                part, condition, freqrange));

set(gcf, 'Position', [0, 0, 750, 550]);
movegui(gcf, 'center');
              
end
