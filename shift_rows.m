function state_out = shift_rows(state_in)
	state_out = cycle(state_in, 'left');
end

