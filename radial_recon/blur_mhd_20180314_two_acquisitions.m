% PLACES POINTS IN K-SPACE FROM ACQUISITIONS WITH 2 DIFFERENT GRADIENTS.
% IF YOU CHANGE THIS FILE YOU SHOULD DELETE ALL OF THE SENSITIVITY CORRECTION FILES IN 
% C:\Users\rs2d\Documents\MATLAB\radial_recon_final_20180314\senscor
% AND (potentially) UPDATE THE WAY THOSE FILES ARE GENERATED (below)


function k_phantom_blurred = blur_mhd_20180314_two_acquisitions(recon_matrix_size, nsample, data_in, x_grad, y_grad, z_grad, handles)
    nmeas = length(x_grad);
    
    %% parallel programming for speed. Splitting into number of cores on machine
    num_cores= feature('numcores');
    
    % divide job
    start_pos = floor(linspace(1, nmeas, num_cores + 1));
    start_pos = start_pos(1:end-1);
    end_pos = [(start_pos(2:end) - 1) nmeas];
    
    
    p = gcp('nocreate');
    % create parallel pool if needed
    if isempty(p)
        if nargin == 7
            add_string_gui(handles, 'Creating parallel pool. This may take a minute ....')
        end
        p = parpool([1 num_cores]);
        if nargin == 7
            add_string_gui(handles, 'Parallel pool created')
        end
    end
    % submt jobs to pool
    for ii = 1:p.NumWorkers
        jobs(ii) = parfeval(p, @blur_portion, 1, start_pos(ii), end_pos(ii), recon_matrix_size, nsample, data_in, x_grad, y_grad, z_grad);
    end

    % Collect the results as they become available.
    matrices = cell(1,p.NumWorkers);
    for ii = 1:p.NumWorkers
      [~,value] = fetchNext(jobs);
      matrices{ii} = value;
    end
    
    % calculate total
    k_phantom_blurred = cat(4, matrices{:});
    k_phantom_blurred = sum(k_phantom_blurred, 4);
end

