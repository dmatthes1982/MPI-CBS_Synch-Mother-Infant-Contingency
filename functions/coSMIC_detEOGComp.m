function [ data_eogcomp ] = coSMIC_detEOGComp( cfg, data_icacomp, data_sensor )
% COSMIC_CORRCOMP estimates components which have a high correlation
% (> 80%) with the EOGV and EOGH components of the original data
%
% Use as
%   [ data_eogcomp ] = COSMIC_corrComp( data_icacomp, data_sensor )
%
% where input data_icacomp has to be the results of COSMIC_ICA and 
% data_sensor the results of COSMIC_SELECTDATA
%
% The configuration options are
%   cfg.part      = participants which shall be processed: mother, child or both (default: both)
%   cfg.threshold = correlation threshold for marking eog-like components (range: 0...1, default: [0.8 0.8])
%                    one value for each participant
%
% This function requires the fieldtrip toolbox
%
% See also COSMIC_ICA and COSMIC_SELECTDATA

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part        = ft_getopt(cfg, 'part', 'both');
threshold  = ft_getopt(cfg, 'threshold', [0.8 0.8]);

if ~ismember(part, {'mother', 'child', 'both'})                             % check cfg.part definition
  error('cfg.part has to either ''mother'', ''child'' or ''both''.');
end

if (any(threshold < 0) || any(threshold > 1) )
  error('The threshold definition is out of range [0 1]');
end

% -------------------------------------------------------------------------
% Estimate correlating components
% -------------------------------------------------------------------------
if ismember(part, {'mother', 'both'})
  fprintf('<strong>Estimate EOG-correlating components at mother...</strong>\n');
  data_eogcomp.mother = corrComp(data_icacomp.mother, data_sensor.mother, threshold(1));
end

if ismember(part, {'child', 'both'})
  fprintf('<strong>Estimate EOG-correlating components at child...</strong>\n');
  data_eogcomp.child = corrComp(data_icacomp.child, data_sensor.child, threshold(2));
end

end

%--------------------------------------------------------------------------
% SUBFUNCTION which does the computation of the correlation coefficient
%--------------------------------------------------------------------------
function [ dataEOGComp ] = corrComp( dataICAComp, dataEOG, th )

numOfComp = length(dataICAComp.label);

eogvCorr = zeros(2,2,numOfComp);
eoghCorr = zeros(2,2,numOfComp);

eogvNum = strcmp('EOGV', dataEOG.label);
eoghNum = strcmp('EOGH', dataEOG.label);

for i=1:numOfComp
  eogvCorr(:,:,i) = corrcoef( dataEOG.trial{1}(eogvNum,:), ...
                              dataICAComp.trial{1}(i,:));
  eoghCorr(:,:,i) = corrcoef( dataEOG.trial{1}(eoghNum,:), ...
                              dataICAComp.trial{1}(i,:));
end

eogvCorr = squeeze(eogvCorr(1,2,:));
eoghCorr = squeeze(eoghCorr(1,2,:));

dataEOGComp.eogvCorr = eogvCorr;
dataEOGComp.eoghCorr = eoghCorr;

eogvCorr = abs(eogvCorr);
eoghCorr = abs(eoghCorr);

eogvCorr = (eogvCorr > th);
eoghCorr = (eoghCorr > th);

dataEOGComp.label      = dataICAComp.label;
dataEOGComp.topolabel  = dataICAComp.topolabel;
dataEOGComp.topo       = dataICAComp.topo;
dataEOGComp.unmixing   = dataICAComp.unmixing;
dataEOGComp.elements   = dataICAComp.label(eogvCorr | eoghCorr);

end
