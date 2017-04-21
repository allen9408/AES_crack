key_hex = {'00' '01' '02' '03' '04' '05' '06' '07' ...
			'08' '09' '0a' '0b' '0c' '0d' '0e' '0f'};
key = hex2dec(key_hex);
[s_box, inv_s_box, w, poly_mat, inv_poly_mat] = aes_init(key);
lfsr_reg = zeros(20, 1);


file_in = textread('input.txt');
[row, col] = size(file_in);

text_out = fopen('text_out.txt', 'w+');
cap_out = fopen('cap_out.txt', 'w+');
key_out = fopen('key_out.txt', 'w+');

for r = 1:row
	plaintext = file_in(r, :)';
	ciphertext = cipher(plaintext, w ,s_box, poly_mat);
	if (r == 1)
		% Initial TSC reg[19:0] = data[19:0]
		for i = 1:8
			lfsr_reg(i) = bitshift(mod(plaintext(16), 2^i), -(i-1));
			lfsr_reg(i+8) = bitshift(mod(plaintext(15), 2^i), -(i-1));
		end
		for i = 1:4
			lfsr_reg(i + 16) = bitshift(mod(plaintext(14), 2^i), -(i-1));
		end
	end

	[cap(r,:), lfsr_reg] = tsc(plaintext, key, lfsr_reg,r);
	fprintf(text_out, '%g\t', ciphertext);
	fprintf(text_out, '\r\n');
	fprintf(cap_out, '%g\t', cap(r,:));
	fprintf(cap_out, '\r\n');
    if (mod(r,2) == 0)
        key_o(1,1) = 0;
        key_o(2,1) = 1;
        for i = 2:8
            if cap(r,i-1) == cap(r-1, i)
                key_o(1,i) = key_o(1,i-1); 
                key_o(2,i) = key_o(2,i-1);
            else
                key_o(1,i) = ~key_o(1,i-1);
                key_o(2,i) = ~key_o(2,i-1);
            end
        end
        fprintf(key_out, '%g\t',key_o(1,:));
        fprintf(key_out, '\t or \t');
        fprintf(key_out, '%g\t',key_o(2,:));
        fprintf(key_out, '\r\n');
    end
end
% plaintext_hex = {'00' '11' '22' '33' '44' '55' '66' '77' ...
% 				'88' '99' 'aa' 'bb' 'cc' 'dd' 'ee' 'ff'};
% plaintext = hex2dec(plaintext_hex);
% ciphertext = cipher(plaintext, w ,s_box, poly_mat);
% re_plaintext = inv_cipher(ciphertext, w, inv_s_box, inv_poly_mat);

