function coSMIC_easyPSDplot(cfg, data)
% COSMIC_EASYPSDPLOT is a function, which makes it easier to plot the power
% spectral density within a specific condition of the coSMIC_DATASTRUCTURE
%
% Use as
%   coSMIC_easyPSDplot(cfg, data)
%
% where the input data have to be a result from COSMIC_PWELCH.
%
% The configuration options are 
%   cfg.part        = participant identifier, options: 'mother' or 'child' (default: 'mother')
%   cfg.condition   = condition (default: 4 or 'Baseline', see COSMIC_DATASTRUCTURE)
%   cfg.electrode   = number of electrodes (default: {'Cz'} repsectively [8])
%                     examples: {'Cz'}, {'F3', 'Fz', 'F4'}, [8] or [2, 1, 28]
%
% This function requires the fieldtrip toolbox
%
% See also COSMIC_PWELCH, COSMIC_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 'mother');
cond    = ft_getopt(cfg, 'condition', 4);
elec    = ft_getopt(cfg, 'electrode', {'Cz'});

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

if ~ismember(part, {'mother', 'child'})                                     % check cfg.part definition
  error('cfg.part has to either ''mother'' or ''child''.');
end

switch part                                                                 % extract selected participant
    case 'mother'
    data = data.mother;
  case 'child'
    data = data.child;
end

trialinfo = data.trialinfo;                                                 % get trialinfo
label     = data.label;                                                     % get labels 

cond    = coSMIC_checkCondition( cond );                                    % check cfg.condition definition    
if isempty(find(trialinfo == cond, 1))
  error('The selected dataset contains no condition %d.', cond);
else
  trialNum = find(ismember(trialinfo, cond));
end

if isnumeric(elec)                                                          % check cfg.electrode
  for i=1:length(elec)
    if elec(i) < 1 || elec(i) > 32
      error('cfg.elec has to be a numbers between 1 and 32 or a existing labels like {''Cz''}.');
    end
  end
else
  tmpElec = zeros(1, length(elec));
  for i=1:length(elec)
    tmpElec(i) = find(strcmp(label, elec{i}));
    if isempty(tmpElec(i))
      error('cfg.elec has to be a cell array of existing labels like ''Cz''or a vector of numbers between 1 and 32.');
    end
  end
  elec = tmpElec;
end

% -------------------------------------------------------------------------
% Plot power spectral density (PSD)
% -------------------------------------------------------------------------
plot(data.freq, squeeze(data.powspctrm(trialNum, elec,:)));                 %#ok<FNDSB>
labelString = strjoin(data.label(elec), ',');
title(sprintf('PSD - Part.: %s - Cond.: %d - Elec.: %s', ...
        part, cond, labelString));

xlabel('frequency in Hz');                                                  % set xlabel
ylabel('PSD');                                                              % set ylabel

end
