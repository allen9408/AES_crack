function [s_box, inv_s_box, w, poly_mat, inv_poly_mat] = aes_init()
	[s_box, inv_s_box] = s_box_gen();
	rcon = rcon_gen();
	key_hex = {'00' '01' '02' '03' '04' '05' '06' '07' ...
				'08' '09' '0a' '0b' '0c' '0d' '0e' '0f'};
	key = hex2dec(key_hex);
	w = key_expansion(key, s_box, rcon);
	[poly_mat, inv_poly_mat] = poly_mat_gen();
end

function [s_box, inv_s_box] = s_box_gen()
	mod_pol = bin2dec('100011011');
	inverse(1) = 0;
	for i = 1:255
		inverse(i+1) = find_inverse(i, mod_pol);
	end
	for i = 1:256
		s_box(i) = aff_trans(inverse(i));
	end
	inv_s_box = s_box_inversion(s_box);
end