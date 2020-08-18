function ori_sf_fr = kk_get_firing_rates (stim_path, block_path)

%%Identify stim and block paths of interest
% stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
% block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/cluster_group.tsv');

%%import information about stimulus 
sf_ori_time = get_stim_info(stim_path);

%% import spiking information
SU_spike_times = Get_Spike_info(block_path);

%% define output table
numberofunits = size(SU_spike_times, 2);
ori_sf_fr = cell(numberofunits, 2);

%% get firing rate for each ori/sf combo
for j=1:size(SU_spike_times,1) %unit
     for i=1:size(sf_ori_time) %stim trial
        temp_onset_bin = (sf_ori_time(i,3)*24414);
        temp_offset_bin = (sf_ori_time(i,4)*24414);
        temp_spike_time_bin = cell2mat(SU_spike_times(j,3));
        temp_fr_bin = find(temp_spike_time_bin > temp_onset_bin & temp_spike_time_bin < temp_offset_bin);
        %temp_fr1 = find(temp_spike_time_bin(:,1) > temp_onset_bin);
        %temp_fr2 = find(temp_spike_time_bin(:,1) < temp_offset_bin);
        %temp_fr_true = 1+(temp_fr1(1,1)-temp_fr2(end,1));
        sf_ori_time(i,5) = size(temp_fr_bin,1);
     end
         ori_sf_fr{j,2} = sf_ori_time; %fills col2 with SF-Ori-ts-fr table
         ori_sf_fr{j,1} = cell2mat(SU_spike_times(j,1)); %fills col1 with SUids
end

end 