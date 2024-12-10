function [bytes_remaining, t_amplifier, amplifier_data, aux_input_data, supply_voltage_data, temp_sensor_data, board_adc_data, board_dig_in_raw, board_dig_out_raw] = read_rhd_chunk(fid, bytes_remaining, header, blocks_per_chunk, is_blocking)
%READ_RHD_CHUNK Reads chunk of data from RHD binary file (i.e. during online streaming from disk-file).
arguments
    fid
    bytes_remaining
    header struct
    blocks_per_chunk {mustBePositive, mustBeInteger} = 1 % There are 128 samples per block (data-frame)
    is_blocking (1,1) logical = true;
end

num_data_blocks_available = floor(bytes_remaining / header.bytes_per_block);
if is_blocking
    while num_data_blocks_available < blocks_per_chunk
        pause(0.010);
    end
else
    if (num_data_blocks_available < blocks_per_chunk) && (header.total_data_bytes/header.bytes_per_block >= blocks_per_chunk)
        fseek(fid,header.start_of_data,"bof");
    end
end
num_amplifier_samples = header.num_samples_per_data_block * blocks_per_chunk;
num_aux_input_samples = (header.num_samples_per_data_block / 4) * blocks_per_chunk;
num_supply_voltage_samples = 1 * blocks_per_chunk;
num_board_adc_samples = header.num_samples_per_data_block * blocks_per_chunk;
num_board_dig_in_samples = header.num_samples_per_data_block * blocks_per_chunk;
num_board_dig_out_samples = header.num_samples_per_data_block * blocks_per_chunk;

t_amplifier = zeros(1, num_amplifier_samples);
amplifier_data = zeros(header.num_amplifier_channels, num_amplifier_samples);
aux_input_data = zeros(header.num_aux_input_channels, num_aux_input_samples);
supply_voltage_data = zeros(header.num_supply_voltage_channels, num_supply_voltage_samples);
temp_sensor_data = zeros(header.num_temp_sensor_channels, num_supply_voltage_samples);
board_adc_data = zeros(header.num_board_adc_channels, num_board_adc_samples);
board_dig_in_raw = zeros(1, num_board_dig_in_samples);
board_dig_out_raw = zeros(1, num_board_dig_out_samples);

amplifier_index = 1;
aux_input_index = 1;
supply_voltage_index = 1;
board_adc_index = 1;
board_dig_in_index = 1;
board_dig_out_index = 1;

for i=1:blocks_per_chunk
    % In version 1.2, we moved from saving timestamps as unsigned
    % integeters to signed integers to accomidate negative (adjusted)
    % timestamps for pretrigger data.
    if ((header.data_file_main_version_number == 1 && header.data_file_secondary_version_number >= 2) ...
            || (header.data_file_main_version_number > 1))
        t_amplifier(amplifier_index:(amplifier_index + header.num_samples_per_data_block - 1)) = fread(fid, header.num_samples_per_data_block, 'int32');
    else
        t_amplifier(amplifier_index:(amplifier_index + header.num_samples_per_data_block - 1)) = fread(fid, header.num_samples_per_data_block, 'uint32');
    end
    if (header.num_amplifier_channels > 0)
        amplifier_data(:, amplifier_index:(amplifier_index + header.num_samples_per_data_block - 1)) = fread(fid, [header.num_samples_per_data_block, header.num_amplifier_channels], 'uint16')';
    end
    if (header.num_aux_input_channels > 0)
        aux_input_data(:, aux_input_index:(aux_input_index + (header.num_samples_per_data_block / 4) - 1)) = fread(fid, [(header.num_samples_per_data_block / 4), header.num_aux_input_channels], 'uint16')';
    end
    if (header.num_supply_voltage_channels > 0)
        supply_voltage_data(:, supply_voltage_index) = fread(fid, [1, header.num_supply_voltage_channels], 'uint16')';
    end
    if (header.num_temp_sensor_channels > 0)
        temp_sensor_data(:, supply_voltage_index) = fread(fid, [1, header.num_temp_sensor_channels], 'int16')';
    end
    if (header.num_board_adc_channels > 0)
        board_adc_data(:, board_adc_index:(board_adc_index + header.num_samples_per_data_block - 1)) = fread(fid, [header.num_samples_per_data_block, num_board_adc_channels], 'uint16')';
    end
    if (header.num_board_dig_in_channels > 0)
        board_dig_in_raw(board_dig_in_index:(board_dig_in_index + header.num_samples_per_data_block - 1)) = fread(fid, header.num_samples_per_data_block, 'uint16');
    end
    if (header.num_board_dig_out_channels > 0)
        board_dig_out_raw(board_dig_out_index:(board_dig_out_index + header.num_samples_per_data_block - 1)) = fread(fid, header.num_samples_per_data_block, 'uint16');
    end

    amplifier_index = amplifier_index + header.num_samples_per_data_block;
    aux_input_index = aux_input_index + (header.num_samples_per_data_block / 4);
    supply_voltage_index = supply_voltage_index + 1;
    board_adc_index = board_adc_index + header.num_samples_per_data_block;
    board_dig_in_index = board_dig_in_index + header.num_samples_per_data_block;
    board_dig_out_index = board_dig_out_index + header.num_samples_per_data_block;
end
bytes_remaining = header.filesize - ftell(fid);


end

