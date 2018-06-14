% Runs the radial reconstruction on a data set of your choosing, leaving all the variables in the Matlab Workspace.
function radial_recon_rs2d_20180314_two_grads(handles)
    if nargin == 0
        clear % clears the workspace when called from the command line without arguments
    end

    % function [recon_final, k_final, params] = radial_recon_rs2d_20171220_multi(expno)

    % close all % closes all open figures
    disp('Importing data .... ')
    if nargin == 1    % to GUI
        set(handles.update, 'String', 'Importing data .... ');
    end
    
    tic; % begins a timer for data loading

    % Choose file, if called from command line. If from GUI, check whether same data
    % folder as previously used
    if nargin == 0
        data_path = uigetdir('../');
        [data_raw, params] = openrs2d(data_path);
    else
        % try to find data_path in saved workspace. use already parsed data if data_path hasn't changed
        try
            warning('off','MATLAB:load:variableNotFound') % suppress warning if variables don't exist
            vars = load('workspace','data_path','data_all','params');
            warning('on','MATLAB:load:variableNotFound')
            if ~isfield(vars, 'data_path') || ~isequal(vars.data_path, handles.data_path) ...
                    || ~isfield(vars, 'data_all') || ~isfield(vars, 'params')
                data_path = handles.data_path;
                [data_raw, params] = openrs2d(data_path);
            else
                data_all = vars.data_all; params = vars. params; data_path = vars.data_path;
            end
        catch
            data_path = handles.data_path;
            [data_raw, params] = openrs2d(data_path);
        end
    end
    % data_path = 'C:\Users\rs2d\Spinlab Data\Workspace\zte_mhd\zte_20180320\Data'; % this is the path where the data is stored when developing code in Sequence Development

    
    % Loading parameters from the params structure
    DS = str2double(params.DUMMY_SCAN);
    npts = str2double(params.ACQUISITION_MATRIX_DIMENSION_1D);
    n2d = str2double(params.ACQUISITION_MATRIX_DIMENSION_2D);
    n3d = str2double(params.ACQUISITION_MATRIX_DIMENSION_3D);
    nspokes = str2double(params.TOTAL_SPOKES);
    if ~exist('data_all', 'var') % we may have already received data_all from workspace
        data_all = transpose(reshape(data_raw,npts,n2d*n3d));
    end
    data_grads_full = data_all((DS+1):end,:);
    data_zeros = data_all(1:9,:);
    data_ramp = data_all(10:DS,:);
    x_grad = NaN(nspokes,1);
    y_grad = NaN(nspokes,1);
    z_grad = NaN(nspokes,1);
    try
        grads = csvread([data_path filesep 'gradient_file.txt']); % reads in the gradient file
    catch
        errordlg('Could not load gradient_file.txt');
        return;
    end
        
    x_grad_ramp = grads(10:DS,1); % collect the gradients used in the dummy scans
    x_grad(1:end) = grads((DS+1):end,1); % parses the gradient variable 
    y_grad(1:end) = grads((DS+1):end,2); % parses the gradient variable 
    z_grad(1:end) = grads((DS+1):end,3); % parses the gradient variable 
    toc; % displays data loading time
    if nargin == 1
        update_gui_time(handles); % sends loading time to gui
    end
    %% plots the first line of data and allows the user (if called from command line) to choose the zero of k-space and the number of points lost in the deadtime

    figure(1); 

    plot(1:npts, real(data_grads_full(1,:)), 1:npts, imag(data_grads_full(1,:)), 1:npts, abs(data_grads_full(1,:)))

    title('raw data')
    legend('real','imag','mag')
    xlabel('point number')
    
    % load values from GUI/ask user for input
    if nargin == 0
        % npts_filtered = 2^6;
        prepts = input('point at zero of time: '); % this is typically 1 with a large DW, as the PW is small
        % the point at prepts that is selected will be unused as well as all
        % previous points
        firstpt = input('first point of useable data: '); % I've been using 3 or 4.
    else
        prepts = handles.prepts_val;
        firstpt = handles.firstpt_val;

    end
    deadpts = firstpt-prepts-1;
    data_grads_undead = data_grads_full(:, (prepts+1):end);
    data_grads_undead(:,1:deadpts) = zeros(nspokes,deadpts);

    % plots the same data from the specified zero in k-space with the data before the first useable point set to zero. 
    figure(2); plot(1:(npts-prepts), real(data_grads_undead(1,:)), 1:(npts-prepts), imag(data_grads_undead(1,:)), 1:(npts-prepts), abs(data_grads_undead(1,:)))
    title('used data (zeros in deadtime)')
    legend('real','imag','mag')
    xlabel('point number')

    npts = size(data_grads_undead,2); % Uses all the points acquired except those at the beginning.

    % if number of points specified in gui, uses that
    if nargin == 1 && ~isnan(handles.numpts_val)
        numpts = handles.numpts_val; 
        data_grads_undead = data_grads_undead(:,1:deadpts+numpts);
        npts = size(data_grads_undead,2);
    %% For command line, to use a specified number of points implement the following code :
    % else
    % numpts = input('number of points to be used: '); 
    % data_grads_undead = data_grads_undead(:,1:deadpts+numpts);
    % npts = size(data_grads_undead,2);
    end

    %% plots all the data by index number
    data_grads = data_grads_undead; % creates variable to be used in next step

    figure(31)
    pcolor(abs(data_grads(1:5:end,:))); shading flat

    clear data data_raw grads data_grads_undead %deletes bulky, repetitive data;


    %% calculates the gradient amplitudes and number of acquisition in each gradient set
    grad_amp = sqrt(x_grad.^2+y_grad.^2+z_grad.^2);
    nspokes  = length(x_grad);
    nspokes1 = find(grad_amp==grad_amp(1), 1, 'last');
    nspokes2 = nspokes-nspokes1;

    %% sets the recon size 
    if nargin == 0
        recon_matrix_size = 2^6; % fixed on command line
    else
        recon_matrix_size = handles.recon_matrix_size_val; % size can be edited in gui
    end
    nsample = npts; 
    nmeas = nspokes;
    %% Step 1. Filtering 


    % % Each sample of a projection is multiplied by the square of its sample number
    % % to compensate for the varying density of measurements in the k-domain
    % Here instead we use filter2 to multiply by the correct position in
    % k-space for the second data set.
    % IF YOU CHANGE THE FILTER YOU SHOULD DELETE ALL OF THE SENSITIVITY CORRECTION FILES IN 
    % C:\Users\rs2d\Documents\MATLAB\radial_recon_final_20180314\senscor


    disp('Step 1. Filtering data .... ')
    if nargin == 1
        add_string_gui(handles, 'Step 1. Filtering data ....');
    end
    
    res = 56/64*npts; % I'm not sure what this does, but it is in the Chesler and Wu codes for the hanning filter
    c = pi/res; % I'm not sure what this does, but it is in the Chesler and Wu codes for the hanning filter
    filter = zeros(1,nsample); % for the main gradient
    filter2 = zeros(1,nsample); % for the secondary gradient
    filter_type = 'hanning';
    switch filter_type
        case 'hanning'
            for n=1:nsample
                filter(n)=0.5*(1+cos(c*n))*(n*n);
                filter2(n)=0.5*(1+cos(c*n*(grad_amp(end)/grad_amp(1))))*(n*n)*(grad_amp(end)/grad_amp(1))^2; % scales the n so that it is a relative trajectory in k-space for the smaller gradient
                if n>res
                    filter(n) = 0;
                    filter2(n) = 0;
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
        if deadpts ~=0
            k_filtered(n,ceil(dk*deadpts):end) = zeros(1,nsample-ceil(dk*deadpts)+1);
        end
    end


    %% Step 2. Blurring 
    % % From its proper position in the k-domain each sample point is blurred in a trilinear
    % % manner onto the eight points of a cubic lattice that surround it.
    % % IF YOU CHANGE THIS PORTION YOU SHOULD DELETE ALL OF THE SENSITIVITY CORRECTION FILES IN 
    % C:\Users\rs2d\Documents\MATLAB\radial_recon_final_20180314\senscor

    disp('Step 2. Blurring data .... ')
    if nargin == 1
        add_string_gui(handles, 'Step 2. Blurring data .... ');
    end
    tic; % timing
    k_blurred = blur_mhd_20180314_two_acquisitions(recon_matrix_size, nsample, k_filtered, x_grad, y_grad, z_grad);
    toc; % timing
    if nargin == 1
        update_gui_time(handles); % sends loading time to gui
    end

    %% Step 3. Sensitivity correction

    % Each point of the reconstruction lattice is divided by a corresponding point of a correction
    % lattice to correct for small variations in local data density around
    % each point. IF YOU CHANGE THIS PORTION YOU SHOULD DELETE ALL OF THE SENSITIVITY CORRECTION FILES IN 
    % C:\Users\rs2d\Documents\MATLAB\radial_recon_final_20180314\senscor

    disp('Step 3. Sensitivity correction .... ')
    if nargin == 1
        add_string_gui(handles, 'Step 3. Sensitivity correction .... ');
    end
    tic
    senscor = senscor_gen_20180314(recon_matrix_size, nsample, nspokes1, filter, filter2, x_grad, y_grad, z_grad);
    %{
    %% unvectorized code:
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
    %}

    % should do the same as the above code, in about 1/2 to 2/3 the time
    k_final = k_blurred ./ senscor;
    k_final(senscor == 0) = 0;
 %{
    % same as second version, but runs on GPU for faster processing
    k_blurred_gpu = gpuArray(k_blurred);
    senscor_gpu = gpuArray(senscor);
    k_final_gpu = k_blurred_gpu ./ senscor_gpu;
    k_final = k_final_gpu;
    clear senscor_gpu k_blurred_gpu k_final_gpu;
 %}
    toc
    if nargin == 1
        update_gui_time(handles); % sends loading time to gui
    end
    %% Step 4. FFT
    % The reconstruction (k-space) lattice is Fourier transformed into a space domain
    % lattice.
    disp('Step 4. Fourier transform .... ')
    if nargin == 1
        add_string_gui(handles, 'Step 4. Fourier transform .... ');
    end
    

    first_recon = fftshift(fftn(fftshift(k_final)));

    %% Step 5. Blur compensation
    % The final image is produced by dividing each point in the space domain by three sinc squared
    % functions. one for each of the three components of distance from the origin.

    disp('Step 5. Applying blur compensation .... ')
    if nargin == 1
        add_string_gui(handles, 'Step 5. Applying blur compensation ....');
    end
    blur_comp_array = blur_compensation(recon_matrix_size);

    recon_final = first_recon./blur_comp_array;
    %% Plotting

    disp('Plotting results .... ')
    if nargin == 1
        add_string_gui(handles, 'Plotting results .... ');
    end

    figure(101); pcolor(squeeze(abs(recon_final(:,:,recon_matrix_size/2+1)))'); shading flat; colormap('gray'); title('axial slice')
    figure(102); pcolor(squeeze(abs(recon_final(:,recon_matrix_size/2+1,:)))'); shading flat; colormap('gray'); title('coronal slice')
    figure(103); pcolor(squeeze(abs(recon_final(recon_matrix_size/2+1,:,:)))'); shading flat; colormap('gray'); title('sagittal slice')


    figure(201); pcolor(squeeze(abs(k_final(:,:,recon_matrix_size/2+1)))); shading flat; colormap('gray'); title('axial slice k-space')
    figure(202); pcolor(squeeze(abs(k_final(:,recon_matrix_size/2+1,:)))); shading flat; colormap('gray'); title('coronal slice k-space')
    figure(203); pcolor(squeeze(abs(k_final(recon_matrix_size/2+1,:,:)))); shading flat; colormap('gray'); title('sagittal slice k-space')

    disp('Done.')
    if nargin == 1
        add_string_gui(handles, 'Done. ');
    end
    %% Optional plotting for more slices.
%{
    coloraxis = [0 max(max(max(abs(recon_final))))];

    for n = 8:2:56
        figure(1000+n); pcolor(squeeze(abs(recon_final(:,n,:)))); shading flat; colormap('gray'); title(['coronal slice ' num2str(n)]); caxis(coloraxis)
    end
    for n = 8:2:56
        figure(1100+n); pcolor(squeeze(abs(recon_final(:,:,n)))); shading flat; colormap('gray'); title(['axial slice ' num2str(n)]); caxis(coloraxis)
    end
    for n = 8:2:56
        figure(1200+n); pcolor(squeeze(abs(recon_final(n,:,:)))); shading flat; colormap('gray'); title(['sagittal slice ' num2str(n)]); caxis(coloraxis)
    end
 %}
    %% Save log to CSV, when called from GUI
    if nargin == 1
        addpath(fileparts(fileparts(mfilename)));
        if ~exist('log.csv', 'file')
            fileid = fopen([fileparts(fileparts(mfilename('fullpath'))) filesep 'log.csv'], 'wt');
            if fileid < 0
                errordlg('log cannot be saved');
                error('log cannot be saved');
            end
            fprintf(fileid, 'Point at zero,First point of usable data,Recon matrix size,Number of points');
        else
            fileid = fopen([fileparts(fileparts(mfilename('fullpath'))) filesep 'log.csv'], 'at');
            if fileid < 0
                errordlg('log cannot be saved');
                error('log cannot be saved');
            end
        end
        fprintf(fileid, '\n%d,%d,%d,%d',handles.prepts_val,handles.firstpt_val,handles.recon_matrix_size_val,handles.numpts_val);

        fclose('all');
    end

% save values to workspace. Not really good practice, but needed for
% Marcus's phantom code.
% (want to clear figures, to avoid large data files):
% https://stackoverflow.com/questions/45560181/avoid-saving-of-graphics-in-matlab
clear handles;
varData = whos;
saveIndex = cellfun(@isempty, regexp({varData.class}, 'matlab.(graphics|ui)'));
saveVars = {varData(saveIndex).name};
save('workspace.mat', saveVars{:});
load_workspace;
end

% prints a given string to the gui
function add_string_gui(handles, addition)
    old_update = get(handles.update, 'String');
    old_update = mat_to_string(old_update); % handles.update String is stored as multidimensional matrix. Must be converted to string
    set(handles.update, 'String', sprintf('%s%s', old_update, addition));
    drawnow;
end

% prints the time elapsed to the gui
function update_gui_time(handles)
    add_string_gui(handles, sprintf('Elapsed time is %s seconds', num2str(toc)));
end

% coverts matrix representation of string to datatype string, preserving newlines
function str = mat_to_string(mat)
    mat(:,end + 1) = '\'; mat(:,end + 1) = 'n';
    mat = mat'; 
    mat = mat(:);
    mat = mat';
    str = compose(mat);
    if isa(str, 'cell')
        str = cell2mat(str);
    end
end
    

