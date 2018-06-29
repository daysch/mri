% This calculates a set of data for a known phantom. It takes in an MxNxO
% matrix representing an image, a foldername, and the size of the matrix.
% Optionally takes in handles, which couples with other functions to update
% the gui. Uses npts, nspokes, data_grads_full, x_grad, y_grad, and z_grad
% from the previous reconstruction performed. This was stored in
% workspace.mat.

%%
function rad_k_lines = pseudo_data_phantom(phan_true, foldername, recon_matrix_size, handles)
try
    load workspace;
catch
    error('unable to load necessary data from previous recontruction');
end

% declare some constants
nsample = 2^6; %2^7 max if using 'big_phantom';
phantom_matrix_size = 2*nsample; %max 2^8
% nsample = 2^6; %2^10;

% grad_amp_big = 2;
% grad_amp_this = 100;
% nrings1 = 51;
% nrings2 = 3;
% grad_amp = 1;
% grad_amp_ratio = grad_amp/grad_amp_big;
%%
% data generation method 'big_phantom' creates a phantom of size (2*nsample)^3
% with the center recon_matrix_size^3 points as the original phantom. This
% is then FFT'd. This is good to generate the data, but the phase is not
% correct.
% method 'interp_true' interpolates the true k-space data from the original
% phantom onto a matrix of the same size as 2*nsample. This preserves the
% phase behavior but may not be great for a heavily varying sample.

data_gen_method = 'interp_true'; % 'big_phantom'  or 'interp_true'
phan_k_true = ifftshift(ifftn(ifftshift(phan_true)));
phan_recon1_true = fftshift(fftn(fftshift(phan_k_true)));

%% create the gradients for sampling k-space
x_grad_orig = x_grad; y_grad_orig = y_grad; z_grad_orig = z_grad;

% [x_grad,y_grad,z_grad] = grad_pattern_rs2d(nrings1);
% nmeas = length(x_grad);
% [x_grad2,y_grad2,z_grad2] = grad_pattern_rs2d(nrings2);
% nmeas2 = length(x_grad2);

%% k-space pseudo-data generation
disp('Generating data .... ')
if nargin == 4
    add_string_gui(handles, 'Generating data .... ');
end
tic;
switch data_gen_method
    case 'big_phantom'
        ind_center = (phantom_matrix_size/2-recon_matrix_size/2):(phantom_matrix_size/2+recon_matrix_size/2-1);
        phan_datagen = zeros(phantom_matrix_size,phantom_matrix_size,phantom_matrix_size);
        phan_datagen(ind_center,ind_center,ind_center) = phan_true;
        phan_k_datagen = ifftshift(ifftn(ifftshift(phan_datagen)));
        phan_recon1 = fftshift(fftn(fftshift(phan_k_datagen)));
        
    case 'interp_true'
        [X,Y,Z] = meshgrid(-recon_matrix_size/2:recon_matrix_size/2-1);
        [Xq,Yq, Zq] = meshgrid(-recon_matrix_size/2:recon_matrix_size/phantom_matrix_size:recon_matrix_size/2-recon_matrix_size/phantom_matrix_size);
        phan_k_datagen = interp3(X,Y,Z,phan_k_true,Xq,Yq, Zq,'spline');
end

% create grid vectors to sample model k-space in radial fashion
x_k_datagen = -recon_matrix_size:2*recon_matrix_size/phantom_matrix_size:recon_matrix_size-2*recon_matrix_size/phantom_matrix_size;
y_k_datagen = -recon_matrix_size:2*recon_matrix_size/phantom_matrix_size:recon_matrix_size-2*recon_matrix_size/phantom_matrix_size;
z_k_datagen = -recon_matrix_size:2*recon_matrix_size/phantom_matrix_size:recon_matrix_size-2*recon_matrix_size/phantom_matrix_size;

% sample model k-space in radial fashion
toc;
if nargin == 4
    update_gui_time(handles);
end

%%
disp('Interpolating data .... ')
if nargin == 4
    add_string_gui(handles, 'Interpolating data .... ');
end

tic;
grad_amp_big = sqrt(x_grad(2)^2+z_grad(2)^2+y_grad(2)^2);
x_proj_k = y_grad/grad_amp_big*x_k_datagen;
y_proj_k = x_grad/grad_amp_big*y_k_datagen;
z_proj_k = z_grad/grad_amp_big*z_k_datagen;
rad_k_lines = interp3(x_k_datagen,y_k_datagen,z_k_datagen, phan_k_datagen,x_proj_k,y_proj_k,z_proj_k, 'linear');
toc;
if nargin == 4
    update_gui_time(handles);
end

rad_k_lines = rad_k_lines(:, nsample+1:end); % collect only half of the radial lines in k-space starting at the zero of k-space and moving outward

npts = nsample;
data_grads_full = rad_k_lines;

% save phantom object to file
mkdir([fileparts(fileparts(mfilename('fullpath'))) filesep 'phantom_objects' filesep foldername]);
save([fileparts(fileparts(mfilename('fullpath'))) filesep 'phantom_objects' filesep foldername filesep 'parsed_data'], ...
    'npts', 'nspokes', 'data_grads_full', 'x_grad', 'y_grad', 'z_grad');
save([fileparts(fileparts(mfilename('fullpath'))) filesep 'phantom_objects' filesep foldername filesep 'phan_true'], 'phan_true');
