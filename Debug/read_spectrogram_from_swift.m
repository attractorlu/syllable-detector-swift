% 
% 1. Open the binary file
filename = 'swift_test.spectrogram.bin';
fid = fopen(filename, 'r');
if fid == -1
    error('Could not open file: %s', filename);
end

% 2. Read raw data as 32-bit floats
raw_data = fread(fid, 'float32');
fclose(fid);

% 3. CONFIGURATION (Update these values based on your network config!)
% Check your config text file for 'timeRange' and 'layer0.inputs'
time_steps = 40;  % Example: 'timeRange' in config

% Calculate frequency bins
num_freqs = 41;%total_inputs / time_steps; 

fprintf('Reshaping with NumFreqs: %d, TimeSteps: %d\n', num_freqs, time_steps);

% 4. Reshape into Neural Network Inputs
% Each column in this matrix represents one full input window seen by the network
input_vector_size = num_freqs * time_steps;
num_windows = floor(length(raw_data) / input_vector_size);

% Truncate any partial writes at the end
clean_data = raw_data(1 : num_windows * input_vector_size);

% Reshape: [InputSize x NumberOfWindows]
network_inputs = reshape(clean_data, input_vector_size, num_windows);

% 5. Reconstruct Continuous Spectrogram
% The network input is a sliding window (overlapping). To get the continuous
% spectrogram, we extract just the new data (the first time slice) from each window.
% The vector is arranged as [Freqs_Time0, Freqs_Time1, ...].
% So rows 1 to num_freqs correspond to the first time slice of that window.

spectrogram_img = network_inputs(1:num_freqs, :);

% 6. Plot
figure;
imagesc(spectrogram_img);
set(gca, 'YDir', 'normal'); % Low frequencies at the bottom
colormap('jet');
colorbar;
title(['Spectrogram (' filename ')']);
xlabel('Time (Window Steps)');
ylabel('Frequency Bins');
