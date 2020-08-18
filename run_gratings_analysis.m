%% this script runs all functions to analyze gratings recordings
% takes about 60 sec for one run
%% input arguments. will need to change these for each run or optimize for batch analysis
stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/');

%% get stim info
sf_ori_time = get_stim_info(stim_path);

%% get spike times for single units
SU_spike_times = Get_Spike_info(block_path);

%% get firing rate info
ori_sf_fr = get_firing_rates (stim_path, block_path);

%% get spontaneous firing rates
spont_activity = get_spont_activity(block_path, stim_path);

%% get preferred SF
prefSF_F0 = get_preferredoriandsf(block_path, stim_path);

%% get fft
all_fft = FFt(block_path, stim_path);

%% get gOSI
all_gOSI = get_gosi(block_path, stim_path);

%% run Ttest to see if units are significantly visually evoked
Ttest_results = vis_Ttest(block_path, stim_path);

%% run Hottelings Ttest to see if units are significalty OS
all_P_Hottelings = OS_Ttest(block_path, stim_path);

 

%% define and fill final output table (gratings_analysis)
for unit = 1:size(all_fft,1)
gratings_analysis(unit,:) = [all_fft{unit,1} Ttest_results(unit,1) all_P_Hottelings(unit,1) spont_activity{unit,5} prefSF_F0(unit,10) all_gOSI(unit,2) all_gOSI(unit,3)];
end

%% save to excel file in same folder as block path
filename = 'gratings_analysis.xlsx'; %name of sheet to output to 
[~,~,raw] = xlsread(filename); %reads sheet and collects info in raw
num_occupied_rows = size(raw,1)+2;
num_occupied_rows = num2str(num_occupied_rows);
num_occupied_rows = strcat('A',num_occupied_rows); %gets second empty row so that we can add multiple datasets to the same spreadsheet without confusion


writematrix(gratings_analysis, filename, 'Range', num_occupied_rows); %writes output datatable to excel sheet

