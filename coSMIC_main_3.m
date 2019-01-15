%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '02_preproc/';
  cfg.filename  = 'coSMIC_d01_02_preproc';
  sessionStr    = sprintf('%03d', coSMIC_getSessionNum( cfg ));             % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01888/eegData/DualEEG_coSMIC_processedDataOld/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in preprocessed data folder
  sourceList    = dir([strcat(desPath, '02_preproc/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('coSMIC_d%d_02_preproc_', sessionStr, '.mat'));
  end
end

%% part 3
% ICA decomposition
% Processing steps:
% 1. Concatenated preprocessed trials to a continuous stream
% 2. Detect and reject transient artifacts (200uV delta within 200 ms. 
%    The window is shifted with 100 ms, what means 50 % overlapping.)
% 3. Concatenated cleaned data to a continuous stream
% 4. ICA decomposition
% 5. Extract EOG channels from the cleaned continuous data

cprintf([0,0.6,0], '<strong>[3] - ICA decomposition</strong>\n');
fprintf('\n');

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('coSMIC_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('<strong>Dyad %d</strong>\n', i);
  fprintf('Load preprocessed data...\n');
  coSMIC_loadData( cfg );
  
  % Concatenated preprocessed trials to a continuous stream
  cfg             = [];
  cfg.part        = 'mother';
  
  data_continuous = coSMIC_concatData( cfg, data_preproc );
  
  clear data_preproc
  fprintf('\n');
  
  % Detect and reject transient artifacts (200uV delta within 200 ms. 
  % The window is shifted with 100 ms, what means 50 % overlapping.)
  cfg             = [];
  cfg.part        = 'mother';
  cfg.channel     = {'all', '-EOGV', '-EOGH', '-REF'};                      % use all channels for transient artifact detection expect EOGV, EOGH and REF
  cfg.method      = 'range';
  cfg.sliding     = 'no';
  cfg.continuous  = 'yes';
  cfg.trllength   = 200;                                                    % minimal subtrial length: 200 msec
  cfg.overlap     = 50;                                                     % 50 % overlapping
  cfg.range       = 200;                                                    % 200 uV
   
  cfg_autoart     = coSMIC_autoArtifact(cfg, data_continuous);
   
  cfg           = [];
  cfg.part      = 'mother';
  cfg.artifact  = cfg_autoart;
  cfg.reject    = 'partial';                                                % partial rejection
  cfg.target    = 'single';                                                 % target of rejection
  
  data_cleaned  = coSMIC_rejectArtifacts(cfg, data_continuous);
  
  clear data_continuous cfg_autoart
  fprintf('\n');
  
  % Concatenated cleaned data to a continuous stream
  cfg             = [];
  cfg.part        = 'mother';
  
  data_cleaned = coSMIC_concatData( cfg, data_cleaned );
  
  % ICA decomposition
  cfg               = [];
  cfg.part          = 'mother';
  cfg.channel       = {'all', '-EOGV', '-EOGH', '-REF'};                    % use all channels for EOG decomposition expect EOGV, EOGH and REF
  cfg.numcomponent  = 'all';
  
  data_icacomp      = coSMIC_ica(cfg, data_cleaned);
  fprintf('\n');
  
  % export the determined ica components in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03a_icacomp/');
  cfg.filename    = sprintf('coSMIC_d%02d_03a_icacomp', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The ica components of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  coSMIC_saveData(cfg, 'data_icacomp', data_icacomp);
  fprintf('Data stored!\n');
  clear data_icacomp
  
  % Extract EOG channels from the cleaned continuous data 
  cfg               = [];
  cfg.part          = 'mother';
  cfg.channel       = {'EOGV', 'EOGH'};
  cfg.trials        = 'all';
  data_eogchan      = coSMIC_selectdata(cfg, data_cleaned);
  
  clear data_cleaned
  fprintf('\n');
  
  % export the EOG channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03b_eogchan/');
  cfg.filename    = sprintf('coSMIC_d%02d_03b_eogchan', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The EOG channels of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  coSMIC_saveData(cfg, 'data_eogchan', data_eogchan);
  fprintf('Data stored!\n\n');
  clear data_eogchan
end

%% clear workspace
clear file_path cfg sourceList numOfSources i j
