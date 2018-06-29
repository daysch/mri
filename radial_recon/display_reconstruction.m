function fig = display_reconstruction(recon_final, recon_matrix_size_val, title)
% display reconstruction
addpath([fileparts(fileparts(mfilename('fullpath'))) filesep '3D Viewers' filesep 'vi']); 
scale = 64/recon_matrix_size_val*8;
fig = vi(abs(recon_final), 'aspect', [scale scale scale]);

% change figure title
set(fig, 'Name', title);