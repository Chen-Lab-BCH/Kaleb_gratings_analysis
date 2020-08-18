
function all_gOSI = get_gosi(block_path, stim_path)
%% input arguments
% stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
% block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/cluster_group.tsv');

%% import fft data
all_fft = FFt(block_path, stim_path);

%% assign orientations
% These orientations are corrected to fit polar plot coordinates (0 degrees to the right)
orientations = [135 90 45 360 315 270 225 180]; 
orientations = deg2rad(orientations); % convert to radians

%% import responses at prefSF
prefSF_F0 = get_preferredoriandsf(block_path, stim_path);

%% import spont activity
spont_activity = get_spont_activity(block_path, stim_path);

%% subtract spont activity from prefSF responses
for unit = 1:size(prefSF_F0,1)
    temp_spont_activity = spont_activity{unit,5};
    prefSF_F0_minusblank(unit,:) = prefSF_F0(unit,:)-temp_spont_activity;
    prefSF_F0_minusblank(prefSF_F0_minusblank < 0) = 0; %set negative values to 0 to calculate gosi
end


%% reorder F0's at preferred SF to match orientations for polar plot (above)
%still storing in same place
% for i=1:size(all_fft,1);
%     reordered_F0 = [prefSF_F0(i,3) prefSF_F0(i,2) prefSF_F0(i,1) prefSF_F0(i,8) prefSF_F0(i,7) prefSF_F0(i,6) prefSF_F0(i,5) prefSF_F0(i,4)];
%     prefSF_F0(i,1:8) = reordered_F0;
% end


%% import sorted stim info
%this might not be neccessary tbh 
sf_ori_time_sort = sortrows(get_stim_info(stim_path));

%% define output table
all_gOSI = double(size(all_fft,1));

%% calculate gOSI (see Durand & Reid 2016 methods)
%TODO: double check fft data for mistakes (numbers are slightly off)
%also: plot polar histogram to see wtf is going on
for i=1:size(prefSF_F0,1) %unit
    temp_SUID = all_fft{i,1};
    temp_F0_prefSF = prefSF_F0_minusblank(i,1:8);
   weighted_sum_vector = sum(temp_F0_prefSF.*exp(2i*(orientations)))/sum(temp_F0_prefSF);
   gOSI = abs(weighted_sum_vector);
   temp_pref_ori_phase_angle = (0.5*angle(weighted_sum_vector));
   all_gOSI(i,1) = temp_SUID;
   all_gOSI(i,2) = gOSI;
   all_gOSI(i,3) = rad2deg(temp_pref_ori_phase_angle);
end
end
