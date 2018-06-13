% Runs the blurring algorithm on a filtered array of ones. IF YOU CHANGE
% THIS FILE YOU SHOULD DELETE ALL OF THE SENSITIVITY CORRECTION FILES IN 
% C:\Users\rs2d\Documents\MATLAB\radial_recon_final_20180314\senscor

function senscor = senscor_gen_20180314(recon_matrix_size, nsample, nspokes1, filter, filter2, x_grad, y_grad, z_grad, buffer)

nmeas = length(x_grad);
k_step3_rad = ones(nmeas,nsample);
nspokes2 = nmeas-nspokes1;
grad_amp_big = sqrt(x_grad(2)^2+z_grad(2)^2+y_grad(2)^2);
grad_amp_small = sqrt(x_grad(end)^2+z_grad(end)^2+y_grad(end)^2);

        %% Step one %%
        % % Each sample of a projection is multiplied by the square
        % %             of its sample number to compensate for the varying density of
        % %             measurements in the k-domain
%         nsample = nsample;
%         filter = zeros(1,nsample);
%         for n=1:nsample
%             filter(n) = n^2;
%         end
        %{
        BELOW CODE REPLACED BY VECTORIZATION 
        k_step3_rad_filtered = zeros(nmeas,nsample);
        for n=1:nspokes1
            k_step3_rad_filtered(n,:) = k_step3_rad(n,:).*filter;
        end

        for n=(nspokes1+1):nmeas
            k_step3_rad_filtered(n,:) = k_step3_rad(n,:).*filter2;
        end
        %}
        
        k_step3_rad_filtered = [(k_step3_rad(1:nspokes1,:) .* filter); k_step3_rad((nspokes1 + 1):nmeas,:) .*filter2] ; 

        %% Step 2 %%
        % % From its proper position in the k-domain
        % % each sample point is blurred in a trilinear
        % % manner onto the eight points of a cubic lattice that
        % % surround it.
        
        % first, I check if the correction table has been calculated and
        % saved previously. If so, that table is used so that time is not
        % wasted.
        
        pathname = [fileparts(which('radial_recon_rs2d_20180314_two_grads')) filesep 'senscor' filesep];
        filename = sprintf('senscor_%dpts_%dspokes_at_%f_%dspokes_at_%f.mat', nsample, nspokes1,grad_amp_big,nspokes2,grad_amp_small);
        if exist(filename, 'file') == 2
            load([pathname filename]);
        else
        k_step3_blurred = blur_mhd_20180314_two_acquisitions(recon_matrix_size, nsample, k_step3_rad_filtered, x_grad, y_grad, z_grad, buffer);
         
        senscor = k_step3_blurred;
        
        save([pathname filename], 'senscor'); %senscor is saved for each new parameter set.
        end
    end
    
