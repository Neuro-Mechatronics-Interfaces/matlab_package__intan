function [fid, bytes_remaining, header] = read_rhd_header(fname)
%READ_RHD_HEADER  Reads header struct from RHD2000 binary file to get metadata. Should be used in combination with intan.read_rhd_chunk for online diskfile reading approach.
arguments
    fname {mustBeTextScalar} = ""
end

if strlength(fname) == 0
    [file, path] = ...
        uigetfile('*.rhd', 'Select an RHD2000 Data File', 'MultiSelect', 'off');
    if (file == 0)
        return;
    end
    filename = [path,file];
else
    filename = fname;
end
fid = fopen(filename, 'r');

s = dir(filename);

header = struct;
header.filesize = s.bytes;

% Check 'magic number' at beginning of file to make sure this is an Intan
% Technologies RHD2000 data file.
header.magic_number = fread(fid, 1, 'uint32');
if header.magic_number ~= hex2dec('c6912702')
    error('Unrecognized file type.');
end

% Read version number.
header.data_file_main_version_number = fread(fid, 1, 'int16');
header.data_file_secondary_version_number = fread(fid, 1, 'int16');

if (header.data_file_main_version_number == 1)
    header.num_samples_per_data_block = 60;
else
    header.num_samples_per_data_block = 128;
end

% Read information of sampling rate and amplifier frequency settings.
header.sample_rate = fread(fid, 1, 'single');
header.dsp_enabled = fread(fid, 1, 'int16');
header.actual_dsp_cutoff_frequency = fread(fid, 1, 'single');
header.actual_lower_bandwidth = fread(fid, 1, 'single');
header.actual_upper_bandwidth = fread(fid, 1, 'single');

header.desired_dsp_cutoff_frequency = fread(fid, 1, 'single');
header.desired_lower_bandwidth = fread(fid, 1, 'single');
header.desired_upper_bandwidth = fread(fid, 1, 'single');

% This tells us if a software 50/60 Hz notch filter was enabled during
% the data acquisition.
header.notch_filter_mode = fread(fid, 1, 'int16');
header.desired_impedance_test_frequency = fread(fid, 1, 'single');
header.actual_impedance_test_frequency = fread(fid, 1, 'single');

% Place notes in data strucure
header.notes = struct( ...
    'note1', intan.fread_QString(fid), ...
    'note2', intan.fread_QString(fid), ...
    'note3', intan.fread_QString(fid) );

% If data file is from GUI v1.1 or later, see if temperature sensor data
% was saved.
header.num_temp_sensor_channels = 0;
if ((header.data_file_main_version_number == 1 && header.data_file_secondary_version_number >= 1) ...
        || (header.data_file_main_version_number > 1))
    header.num_temp_sensor_channels = fread(fid, 1, 'int16');
end

% If data file is from GUI v1.3 or later, load board mode.
header.board_mode = 0;
if ((header.data_file_main_version_number == 1 && header.data_file_secondary_version_number >= 3) ...
        || (header.data_file_main_version_number > 1))
    header.board_mode = fread(fid, 1, 'int16');
end

% If data file is from v2.0 or later (Intan Recording Controller),
% load name of digital reference channel.
if (header.data_file_main_version_number > 1)
    header.reference_channel = intan.fread_QString(fid);
end

% Place frequency-related information in data structure.
header.frequency_parameters = struct( ...
    'amplifier_sample_rate', header.sample_rate, ...
    'aux_input_sample_rate', header.sample_rate / 4, ...
    'supply_voltage_sample_rate', header.sample_rate / header.num_samples_per_data_block, ...
    'board_adc_sample_rate', header.sample_rate, ...
    'board_dig_in_sample_rate', header.sample_rate, ...
    'desired_dsp_cutoff_frequency', header.desired_dsp_cutoff_frequency, ...
    'actual_dsp_cutoff_frequency', header.actual_dsp_cutoff_frequency, ...
    'dsp_enabled', header.dsp_enabled, ...
    'desired_lower_bandwidth', header.desired_lower_bandwidth, ...
    'actual_lower_bandwidth', header.actual_lower_bandwidth, ...
    'desired_upper_bandwidth', header.desired_upper_bandwidth, ...
    'actual_upper_bandwidth', header.actual_upper_bandwidth, ...
    'desired_impedance_test_frequency', header.desired_impedance_test_frequency, ...
    'actual_impedance_test_frequency', header.actual_impedance_test_frequency );

% Define data structure for spike trigger settings.
spike_trigger_struct = struct( ...
    'voltage_trigger_mode', {}, ...
    'voltage_threshold', {}, ...
    'digital_trigger_channel', {}, ...
    'digital_edge_polarity', {} );

new_trigger_channel = struct(spike_trigger_struct);
header.spike_triggers = struct(spike_trigger_struct);

% Define data structure for data channels.
channel_struct = struct( ...
    'native_channel_name', {}, ...
    'custom_channel_name', {}, ...
    'native_order', {}, ...
    'custom_order', {}, ...
    'board_stream', {}, ...
    'chip_channel', {}, ...
    'port_name', {}, ...
    'port_prefix', {}, ...
    'port_number', {}, ...
    'electrode_impedance_magnitude', {}, ...
    'electrode_impedance_phase', {} );

new_channel = struct(channel_struct);

