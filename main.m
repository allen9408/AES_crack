[s_box, inv_s_box, w, poly_mat, inv_poly_mat] = aes_init();
plaintext_hex = {'00' '11' '22' '33' '44' '55' '66' '77' ...
				'88' '99' 'aa' 'bb' 'cc' 'dd' 'ee' 'ff'};
plaintext = hex2dec(plaintext_hex);
ciphertext = cipher(plaintext, w ,s_box, poly_mat);
re_plaintext = inv_cipher(ciphertext, w, inv_s_box, inv_poly_mat);