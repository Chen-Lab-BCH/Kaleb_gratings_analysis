function spont_activity = KKget_spont_activity(block_path, stim_path)
%% identify inputs
% stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
% block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/cluster_group.tsv');

%% import fr info
sf_ori_fr = get_firing_rates(block_path, stim_path);
numberofunits = size(sf_ori_fr,1);

SU_spike_times = Get_Spike_info(block_path);
%% define spont activity table
spont_activity = cell(numberofunits, 3);


%fill spontaneous activity matrix
for i=1:numberofunits
    temp_data_bin = sf_ori_fr{i,2};
    [temp_700_indices ~] = ind2sub([648 5], find(temp_data_bin == 700));
    blank_only_array = temp_data_bin(temp_700_indices,1:5);
    spont_activity{i,2} = blank_only_array;
%     for j=1:size(temp_data_bin)
%         if temp_data_bin(j,2) == 700 %find runs of blank stim
%            temp_spont_activity(j,1:5) = temp_data_bin(j,:); %create matrix of blank only runs. everything else is 0s
%            spont_activity{i,2} = temp_spont_activity; %add blank only runs to output
%         end
%     end     
    spont_activity{i,1} = sf_ori_fr{i,1}; %add unit ids to output
%     temp_bin = spont_activity{i,2};
%     spont_activity_true_indices = find(temp_bin(:,1));
%     spont_activity_true = temp_bin(spont_activity_true_indices,:);
%     sum_spont_activity = sum(spont_activity_true(:,5));
%     spont_activity{i,3} = sum_spont_activity/(size(spont_activity_true,1)); %adds spontaneous firing rate to output table 
%     spont_activity{i,3} = spont_activity{i,3}/1.5054; %converts spont firing rate to spike/sec
end 


% 
%bin blank stim spikes into 100ms store in spont activity col 3
for unit=1:size(spont_activity,1)
    for trial=1:size(spont_activity{unit,2},1)
        temp_spont_activity = spont_activity{unit,2}; 
        edges = [temp_spont_activity(trial,3)*24414:2441.4:temp_spont_activity(trial,4)*24414];
        [temp_counts(trial,:),~] = histcounts(SU_spike_times{unit,3}, edges);
        spont_activity{unit,3} = temp_counts;
    end    
     
end

%% fft the blank data
%store in col 4 of spont_activity
for unit = 1:size(spont_activity,1)
    temp_spont_bins = spont_activity{unit,3}./0.1;
    for trial = 1:size(temp_spont_bins,1)
        temp_fft = abs(fft(temp_spont_bins(trial,:)));
        temp_fft = temp_fft/size(temp_fft,2);
        all_fft(trial,:) = temp_fft;
    end
    spont_activity{unit,4} = all_fft;
end

% store average F0 in col5
for unit = 1:size(spont_activity,1)
    temp_fft_all = spont_activity{unit,4};
    temp_avg_F0 = mean(temp_fft_all(:,1));
    spont_activity{unit,5} = temp_avg_F0;
end



end
