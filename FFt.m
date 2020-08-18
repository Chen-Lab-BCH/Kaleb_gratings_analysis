function all_fft = KKFFt(block_path, stim_path)
%% Import neccessary items
%input arguments
% stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
% block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/cluster_group.tsv');

%import spike times
SU_spike_times = Get_Spike_info(block_path);

%import firing rates
ori_sf_fr = get_firing_rates (stim_path, block_path);

%import stimtimes
sf_ori_time = get_stim_info(stim_path);

%sort stimtimes by stim type
sf_ori_time_sort = sortrows(sf_ori_time);

%%import spontaneous activity
spont_activity = get_spont_activity(block_path, stim_path);

%% get firing rates for 100ms bins for each stim run. store in su_spike_times
%col 4
% for  t=1:size(SU_spike_times,1)
%    for i=1:size(sf_ori_time_sort,1) 
%      for j=0:1:14
%             temp_sf_ori_time_sort(i,1) = sf_ori_time_sort(i,3)*24414;
%             temp_onset_bins = ((temp_sf_ori_time_sort(i,1) + 2441.4*j));
%             temp_offset_bins = ((temp_onset_bins + 2441.4));
%             temp_spike_times = SU_spike_times{t,3}; %convert to seconds
%             temp_fr_bin = find(temp_spike_times >= temp_onset_bins & temp_spike_times < temp_offset_bins);
%             temp_spont_activity = spont_activity{t,3}; 
%             sf_ori_time_sort(i,j+5) = (size(temp_fr_bin,1));
%             if sf_ori_time_sort(i,j+5)>0 %subtract spont activity
%                sf_ori_time_sort(i,j+5) = sf_ori_time_sort(i,j+5) - (temp_spont_activity/10);
%             end
% %             if sf_ori_time_sort(i,j+5)<0 %set negative rates to 0
% %                 sf_ori_time_sort(i,j+5) = 0;
% %             end
%      end
%      SU_spike_times{t,4} = sf_ori_time_sort;
%    end
% end

for unit=1:size(SU_spike_times,1)
    for trial=1:size(sf_ori_time_sort,1)
        edges = [sf_ori_time_sort(trial,3)*24414:2441.4:sf_ori_time_sort(trial,4)*24414];
        temp_counts(1,:) = histcounts(SU_spike_times{unit,3}, edges);%-spont_activity{unit,3}/10;
        sf_ori_time_sort(trial, 5:19) = temp_counts;
        sf_ori_time_sort(sf_ori_time_sort<0) = 0; %set negative values to 0
    end
     SU_spike_times{unit,4} = sf_ori_time_sort;
     
end





%% average fr's across each unique stim pair
%Takuma ffts this set
%doesn't change anything later on so I'll do it the other way 
for i=1:size(SU_spike_times,1)
   for j=0:53
   temp_bin_fr = SU_spike_times{i,4};
   average_bin_fr(j+1,:) = mean(temp_bin_fr(((1+12*j:12+12*j)), 5:19)); 
   all_averages = average_bin_fr;
    end 
   SU_spike_times{i,5} = average_bin_fr;
end



%% define fft table. cell1 is unit, cell2 is fft of all averaged data for unique stim combos.
%cell3 is f0, f1, f1/f0 respectively
all_fft = cell(size(SU_spike_times,1), 2);

%% fft raw bins and store in all_fft 
%col1 is unit id
%col2 is raw fft data
%constants from Celeste's analysis. regarding stim information
tempFreq = 2;
fft_int = 0.1;
stim_duration = 1.5; %TO DO get this from main script % subtract 0.3 to remove ON response when stim changes
nyq = 0.5/fft_int; %%% nyquist interval
freq_int = nyq / (0.5*stim_duration/fft_int);


for i=1:size(SU_spike_times,1) % #unit
    for j=1:648 % #stims
    temp_spikes = SU_spike_times{i,4};
    temp_spikes_only = temp_spikes(:,5:19)/0.1; %removes info about stim in col 1:4
    temp_fft(j,:) = abs(fft(temp_spikes_only(j,:)));
    temp_fft(j,:) = temp_fft(j,:)/size(temp_fft,2);
    end
    all_fft{i,2} = temp_fft;
    all_fft{i,1} = SU_spike_times{i,1};
end

% %% fft averaged bins and store in all_fft col7
% for i=1:size(SU_spike_times,1)
%     for j=1:54
%         temp_avg_spikes = SU_spike_times{i,5};
%         temp_fft_avg(j,:) = abs(fft(temp_avg_spikes(j,:)));
%     end
%     all_fft{i,7} = temp_fft_avg;
% end

%% get f1 and f0 


%get F0, F1, and F1/F0 from raw fft and store in all_fft col 3
for i=1:size(all_fft,1)
    for j=1:648
        temp_fft_bin = all_fft{i,2};
        temp_F0 = temp_fft_bin(j,1);
        temp_F1 = 2*temp_fft_bin(j,(1+tempFreq/freq_int));  %%% double to count both pos & neg frequency
        temp_all_fft(j,1) = temp_F0;
        temp_all_fft(j,2) = temp_F1;
        temp_all_fft(j,3) = temp_F1/temp_F0;
    end 
    all_fft{i,3} = temp_all_fft;
end
% 
% %% get F0, F1 from averaged fft
% % its exactly the same as raw fft averaged
% for i=1:size(all_fft,1)
%     for j=1:54
%         temp_fft_avg_bin = all_fft{i,7};
%         temp_F0_avg = temp_fft_avg_bin(j,1);
%         temp_F1_avg = 2*temp_fft_avg_bin(j,(1+tempFreq/freq_int)); %%% double to count both pos & neg frequency
%         temp_all_fft_avg(j,1) = temp_F0_avg;
%         temp_all_fft_avg(j,2) = temp_F1_avg;
%     end
%     all_fft{i,8} = temp_all_fft_avg;
% end


%% average f0 and f1 from raw fft
%store in col 4 all_fft
for i=1:size(all_fft,1)
    for j=0:53
        temp_bin_f0_f1 = all_fft{i,3};
        average_f0_f1(j+1,:) = mean(temp_bin_f0_f1(((1+12*j:12+12*j)), 1:2));
        all_averages = average_f0_f1;
    end
    all_fft{i,4} = all_averages;
end

%% average F0 and F1 across all SF presentations of each ori
%store in all_fft col5
for i=1:size(all_fft,1)
    for j=1:9
        temp_avg_f0_f1_bin = all_fft{i,4};
        allSF_avg = mean(temp_avg_f0_f1_bin(j:9:end,1));
        all_SF_avg_bin(j,1) = allSF_avg;
        all_fft{i,5} = all_SF_avg_bin;
    end
end

%% average F0 and F1 across all ori presentations of each sf
for i=1:size(all_fft,1)
    for j=0:4
        temp_avg_f0_f1_bin = all_fft{i,4};
        allOri_avg = mean(temp_avg_f0_f1_bin((1+9*j:8+9*j),1));
        allOri_avg_bin(j+1,1) = allOri_avg;
        all_fft{i,6} = allOri_avg_bin;
    end
end
end

