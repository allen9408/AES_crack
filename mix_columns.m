function state_out = mix_columns(state_in, poly_mat)
	mod_pol = bin2dec('100011011');
	for i_col_state = 1:4
		for i_row_state = 1:4
			temp_state = 0;
			for i_inner = 1:4
				temp_prod = poly_mult(...
					poly_mat(i_row_state, i_inner), ...
					state_in(i_inner, i_col_state), ...
					mod_pol);
				temp_state = bitxor(temp_state, temp_prod);
			end
			state_out(i_row_state, i_col_state) = temp_state;
		end
	end
end