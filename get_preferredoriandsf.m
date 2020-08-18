function prefSF_F0 = KKget_preferredoriandsf(block_path, stim_path)
%% import neccessary items
%input arguments
% stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
% block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/cluster_group.tsv');

%%import fft data
all_fft = FFt(block_path, stim_path);

%%import and sort sf_ori combos
sf_ori_time = get_stim_info(stim_path);
sf_ori_time_sort = sortrows(sf_ori_time);

%% extract unique pairs from sforitime
for i=1:(size(sf_ori_time_sort,1)/12)
    temp_unique_sf_ori_pairs = sf_ori_time_sort(12*i,1:2);
    unique_sf_ori_pairs(i,:) = temp_unique_sf_ori_pairs;
end

%% define output table
preferred_ori_deg = cell(size(all_fft,1),4);

%% find ori that evokes the highest F0 response. that is preferred ori for
%subsequent calculations (see Durand & Reid, 2016 methods)
%store in col2
%col1 is SUID
for i=1:size(all_fft,1) % #units
    temp_fft_bin = all_fft{i,5};
    temp_SUID_bin = all_fft{i,1};
    preferred_ori_index = temp_fft_bin == max(temp_fft_bin(1:8,1));
    temp_preferred_ori_deg = unique_sf_ori_pairs(preferred_ori_index,2);
%     if size(temp_preferred_ori_deg,1) > 1 %%IMPORTANT NOTE: units may "prefer" multiple ori's with this method. This function arbitrarily chooses the 'true' preferred ori for subsequent calculations with the assumption that this unit will NOT be AS (low gosi), so it will not be counted in the analysis anyways. If gosi comes out to be high, this method will need to be adjusted 
%        temp_preferred_ori_deg = temp_preferred_ori_deg(1,1);
%     end %this doesn't seem to be neccessary but I'll leave it here in
%     case it is in the future
    preferred_ori_deg{i,2} = temp_preferred_ori_deg;
    preferred_ori_deg{i,1} = temp_SUID_bin;
end

%% find SF that evokes the highest response for the preferred ori
%fill output table col 3 with index and F0 of all SF runs of preferred ori 
for i=1:size(all_fft,1)
    temp_preferred_ori_bin = preferred_ori_deg{i,2};
    [temp_ori_indices, ~] = ind2sub([54 2], find(unique_sf_ori_pairs(:,2) == temp_preferred_ori_bin));
    for j=1:size(temp_ori_indices,1)
        temp_fft_bin = all_fft{i,4};
        temp_preferred_ori_index_bin = temp_ori_indices(j,1);
        temp_F0_bin = temp_fft_bin(temp_preferred_ori_index_bin,1);
        temp_ori_indices(j,2) = temp_F0_bin;
        preferred_ori_deg{i,3} = temp_ori_indices;
    end
end

%% define output table
preferred_sf_cpd = cell(size(all_fft,1));

%find preferred sf and place in output table col2
for i=1:size(all_fft,1)
    temp_SUID_bin = all_fft{i,1};
    temp_preferred_ori_deg_bin = preferred_ori_deg{i,3};
    [temp_max_F0_index_bin, ~] = ind2sub([size(temp_preferred_ori_deg_bin) 2], find(temp_preferred_ori_deg_bin == max(temp_preferred_ori_deg_bin(:,2))));
    temp_preferred_sf_index_bin = temp_preferred_ori_deg_bin(temp_max_F0_index_bin,1);
    temp_preferred_sf_bin = unique_sf_ori_pairs(temp_preferred_sf_index_bin,1);
    preferred_sf_cpd{i,2} = temp_preferred_sf_bin;
    preferred_sf_cpd{i,1} = temp_SUID_bin;
end




%% define final output table
preferred_ori_sf_pair = cell(size(all_fft,1));

%fill final output table
%col1 is SUID
%col2 is preferred ori
%col3 is preferred sf
%col4 is avg f0 of all ori's presented at prefsf (see below)
for i=1:size(all_fft,1)
    temp_SUID_bin = all_fft{i,1};
    temp_preferred_ori = preferred_ori_deg{i,2};
    temp_preferred_sf = preferred_sf_cpd(i,2);
    preferred_ori_sf_pair{i,1} = temp_SUID_bin;
    preferred_ori_sf_pair{i,2} = temp_preferred_ori;
    preferred_ori_sf_pair{i,3} = temp_preferred_sf; 
end

%define table for prefSF responses
prefSF_F0 = zeros(size(all_fft,1),10);

%% Find average F0 of all ori's presented at preferred SF store in col4 of output table
%this will be used to calculate gOSI
for i=1:size(all_fft,1)
    temp_fft = all_fft{i,4};
    temp_pref_sf = cell2mat(preferred_ori_sf_pair{i,3});
    temp_ori_indices_pref_sf = unique_sf_ori_pairs(:,1) == temp_pref_sf;
    temp_F0 = temp_fft(temp_ori_indices_pref_sf,1);
    prefSF_F0(i,1:9) = temp_F0;
    prefSF_F0(i,10) = temp_pref_sf;
end

end

