function [ cfgArtifacts ] = coSMIC_databrowser( cfg, data )
% COSMIC_DATABROWSER displays a certain joint attention imitation project 
% dataset using a appropriate scaling.
%
% Use as
%   coSMIC_databrowser( cfg, data )
%
% where the input can be the result of COSMIC_IMPORTDATASET,
% COSMIC_PREPROCESSING or COSMIC_SEGMENTATION
%
% The configuration options are
%   cfg.dyad        = number of dyad (no default value)
%   cfg.part        = number of participant, 1 = mother, 2 = child (default: 1)
%   cfg.artifact    = Nx2 matrix with artifact segments (default: [])
%   cfg.channel     = channels of interest (default: 'all')
%   cfg.ylim        = vertical scaling (default: [-100 100]);
%   cfg.blocksize   = duration in seconds for cutting the data up (default: [])
%   cfg.plotevents  = 'yes' or 'no' (default: 'yes'), if it is no raw data
%                     you have to specify cfg.dyad otherwise the events
%                     will be not found and therefore not plotted
%
% This function requires the fieldtrip toolbox
%
% See also COSMIC_IMPORTDATASET, COSMIC_PREPROCESSING, COSMIC_SEGMENTATION, 
% COSMIC_DATASTRUCTURE, FT_DATABROWSER

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
dyad        = ft_getopt(cfg, 'dyad', []);
part        = ft_getopt(cfg, 'part', 1);
artifact    = ft_getopt(cfg, 'artifact', []);
channel     = ft_getopt(cfg, 'channel', 'all');
ylim        = ft_getopt(cfg, 'ylim', [-100 100]);
blocksize   = ft_getopt(cfg, 'blocksize', []);
plotevents  = ft_getopt(cfg, 'plotevents', 'yes');

if isempty(dyad)                                                            % if dyad number is not specified
  event = [];                                                               % the associated markers cannot be loaded and displayed
else                                                                        % else, load the stimulus markers 
  source = '/data/pt_01905/eegData/DualEEG_coSMIC_rawData/';
  filename = sprintf('coSMIC_all_P%02d.vhdr', dyad);
  path = strcat(source, filename);
  event = ft_read_event(path);                                              % read stimulus markers
  
  eventCell = squeeze(struct2cell(event))';                   
  if any(strcmp(eventCell(:,2), 'S128'))                                    % check if stimulus markers are effected with the 'S128' error 
    match     = ~strcmp(eventCell(:,2), 'S128');                            % correct the error  
    event     = event(match);
    eventCell = squeeze(struct2cell(event))';
    eventNum  = zeros(size(eventCell, 1) - 2, 1);
    for i=3:size(eventCell, 1)
      eventNum(i-2) = sscanf(eventCell{i,2},'S%d');    
    end
    match = eventNum > 128;
    eventNum(match) = eventNum(match) - 128;
    for i=3:size(eventCell, 1)
      event(i).value = sprintf('S%3d', eventNum(i-2));    
    end
  end
end

if ~ismember(part, [1,2])                                                   % check cfg.part definition
  error('cfg.part has to either 1 or 2, 1 = mother, 2 = child');
end

% -------------------------------------------------------------------------
% Configure and start databrowser
% -------------------------------------------------------------------------
cfg                               = [];
cfg.ylim                          = ylim;
cfg.blocksize                     = blocksize;
cfg.viewmode                      = 'vertical';
cfg.artfctdef.threshold.artifact  = artifact;
cfg.continuous                    = 'no';
cfg.channel                       = channel;
cfg.plotevents                    = plotevents;
cfg.event                         = event;
cfg.showcallinfo                  = 'no';

fprintf('Databrowser - Participant: %d\n', part);

switch part
  case 1
    if nargout > 0
      cfgArtifacts = ft_databrowser(cfg, data.mother);
    else
      ft_databrowser(cfg, data.mother);
    end
    
  case 2
    if nargout > 0
      cfgArtifacts = ft_databrowser(cfg, data.child);
    else
      ft_databrowser(cfg, data.child);
    end
    
end

end
