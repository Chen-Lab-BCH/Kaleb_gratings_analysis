ori_sf_fr = get_firing_rates(block_path); 
SU_spike_times = Get_Spike_info(stim_path);
spont_activity = get_spont_activity(block_path);

for unit=1:size(ori_sf_fr,1)
    ori_sf_fr_sort{unit,2} = sortrows(ori_sf_fr{unit,2});
    ori_sf_fr_sort{unit,1} = ori_sf_fr{unit,1};
end

for unit=1:size(ori_sf_fr,1)
    SU_spike_times_sec{unit,2} = double(SU_spike_times{unit,3}./24414);
    SU_spike_times_sec{unit,1} = SU_spike_times{unit,1};
end


for unit=1:size(SU_spike_times,1)
    for trial=1:size(ori_sf_fr_sort,1)
        temp_ori_sf_fr_sort = ori_sf_fr_sort{unit,2};
        edges = [temp_ori_sf_fr_sort(trial,3):0.1:temp_ori_sf_fr_sort(trial,4)];
        temp_counts(1,:) = histcounts(SU_spike_times_sec{unit,2}, edges)-spont_activity{unit,3}/10;
        temp_ori_sf_fr_sort(trial, 6:20) = temp_counts;
       % temp_ori_sf_fr_sort(temp_ori_sf_fr_sort<0) = 0; %set negative values to 0
    end
     SU_spike_times_sec{unit,4} = temp_ori_sf_fr_sort;
     
end