%% actual processing function
function k_phantom_blurred = blur_portion(start, last, recon_matrix_size, nsample, data_in, x_grad, y_grad, z_grad)
    % This creates the zero of k-space at (recon_matrix_size/2 + 1).
    x_k_rect = -recon_matrix_size/2:recon_matrix_size/2-1;
    y_k_rect = -recon_matrix_size/2:recon_matrix_size/2-1;
    z_k_rect = -recon_matrix_size/2:recon_matrix_size/2-1;

    %%
    grad_amp_large = sqrt(x_grad(1)^2+z_grad(1)^2+y_grad(1)^2); % finds the amplitude of the main gradient


    k_phantom_blurred_re = zeros(recon_matrix_size,recon_matrix_size,recon_matrix_size);
    k_phantom_blurred_im = zeros(recon_matrix_size,recon_matrix_size,recon_matrix_size);
    for n = start:last

        % the next 3 lines calculate the distance in k space traversed in each dimension between points
        % this method means that the data in the main gradient stretches from
        % the zero in k-space to the edge of a sphere of diameter equal to
        % recon_matrix_size.

        x_step = x_grad(n)/(nsample-1)*recon_matrix_size/2/grad_amp_large;
        y_step = y_grad(n)/(nsample-1)*recon_matrix_size/2/grad_amp_large;
        z_step = z_grad(n)/(nsample-1)*recon_matrix_size/2/grad_amp_large;

        % the next bit of code takes those steps and maps each point to its
        % proper location in k-space.
        if x_step == 0
            proj_x = zeros(1,nsample);
        else
            proj_x = 0:x_step:x_grad(n)/grad_amp_large*recon_matrix_size/2;
        end

        if y_step == 0
            proj_y = zeros(1,nsample);
        else
            proj_y = 0:y_step:y_grad(n)/grad_amp_large*recon_matrix_size/2;
        end

        if z_step == 0
            proj_z = zeros(1,nsample);
        else
            proj_z = 0:z_step:z_grad(n)/grad_amp_large*recon_matrix_size/2;
        end

        % The rest is primarily just the Chesler code.
        for m = 1:nsample
            data=data_in(n,m);
            if data~=0 % saves time by not processing zeros (confirmed via testing)
                kxl = find(x_k_rect<=proj_x(m), 1, 'last');
                kxu = kxl + 1;
                if kxu>recon_matrix_size; kxu = 1; end
                dx = proj_x(m)-x_k_rect(kxl);
                kyl = find(y_k_rect<=proj_y(m), 1, 'last');
                kyu = kyl + 1;
                if kyu>recon_matrix_size; kyu = 1;  end
                dy = proj_y(m)-y_k_rect(kyl);
                kzl = find(z_k_rect<=proj_z(m), 1, 'last');
                kzu = kzl + 1;
                if kzu>recon_matrix_size; kzu = 1; end
                dz = proj_z(m)-z_k_rect(kzl);
                cx=1-dx;
                cy=1-dy;
                cz=1-dz;
                tmp=cy*cz;

                % I split the real and imaginary parts here as they are calculated
                % faster this way.
                k_phantom_blurred_re(kxl,kyl,kzl)=k_phantom_blurred_re(kxl,kyl,kzl)+real(cx*tmp*data);
                k_phantom_blurred_re(kxu,kyl,kzl)=k_phantom_blurred_re(kxu,kyl,kzl)+real(dx*tmp*data);
                k_phantom_blurred_im(kxl,kyl,kzl)=k_phantom_blurred_im(kxl,kyl,kzl)+imag(cx*tmp*data);
                k_phantom_blurred_im(kxu,kyl,kzl)=k_phantom_blurred_im(kxu,kyl,kzl)+imag(dx*tmp*data);

                tmp=dy*cz;
                k_phantom_blurred_re(kxl,kyu,kzl)=k_phantom_blurred_re(kxl,kyu,kzl)+real(cx*tmp*data);
                k_phantom_blurred_re(kxu,kyu,kzl)=k_phantom_blurred_re(kxu,kyu,kzl)+real(dx*tmp*data);
                k_phantom_blurred_im(kxl,kyu,kzl)=k_phantom_blurred_im(kxl,kyu,kzl)+imag(cx*tmp*data);
                k_phantom_blurred_im(kxu,kyu,kzl)=k_phantom_blurred_im(kxu,kyu,kzl)+imag(dx*tmp*data);

                tmp=cy*dz;
                k_phantom_blurred_re(kxl,kyl,kzu)=k_phantom_blurred_re(kxl,kyl,kzu)+real(cx*tmp*data);
                k_phantom_blurred_re(kxu,kyl,kzu)=k_phantom_blurred_re(kxu,kyl,kzu)+real(dx*tmp*data);
                k_phantom_blurred_im(kxl,kyl,kzu)=k_phantom_blurred_im(kxl,kyl,kzu)+imag(cx*tmp*data);
                k_phantom_blurred_im(kxu,kyl,kzu)=k_phantom_blurred_im(kxu,kyl,kzu)+imag(dx*tmp*data);

                tmp=dy*dz;
                k_phantom_blurred_re(kxl,kyu,kzu)=k_phantom_blurred_re(kxl,kyu,kzu)+real(cx*tmp*data);
                k_phantom_blurred_re(kxu,kyu,kzu)=k_phantom_blurred_re(kxu,kyu,kzu)+real(dx*tmp*data);
                k_phantom_blurred_im(kxl,kyu,kzu)=k_phantom_blurred_im(kxl,kyu,kzu)+imag(cx*tmp*data);
                k_phantom_blurred_im(kxu,kyu,kzu)=k_phantom_blurred_im(kxu,kyu,kzu)+imag(dx*tmp*data);
            end
        end

    end
    k_phantom_blurred = k_phantom_blurred_re+1i*k_phantom_blurred_im;
end