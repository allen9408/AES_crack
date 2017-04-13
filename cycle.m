function matrix_out = cycle(matrix_in, direction)
	if strcmp(direction, 'left')
		col = (0: 5 : 15)';
	else
		col = (16: -3 : 7)';
	end
	row = 0 : 4 : 12;
	cols = repmat(col, 1, 4);
	rows = repmat(row, 4, 1);
	ind_mat = mod(rows + cols, 16) + 1;
	matrix_out = matrix_in(ind_mat);
end