
function Ttest_results = vis_Ttest(block_path, stim_path)
%% input arguments
% stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
% block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/cluster_group.tsv');

%% import fft
all_fft = FFt(block_path, stim_path);
%% import spike times
SU_spike_times = Get_Spike_info(block_path);
%% import pref oris
prefSF_F0 = get_preferredoriandsf(block_path, stim_path);
%% import spont activity
spont_activity = get_spont_activity(block_path, stim_path);
%% import info about stim
ori_sf_fr = get_firing_rates (stim_path, block_path);
%sort stim info
for unit=1:size(all_fft)
    temp_ori_sf_fr = ori_sf_fr{unit,2};
    temp_ori_sf_fr_sort = sortrows(temp_ori_sf_fr);
    ori_sf_fr_sort{unit,2} = temp_ori_sf_fr_sort;
    ori_sf_fr_sort{unit,1} = ori_sf_fr{unit,1};
end
%compile list of unique stims
unique_stims = ori_sf_fr_sort{1,2};
unique_stims = unique_stims(1:12:end,1:2);

%% get indices for prefSF in unique stim list
%this corresponds to averaged fft in col 4 of fft. will use max of this to
%identify pref dir for tTEST
for unit = 1:size(all_fft,1)
    prefSF = prefSF_F0(unit,10);
    temp_indices_prefSF = find(unique_stims == prefSF);
    prefSF_indices{unit,2} = temp_indices_prefSF;
    prefSF_indices{unit,1} = all_fft{unit,1};
end

%% find preferred direction (direction with greatest averaged F0 in prefSF)
for unit = 1:size(all_fft,1)
    temp_indices_prefSF = prefSF_indices{unit,2};
    temp_avg_fft = all_fft{unit,4};
    avg_fft_prefSF = temp_avg_fft(temp_indices_prefSF,1);
    index_max_avg_fft_prefSF = find(avg_fft_prefSF == max(avg_fft_prefSF));
    index_pref_dir_at_prefSF = temp_indices_prefSF(index_max_avg_fft_prefSF,1);
    pref_dir = unique_stims(index_pref_dir_at_prefSF,2);
    all_pref_dir(unit,1) = pref_dir;
end

%% get indices for fft of pref dir + prefSF all tials
for unit = 1:size(all_fft,1)
    temp_prefSF = prefSF_F0(unit,10);
    temp_prefOri = all_pref_dir(unit,1);
    temp_ori_sf_fr_sort = ori_sf_fr_sort{unit,2};
    indices_pref_stim = find(temp_ori_sf_fr_sort(:,1) == temp_prefSF & temp_ori_sf_fr_sort(:,2) == temp_prefOri);
    all_indices_pref_stim{unit,2} = indices_pref_stim;
    all_indices_pref_stim{unit,1} = all_fft{unit,1};
end

%% get F0 of all presentations of pref ori and prefSF
for unit = 1:size(all_fft,1)
    temp_all_F0 = all_fft{unit,3};
    temp_prefStim_indices = all_indices_pref_stim{unit,2};
    prefStim_F0 = temp_all_F0(temp_prefStim_indices,1);
    all_indices_pref_stim{unit,3} = prefStim_F0;
end

%% run Ttest on blank F0 distribution vs. prefStim F0 distribution
for unit = 1:size(all_fft,1)
    temp_prefStim_F0 = all_indices_pref_stim{unit,3};
    temp_spont_actvity_fft = spont_activity{unit,4};
    temp_spont_actvity_f0 = temp_spont_actvity_fft(:,1);
[h,p] = ttest2(temp_prefStim_F0,temp_spont_actvity_f0);
    if (mean(temp_prefStim_F0)-mean(temp_spont_actvity_f0)) < 2
       h = 0;
    end
    Ttest_results(unit,:) = [h,p];
end 

%% run Hotelling T2 test and output P values
%compile array of all F0

end
