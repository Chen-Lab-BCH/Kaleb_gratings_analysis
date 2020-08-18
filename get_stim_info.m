

function sf_ori_time = KKget_stim_info(stim_path)

    %import stim info
%     stim_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort');
    unfiltered_data = TDTbin2mat(stim_path,'TYPE', {'epocs', 'snips', 'scalars'});
    all_stim_info = TDTfilter(unfiltered_data, 'Sm1_', 'VALUES', (0:700));

    %extract time stamps
    time_stamps = all_stim_info.time_ranges'; %transpose to make it look nice

    %organize cpd and ori pairs
    all_spatialfreqs = all_stim_info.epocs.Sm2_.data;
    all_orientations = all_stim_info.epocs.Sm1_.data;

    %define output table: col1 is cpds, col2 is oris, col3 is onset time, col4
    %is offset time
    sf_ori_time = [all_spatialfreqs all_orientations time_stamps];
end