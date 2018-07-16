function [ data ] = INFADI_bpFiltering( cfg, data) 
% INFADI_BPFILTERING applies a specific bandpass filter to every channel in
% the INFADI_DATASTRUCTURE
%
% Use as
%   [ data ] = INFADI_bpFiltering( cfg, data)
%
% where the input data have to be the result from INFADI_IMPORTDATASET,
% INFADI_PREPROCESSING or INFADI_SEGMENTATION 
%
% The configuration options are
%   cfg.bpfreq      = passband range [begin end] (default: [1.9 2.1])
%   cfg.filtorder   = define order of bandpass filter (default: 250)
%   cfg.channel     = channel selection (default: {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2'}
%
% This function is configured with a fixed filter order, to generate
% comparable filter charakteristics for every operating point.
%
% This function requires the fieldtrip toolbox
%
% See also INFADI_IMPORTDATASET, INFADI_PREPROCESSING, INFADI_SEGMENTATION, 
% INFADI_DATASTRUCTURE, FT_PREPROCESSING

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
bpfreq    = ft_getopt(cfg, 'bpfreq', [1.9 2.1]);
order     = ft_getopt(cfg, 'filtorder', 250);
channel   = ft_getopt(cfg, 'channel', {'all', '-REF', '-EOGV', '-EOGH', ... % apply bandpass to every channel except REF, EOGV, EOGH, V1 and V2
                                       '-V1', '-V2' });

% -------------------------------------------------------------------------
% Filtering settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.trials          = 'all';                                                % apply bandpass to all trials
cfg.channel         = channel;
cfg.bpfilter        = 'yes';
cfg.bpfilttype      = 'fir';                                                % use a simple fir
cfg.bpfreq          = bpfreq;                                               % define bandwith
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output
cfg.bpfiltord       = order;                                                % define filter order

centerFreq = (bpfreq(2) + bpfreq(1))/2;

% -------------------------------------------------------------------------
% Bandpass filtering
% -------------------------------------------------------------------------
data.centerFreq = [];

fprintf('<strong>Apply bandpass to experimenters data with a center frequency of %g Hz...</strong>\n', ...           
          centerFreq);
data.experimenter   = ft_preprocessing(cfg, data.experimenter);        
          
fprintf('<strong>Apply bandpass to childs data with a center frequency of %g Hz...</strong>\n', ...           
          centerFreq);
data.child   = ft_preprocessing(cfg, data.child);
  
data.centerFreq = centerFreq;
data.bpFreq = bpfreq;

end
