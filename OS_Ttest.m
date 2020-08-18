% This function will perform a Hotelling T2 test and output P values
function all_P_Hottelings = KKOS_Ttest(block_path, stim_path)
%% input arguments
% % stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
% % block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/cluster_group.tsv');

%% import fft
all_fft = FFt(block_path, stim_path);

%% import preferred sf
prefSF_F0 = get_preferredoriandsf(block_path, stim_path);

%% get stim info
sf_ori_time = get_stim_info(stim_path);
sf_ori_time_sort = sortrows(sf_ori_time); %sort info

%% get indices of all presentations for prefSF
for unit = 1:size(all_fft,1)
    temp_prefSF = prefSF_F0(unit,10);
    temp_indices_all_prefSF_presentations = find(sf_ori_time_sort(:,1) == temp_prefSF);
    all_indices_all_prefSF_presentations{unit,1} = temp_indices_all_prefSF_presentations(1:end-11,1);
end

%% get F0 for indices found above
for unit = 1:size(all_fft,1)
    temp_all_F0 = all_fft{unit,3};
    temp_all_indices_all_prefSF_presentations = all_indices_all_prefSF_presentations{unit,1};
    temp_F0_all_prefSF_presentations =  temp_all_F0(temp_all_indices_all_prefSF_presentations);
    F0_all_prefSF_presentations{unit,1} = temp_F0_all_prefSF_presentations;
end

%% break F0s into orientations
for unit = 1:size(all_fft,1)
    temp_F0_all_prefSF_presentations = F0_all_prefSF_presentations{unit,1};
    temp_F0_dir = [temp_F0_all_prefSF_presentations(1:12,1) temp_F0_all_prefSF_presentations(13:24,1) temp_F0_all_prefSF_presentations(25:36,1) temp_F0_all_prefSF_presentations(37:48,1) temp_F0_all_prefSF_presentations(49:60,1) temp_F0_all_prefSF_presentations(61:72,1) temp_F0_all_prefSF_presentations(73:84,1) temp_F0_all_prefSF_presentations(85:96,1)];
    all_F0_dir{unit,1} = temp_F0_dir;
end

%% define orientations for weighted sum vector calculation
orientations = [135 90 45 360 315 270 225 180];
    orientations = deg2rad(orientations); % convert to radians

%% find weighted sum vector of each run of preferredSF
for unit = 1:size(all_fft,1)
    temp_all_F0_dir = all_F0_dir{unit,1};
    for run = 1:size(temp_all_F0_dir)
        temp_F0_run = temp_all_F0_dir(run,:);
        weighted_sum_vector_run = sum(temp_F0_run.*exp(2i*(orientations)));
        temp_real_imaginary_vector_components = [real(weighted_sum_vector_run) imag(weighted_sum_vector_run)];
        temp_Hottelings_data(run,:) = temp_real_imaginary_vector_components;
        all_Hottelings_data{unit,1} = temp_Hottelings_data;
    end
end

%% perform Hotelling T2 test
for unit = 1:size(all_Hottelings_data,1)
    P = T2Hot1_TS(all_Hottelings_data{unit,1},[0 0],0.05);
    all_P_Hottelings(unit,1) = P;
end

end

