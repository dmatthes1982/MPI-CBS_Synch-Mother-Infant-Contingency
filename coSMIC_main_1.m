%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01a_raw/';
  cfg.filename  = 'coSMIC_d01_01a_raw';
  sessionNum    = coSMIC_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('srcPath', 'var')
  srcPath = '/data/pt_01888/eegData/DualEEG_coSMIC_rawData/';               % source path to raw data
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01888/eegData/DualEEG_coSMIC_processedDataOld/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, '/*.vhdr']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, 'coSMIC_all_P%d.vhdr');
  end
end

%% part 1
% 1. import data from brain vision eeg files and bring it into an order
% 2. select corrupted channels 
% 3. repair corrupted channels

cprintf([0,0.6,0], '<strong>[1] - Data import and repairing of bad channels</strong>\n');
fprintf('\n');

%% import data from brain vision eeg files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  cfg               = [];
  cfg.path          = srcPath;
  cfg.dyad          = i;
  cfg.continuous    = 'no';
  cfg.prestim       = 0;
  cfg.rejectoverlap = 'yes';
  
  fprintf('<strong>Import data of dyad %d</strong> from: %s ...\n', i, cfg.path);
  ft_info off;
  [data_raw, cfg_manart] = coSMIC_importDataset( cfg );
  ft_info on;

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('coSMIC_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The RAW data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  coSMIC_saveData(cfg, 'data_raw', data_raw);
  fprintf('Data stored!\n\n');
  clear data_raw
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01b_manart/');
  cfg.filename    = sprintf('coSMIC_d%02d_01b_manart', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The manual defined artifacts of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  coSMIC_saveData(cfg, 'cfg_manart', cfg_manart);
  fprintf('Data stored!\n\n');
  clear cfg_manart
end

fprintf('<strong>Repairing of corrupted channels</strong>\n\n');

% Create settings file if not existing
settings_file = [desPath '00_settings/' ...
                  sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  coSMIC_createTbl(cfg);                                                    % create settings file
end

% Load settings file
T = readtable(settings_file);
warning off;
T.dyad(numOfPart) = numOfPart;
warning on;

%% repairing of corrupted channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);
  
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('coSMIC_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;
    
  fprintf('Load raw data...\n');
  coSMIC_loadData( cfg );
  
  % concatenated raw trials to a continuous stream
  cfg = [];
  cfg.part = 'both';

  data_continuous = coSMIC_concatData( cfg, data_raw );

  fprintf('\n');

  % detect noisy channels automatically
  data_noisy = coSMIC_estNoisyChan( data_continuous );

  fprintf('\n');

  % select corrupted channels
  data_badchan = coSMIC_selectBadChan( data_continuous, data_noisy );
  clear data_noisy

  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01c_badchan/');
  cfg.filename    = sprintf('coSMIC_d%02d_01b_badchan', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Bad channels of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  coSMIC_saveData(cfg, 'data_badchan', data_badchan);
  fprintf('Data stored!\n\n');
  clear data_continuous
  
  % add bad labels of bad channels to the settings file
  if isempty(data_badchan.mother.badChan)
    badChanMother = {'---'};
  else
    badChanMother = {strjoin(data_badchan.mother.badChan,',')};
  end
  if isempty(data_badchan.child.badChan)
    badChanChild = {'---'};
  else
    badChanChild = {strjoin(data_badchan.child.badChan,',')};
  end
  warning off;
  T.badChanMother(i) = badChanMother;
  T.badChanChild(i) = badChanChild;
  warning on;
  
  % repair corrupted channels
  data_repaired = coSMIC_repairBadChan( data_badchan, data_raw );
  
  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01d_repaired/');
  cfg.filename    = sprintf('coSMIC_d%02d_01d_repaired', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Repaired raw data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  coSMIC_saveData(cfg, 'data_repaired', data_repaired);
  fprintf('Data stored!\n\n');
  clear data_repaired data_raw data_badchan 
end

% store settings table
delete(settings_file);
writetable(T, settings_file);

%% clear workspace
clear file_path cfg sourceList numOfSources i T badChanMother ...
      badChanChild settings_file