% Create structure arrays for each type of data channel.
header.amplifier_channels = struct(channel_struct);
header.aux_input_channels = struct(channel_struct);
header.supply_voltage_channels = struct(channel_struct);
header.board_adc_channels = struct(channel_struct);
header.board_dig_in_channels = struct(channel_struct);
header.board_dig_out_channels = struct(channel_struct);

amplifier_index = 1;
aux_input_index = 1;
supply_voltage_index = 1;
board_adc_index = 1;
board_dig_in_index = 1;
board_dig_out_index = 1;

% Read signal summary from data file header.

header.number_of_signal_groups = fread(fid, 1, 'int16');

for signal_group = 1:header.number_of_signal_groups
    signal_group_name = intan.fread_QString(fid);
    signal_group_prefix = intan.fread_QString(fid);
    signal_group_enabled = fread(fid, 1, 'int16');
    signal_group_num_channels = fread(fid, 1, 'int16');
    signal_group_num_amp_channels = fread(fid, 1, 'int16'); %#ok<NASGU>

    if (signal_group_num_channels > 0 && signal_group_enabled > 0)
        new_channel(1).port_name = signal_group_name;
        new_channel(1).port_prefix = signal_group_prefix;
        new_channel(1).port_number = signal_group;
        for signal_channel = 1:signal_group_num_channels
            new_channel(1).native_channel_name = intan.fread_QString(fid);
            new_channel(1).custom_channel_name = intan.fread_QString(fid);
            new_channel(1).native_order = fread(fid, 1, 'int16');
            new_channel(1).custom_order = fread(fid, 1, 'int16');
            signal_type = fread(fid, 1, 'int16');
            channel_enabled = fread(fid, 1, 'int16');
            new_channel(1).chip_channel = fread(fid, 1, 'int16');
            new_channel(1).board_stream = fread(fid, 1, 'int16');
            new_trigger_channel(1).voltage_trigger_mode = fread(fid, 1, 'int16');
            new_trigger_channel(1).voltage_threshold = fread(fid, 1, 'int16');
            new_trigger_channel(1).digital_trigger_channel = fread(fid, 1, 'int16');
            new_trigger_channel(1).digital_edge_polarity = fread(fid, 1, 'int16');
            new_channel(1).electrode_impedance_magnitude = fread(fid, 1, 'single');
            new_channel(1).electrode_impedance_phase = fread(fid, 1, 'single');

            if (channel_enabled)
                switch (signal_type)
                    case 0
                        header.amplifier_channels(amplifier_index) = new_channel;
                        header.spike_triggers(amplifier_index) = new_trigger_channel;
                        amplifier_index = amplifier_index + 1;
                    case 1
                        header.aux_input_channels(aux_input_index) = new_channel;
                        aux_input_index = aux_input_index + 1;
                    case 2
                        header.supply_voltage_channels(supply_voltage_index) = new_channel;
                        supply_voltage_index = supply_voltage_index + 1;
                    case 3
                        header.board_adc_channels(board_adc_index) = new_channel;
                        board_adc_index = board_adc_index + 1;
                    case 4
                        header.board_dig_in_channels(board_dig_in_index) = new_channel;
                        board_dig_in_index = board_dig_in_index + 1;
                    case 5
                        header.board_dig_out_channels(board_dig_out_index) = new_channel;
                        board_dig_out_index = board_dig_out_index + 1;
                    otherwise
                        error('Unknown channel type');
                end
            end

        end
    end
end

% Summarize contents of data file.
header.num_amplifier_channels = amplifier_index - 1;
header.num_aux_input_channels = aux_input_index - 1;
header.num_supply_voltage_channels = supply_voltage_index - 1;
header.num_board_adc_channels = board_adc_index - 1;
header.num_board_dig_in_channels = board_dig_in_index - 1;
header.num_board_dig_out_channels = board_dig_out_index - 1;

% Determine how many samples the data file contains.

% Each data block contains num_samples_per_data_block amplifier samples.
header.bytes_per_block = header.num_samples_per_data_block * 4;  % timestamp data
header.bytes_per_block = header.bytes_per_block + header.num_samples_per_data_block * 2 * header.num_amplifier_channels;
% Auxiliary inputs are sampled 4x slower than amplifiers
header.bytes_per_block = header.bytes_per_block + (header.num_samples_per_data_block / 4) * 2 * header.num_aux_input_channels;
% Supply voltage is sampled once per data block
header.bytes_per_block = header.bytes_per_block + 1 * 2 * header.num_supply_voltage_channels;
% Board analog inputs are sampled at same rate as amplifiers
header.bytes_per_block = header.bytes_per_block + header.num_samples_per_data_block * 2 * header.num_board_adc_channels;
% Board digital inputs are sampled at same rate as amplifiers
if (header.num_board_dig_in_channels > 0)
    header.bytes_per_block = header.bytes_per_block + header.num_samples_per_data_block * 2;
end
% Board digital outputs are sampled at same rate as amplifiers
if (header.num_board_dig_out_channels > 0)
    header.bytes_per_block = header.bytes_per_block + header.num_samples_per_data_block * 2;
end
% Temp sensor is sampled once per data block
if (header.num_temp_sensor_channels > 0)
    header.bytes_per_block = header.bytes_per_block + 1 * 2 * header.num_temp_sensor_channels;
end
header.start_of_data = ftell(fid);

bytes_remaining = header.filesize - header.start_of_data;
header.total_data_bytes = bytes_remaining; % e.g. if file has finished recording

end