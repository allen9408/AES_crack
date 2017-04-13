function state_out = add_round_key(state_in, round_key)
	state_out = bitxor(state_in, round_key);
end

