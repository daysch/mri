function blur_comp_array = blur_compensation(recon_matrix_size)
% creates the blurring compensation array of the sinc^2 functions in each
% of the three matrix directions.

step_recon = recon_matrix_size/(recon_matrix_size-1);
recon_coords = -recon_matrix_size/2:step_recon:recon_matrix_size/2;


blur_comp_array = zeros(recon_matrix_size,recon_matrix_size,recon_matrix_size);
sinc_sq = (sin(recon_coords*(pi/2)/(recon_matrix_size/2))./(recon_coords*(pi/2)/(recon_matrix_size/2))).^2;

% note: consider vectorizing this somehow. sinc_sq'*sinc_sq gets you the first two dimensions, I believe 
% Try, for example, https://www.mathworks.com/matlabcentral/answers/104127-how-to-multiply-multidimensional-arrays-with-a-column-vector
for j = 1:recon_matrix_size
    for k = 1:recon_matrix_size
        for l = 1:recon_matrix_size
            blur_comp_array(j,k,l) = sinc_sq(j)*sinc_sq(k)*sinc_sq(l);
        end
    end
end