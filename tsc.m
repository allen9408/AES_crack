function [cap, reg_out] = tsc(plaintext, key, reg_in,r)
	reg_out = lfsr(plaintext, reg_in);
    shift = mod(fix((r-1)/2),16) + 1
	for i = 1:8
		mask = 2^i;
        key_bit = bitshift(mod(key(shift),mask), -(i-1));
		cap(i) = bitxor(reg_out(i),key_bit); 
	end
end

function reg_out = lfsr(plaintext, reg_in)
	tmp = xor(xor(xor(reg_in(16), reg_in(12)), reg_in(8)), reg_in(1));
	for i = 1:19
		reg_out(i) = reg_in(i+1);
	end
	reg_out(20) = tmp;
end
