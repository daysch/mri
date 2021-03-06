% This calculates a set of data for a known phantom. It should be used
% after a data set is processed using the radial_recon_rs2d_2018... program
% as it uses the same gradient file and a few other parameters.

% clear
close all
%%
recon_matrix_size = 2^6; % currently fixed
nsample = 2^6; %2^7 max if using 'big_phantom';
phantom_matrix_size = 2*nsample; %max 2^8
% nsample = 2^6; %2^10;

phan_radius = recon_matrix_size/4;
phan_offset = [-7 -5 0];
phan_shape = 'cylinder'; % 'spherical', 'cubic', 'rods', 'complex', 'cylinder'
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

phan_true = phantom_mhd_new(recon_matrix_size,phan_shape, phan_radius, phan_offset);
phan_k_true = ifftshift(ifftn(ifftshift(phan_true)));
phan_recon1_true = fftshift(fftn(fftshift(phan_k_true)));
%% plot slices of the phantom

figure(101); pcolor(squeeze(phan_true(:,:,recon_matrix_size/2))); shading flat; colormap('gray'); title('axial slice')
figure(102); pcolor(squeeze(phan_true(:,recon_matrix_size/2,:))'); shading flat; colormap('gray'); title('coronal slice')
figure(103); pcolor(squeeze(phan_true(recon_matrix_size/2,:,:))'); shading flat; colormap('gray'); title('sagittal slice')

%% create the gradients for sampling k-space
x_grad_orig = x_grad; y_grad_orig = y_grad; z_grad_orig = z_grad;

% [x_grad,y_grad,z_grad] = grad_pattern_rs2d(nrings1);
% nmeas = length(x_grad);
% [x_grad2,y_grad2,z_grad2] = grad_pattern_rs2d(nrings2);
% nmeas2 = length(x_grad2);

figure(10000); scatter3(x_grad_orig,y_grad_orig,z_grad_orig, '.')

%% k-space pseudo-data generation
% This is a very time-consuming step
disp('Generating data .... ')
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
rad_k_lines = zeros(nmeas,phantom_matrix_size); % radial lines in k-space
toc;

%% Also a very time-consuming step
disp('Interpolating data .... ')
tic;
for n = 1:nmeas
    x_proj_k = y_grad(n)/grad_amp_big*x_k_datagen;
    y_proj_k = x_grad(n)/grad_amp_big*y_k_datagen;
    z_proj_k = z_grad(n)/grad_amp_big*z_k_datagen;
    rad_k_lines (n,:) = interp3(x_k_datagen,y_k_datagen,z_k_datagen, phan_k_datagen,x_proj_k,y_proj_k,z_proj_k, 'linear');
end
toc;

rad_k_lines = rad_k_lines(:, nsample+1:end); % collect only half of the radial lines in k-space starting at the zero of k-space and moving outward

%%
npts = nsample;
figure(1); 

plot(1:npts, real(rad_k_lines(1,:)), 1:npts, imag(rad_k_lines(1,:)), 1:npts, abs(rad_k_lines(1,:)))

title('raw data')
legend('real','imag','mag')
xlabel('point number')

% npts_filtered = 2^6;
prepts = input('point at zero of time: '); % this is typically 1 with a large DW, as the PW is small
% the point at prepts that is selected will be unused as well as all
% previous points
firstpt = input('first point of useable data: '); % I've been using 3 or 4.
deadpts = firstpt-prepts-1;
data_grads_undead = rad_k_lines(:, (prepts+1):end);
data_grads_undead(:,1:deadpts) = zeros(size(rad_k_lines,1),deadpts);

% plots the same data from the specified zero in k-space with the data before the first useable point set to zero. 
figure(2); plot(1:(npts-prepts), real(data_grads_undead(1,:)), 1:(npts-prepts), imag(data_grads_undead(1,:)), 1:(npts-prepts), abs(data_grads_undead(1,:)))
title('used data (zeros in deadtime)')
legend('real','imag','mag')
xlabel('point number')

npts = size(data_grads_undead,2); % Uses all the points acquired except those at the beginning.
nsample = npts;
%% to use a specified number of points implement the following code :

% numpts = input('number of points to be used: '); 
% data_grads_undead = data_grads_undead(:,1:deadpts+numpts);
% npts = size(data_grads_undead,2);

%% plots all the data by index number
data_grads = data_grads_undead; % creates variable to be used in next step

figure(31)
pcolor(abs(data_grads(1:5:end,:))); shading flat


%END PSEUDO DATA GENERATION

%% Step 1. Filtering 

% % Each sample of a projection is multiplied by the square of its sample number
% % to compensate for the varying density of measurements in the k-domain.
% Here instead we use filter 2 to multiply by the correct position in
% k-space.

disp('Step 1. Filtering data .... ')
res = 56/64*npts; % I'm not sure what this does, but it is in the Chesler and Wu codes for the hanning filter
c = pi/res; % I'm not sure what this does, but it is in the Chesler and Wu codes for the hanning filter
filter = zeros(1,nsample); % for the main gradient
filter2 = zeros(1,nsample); % for the secondary gradient
filter_type = 'hanning';
switch filter_type
    case 'hanning'
        for n=1:nsample
            filter(n)=0.5*(1+cos(c*n))*(n*n);
            filter2(n)=0.5*(1+cos(c*n*(grad_amp(end)/grad_amp(1))))*(n*n)*(grad_amp(end)/grad_amp(1))^2;
            if n>res
                filter(n) = 0;
            end 
        end
    otherwise
        for n=1:nsample
            filter(n) = n^2;
            filter2(n) = n^2;
        end
end
k_filtered = zeros(nmeas,nsample);
for n=1:nspokes1 % just the points in the first gradient set
    k_filtered(n,:) = data_grads(n,:).*filter;
end

%% applies the scaling factors for oversampling in k-space and undersampling in number of projections
grad_amp_big = sqrt(x_grad(2)^2+z_grad(2)^2+y_grad(2)^2);
grad_amp_small = sqrt(x_grad(end)^2+z_grad(end)^2+y_grad(end)^2);
prog_ratio = (nspokes1)/nspokes2;
dk = grad_amp_big/grad_amp_small;

for n=(nspokes1+1):nspokes % just the points in the second gradient set
    k_filtered(n,:) = data_grads(n,:).*filter2*prog_ratio/dk;
    if deadpts ~= 0;
        k_filtered(n,ceil(dk*deadpts):end) = zeros(1,nsample-ceil(dk*deadpts)+1);
    else
    end

end


%% Step 2. Blurring 
% % From its proper position in the k-domain each sample point is blurred in a trilinear
% % manner onto the eight points of a cubic lattice that surround it.

disp('Step 2. Blurring data .... ')
tic; % timing
k_blurred = blur_mhd_20180314_two_acquisitions(recon_matrix_size, nsample, k_filtered, x_grad, y_grad, z_grad);
toc; % timing

%% Step 3. Sensitivity correction

% % Each point of the reconstruction lattice is divided by a corresponding point of a correction
% % lattice to correct for small variations in local data density around each point.

disp('Step 3. Sensitivity correction .... ')
tic
senscor = senscor_gen_20180314(recon_matrix_size, nsample, nspokes1, filter, filter2, x_grad, y_grad, z_grad);

k_final = zeros(recon_matrix_size,recon_matrix_size,recon_matrix_size);
for n = 1:recon_matrix_size
    for m = 1:recon_matrix_size
        for l = 1:recon_matrix_size
            if senscor(n,m,l) == 0;
                k_final(n,m,l) = 0;
            else
                k_final(n,m,l) = k_blurred(n,m,l)/senscor(n,m,l);
            end
        end
    end
end
toc
%% Step 4. FFT
% The reconstruction lattice is Fourier transformed into a space domain
% lattice.
disp('Step 4. Fourier transform .... ')

first_recon = fftshift(fftn(fftshift(k_final)));

%% Step 5. Blur compensation
% The final image is produced by dividing each point in the space domain by three sinc squared
% functions. one for each of the three components of distance from the origin.

disp('Step 5. Applying blur compensation .... ')

blur_comp_array = blur_compensation(recon_matrix_size);

recon_final = first_recon./blur_comp_array;

%% Plotting

disp('Plotting results .... ')

figure(101); pcolor(squeeze(abs(recon_final(:,:,recon_matrix_size/2+1)))'); shading flat; colormap('gray'); title('axial slice')
figure(102); pcolor(squeeze(abs(recon_final(:,recon_matrix_size/2+1,:)))'); shading flat; colormap('gray'); title('coronal slice')
figure(103); pcolor(squeeze(abs(recon_final(recon_matrix_size/2+1,:,:)))'); shading flat; colormap('gray'); title('sagittal slice')


figure(201); pcolor(squeeze(abs(k_final(:,:,recon_matrix_size/2+1)))); shading flat; colormap('gray'); title('axial slice k-space')
figure(202); pcolor(squeeze(abs(k_final(:,recon_matrix_size/2+1,:)))); shading flat; colormap('gray'); title('coronal slice k-space')
figure(203); pcolor(squeeze(abs(k_final(recon_matrix_size/2+1,:,:)))); shading flat; colormap('gray'); title('sagittal slice k-space')

disp('Done.')
%% Optional plotting for more slices.

% coloraxis = [0 max(max(max(abs(recon_final))))];
% 
% for n = 8:2:56
%     figure(1000+n); pcolor(squeeze(abs(recon_final(:,n,:)))); shading flat; colormap('gray'); title(['coronal slice ' num2str(n)]); caxis(coloraxis)
% end
% for n = 8:2:56
%     figure(1100+n); pcolor(squeeze(abs(recon_final(:,:,n)))); shading flat; colormap('gray'); title(['axial slice ' num2str(n)]); caxis(coloraxis)
% end
% for n = 8:2:56
%     figure(1200+n); pcolor(squeeze(abs(recon_final(n,:,:)))); shading flat; colormap('gray'); title(['sagittal slice ' num2str(n)]); caxis(coloraxis)
% end

