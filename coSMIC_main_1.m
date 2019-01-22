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
  desPath = '/data/pt_01888/eegData/DualEEG_coSMIC_processedData/';         % destination path for processed data  
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

cprintf([0,0.6,0], '<strong>[1] - Data import</strong>\n');
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



%% clear workspace
clear file_path cfg sourceList numOfSources i
