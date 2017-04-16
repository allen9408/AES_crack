function [s_box, inv_s_box, w, poly_mat, inv_poly_mat] = aes_init(key)
	[s_box, inv_s_box] = s_box_gen();
	rcon = rcon_gen();
	% key_hex = {'00' '01' '02' '03' '04' '05' '06' '07' ...
	% 			'08' '09' '0a' '0b' '0c' '0d' '0e' '0f'};
	% key = hex2dec(key_hex);
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

function b_inv = find_inverse(b_in, mod_pol)
	for i = 1:255
		prod = poly_mult(b_in, i, mod_pol);
		if prod == 1
			b_inv = i;
			break;
		end
	end
end

function b_out = aff_trans(b_in)
	mod_pol = bin2dec('100000001');
	mult_pol = bin2dec('00011111');
	add_pol = bin2dec('01100011');
	tmp = poly_mult(b_in, mult_pol, mod_pol);
	b_out = bitxor(tmp, add_pol);
end

function inv_s_box = s_box_inversion(s_box)
	for i = 1:256
		inv_s_box(s_box(i) + 1) = i - 1;
	end
end

function rcon = rcon_gen()
	mod_pol = bin2dec('100011011');
	rcon(1) = 1;
	for i = 2:10
		rcon(i) = poly_mult(rcon(i-1), 2, mod_pol);
	end
	rcon = [rcon(:), zeros(10,3)];
end

function w = key_expansion(key, s_box, rcon)
	w  = (reshape(key, 4, 4))';
	for i = 5:44
		temp = w(i-1, :);
		if mod(i, 4) == 1
			temp = rot_word(temp);
			temp = sub_bytes(temp, s_box);
			r = rcon((i-1)/4, :);
			temp = bitxor(temp,r);
		end
		w(i, :) = bitxor(w(i-4, :), temp);
	end
end

function w_out = rot_word (w_in)
	w_out = w_in([2 3 4 1]);
end

function [poly_mat, inv_poly_mat] = poly_mat_gen()
	row_hex = {'02' '03' '01' '01'};
	row = hex2dec(row_hex)';
	rows = repmat(row, 4, 1);
	poly_mat = cycle(rows, 'right');
	inv_row_hex = {'0e' '0b' '0d' '09'};
	inv_row = hex2dec(inv_row_hex)';
	inv_rows = repmat(inv_row, 4, 1);
	inv_poly_mat = cycle(inv_rows, 'right');
end

