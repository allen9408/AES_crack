function bytes_out = sub_bytes (bytes_in, s_box)
	bytes_out = s_box(bytes_in + 1);
end