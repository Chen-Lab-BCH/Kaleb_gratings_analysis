function SU_spike_times = KKGet_Spike_info(block_path)

%import sort data
block_path = ('/Users/kalebkelley/Desktop/Matlab/P30_NR_redownload/S1-R2-gratings2/S1-R2-gratings2-kilosort/cluster_group.tsv');
[unitID,unitQualtiy] = readClusterGroupsCSV(block_path);
all_unitID_unitQuality = [unitID; unitQualtiy];

%identify single units
SUid = find(unitQualtiy == 2) -1; %array of unitIDs for single units only

%import spiking data
spike_clusters = readNPY('spike_clusters.npy');
spike_time = readNPY('spike_times.npy');
%spike_time = spike_time/24414; %convert to seconds

%define output table
Numberofunits = size(SUid,2);
SU_spike_times = cell(Numberofunits,2);

%fill output table
for i=1:Numberofunits; %thus i=unit number
        temp_SUid = SUid(i);
        temp_spike_clusters_indices = find(spike_clusters==temp_SUid);
        temp_spike_times = spike_time(temp_spike_clusters_indices);
    SU_spike_times{i,1} = temp_SUid; %adds unit ID
    SU_spike_times{i,2} = temp_spike_clusters_indices; %adds index of each cluster
    SU_spike_times{i,3} = temp_spike_times; %adds timestamp of each cluster index
end;    
end




    
