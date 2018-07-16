function [ data ] = coSMIC_selectdata( cfg, data )
% COSMIC_SELECTDATA extracts specified channels from a dataset
%
% Use as
%   [ data  ] = coSMIC_selectdata( cfg, data )
%
% where input data can be nearly every sensor space data
%
% The configuration options are
%   cfg.part    = participants which shall be processed: mother, child or both (default: both)
%   cfg.channel = 1xN cell-array with selection of channels (default = 'all')
%   cfg.trials  = 1xN vector of condition numbers or 'all' (default = 'all')
%
% This function requires the fieldtrip toolbox.
%
% See also COSMIC_PREPROCESSING, COSMIC_SEGMENTATION, COSMIC_CONCATDATA,
% COSMIC_BPFILTERING

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 'both');                                   % participant selection
channel = ft_getopt(cfg, 'channel', 'all');
trials  = ft_getopt(cfg, 'trials', 'all');

if ~ismember(part, {'mother', 'child', 'both'})                             % check cfg.part definition
  error('cfg.part has to either ''mother'', ''child'' or ''both''.');
end

% -------------------------------------------------------------------------
% Estimate trial indices
% ------------------------------------------------------------------------
if ischar(trials)
  trialsPart1 = trials;
  trialsPart2 = trials;
else
  if ismember(part, {'mother', 'both'})
    val = ismember(data.mother.trialinfo, trials);                          % estimate trial indices
    trialsPart1 = find(val);
  end

  if ismember(part, {'child', 'both'})
    val = ismember(data.child.trialinfo, trials);                           % estimate trial indices
    trialsPart2 = find(val);
  end
end

% -------------------------------------------------------------------------
% Channel extraction
% -------------------------------------------------------------------------
cfg              = [];
cfg.channel      = channel;
cfg.showcallinfo = 'no';

if ismember(part, {'mother', 'both'})
  cfg.trials = trialsPart1;
  dataTmp.mother = ft_selectdata(cfg, data.mother);
end

if ismember(part, {'child', 'both'})
  cfg.trials = trialsPart2;
  dataTmp.child = ft_selectdata(cfg, data.child);
end

data = dataTmp;

end
