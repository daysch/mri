function phan = phantom_mhd_new(matrix_size, type, phantom_extent, offcenter, intensity, rotAng, rotDir)
% creates a phantom of matrix_size in three dimensions. The available types
% are 'rectangular', and 'ellipsoidal' Extent is specified in number of points in
% each direction [x y z]. offcenter is an array of three points [x y z] 
% denoting how far from the center the object resides. Intensity determines
% the color of the grayscale image. rotAng and rotDir determine the angle
% and direction for the phantom to be rotated.
% adds arbitrary number (2.2251e-200) to declare black spaces as relavent
% data

% max dimension of phantom is diagonal of box
diag = ceil(sqrt(matrix_size^2*3));
if mod(diag, 2) ~= 0
    diag = diag + 1;
end

switch type
    case 'rectangular'
        %% cubic phantom
        if nargin==2
            phantom_extent = [matrix_size/4, matrix_size/4, matrix_size/4];
            offcenter = [0 0 0];
            intensity = 1;
            rotAng = 0;
            rotDir = [0 0 0];
        elseif nargin==3
            offcenter = [0 0 0];
            intensity = 1;
            rotAng = 0;
            rotDir = [0 0 0];
        elseif nargin==4
            intensity = 1;
            rotAng = 0;
            rotDir = [0 0 0];
        elseif nargin == 5 || nargin == 6
            rotAng = 0;
            rotDir = [0 0 0];
        end
        
        % create initial phantom
        phan = zeros(diag, diag, diag);
        phantom_on_x= max(1,(diag/2-phantom_extent(1)+1)):min(diag,(diag/2+phantom_extent(1)));
        phantom_on_y= max(1,(diag/2-phantom_extent(2)+1)):min(diag,(diag/2+phantom_extent(2)));
        phantom_on_z= max(1,(diag/2-phantom_extent(3)+1)):min(diag,(diag/2+phantom_extent(3)));
        phan(phantom_on_y,phantom_on_x,phantom_on_z) ...
            = ones(min(phantom_extent(2)*2, diag),min(phantom_extent(1)*2, diag),min(phantom_extent(3)*2, diag));
            
    case 'ellipsoidal'
        if nargin==2
            phantom_extent = [matrix_size/4, matrix_size/4, matrix_size/4];
            offcenter = [0 0 0];
            intensity = 1;
            rotAng = 0;
            rotDir = [0 0 0];
        elseif nargin==3
            offcenter = [0 0 0];
            intensity = 1;
            rotAng = 0;
            rotDir = [0 0 0];
        elseif nargin==4
            intensity = 1;
            rotAng = 0;
            rotDir = [0 0 0];
        elseif nargin == 5 || nargin == 6
            rotAng = 0;
            rotDir = [0 0 0];
        end
        
        phan = zeros(diag,diag,diag);
        for x = 1:diag
            for y = 1:diag
                for z = 1:diag
                    if (((diag/2+.5-x)/phantom_extent(1))^2+...
                        ((diag/2+.5-y)/phantom_extent(2))^2+...
                        ((diag/2+.5-z)/phantom_extent(3))^2)<1
                            phan(y,x,z)=1;
                    end
                end
            end
        end
        
    otherwise
        error('not a valid phantom type')
end

% rotate, shift, and crop matrix
phan = transformation(phan, rotAng, rotDir, offcenter, matrix_size);

% change intensity
phan = phan * intensity;
end

function phan = transformation(phan, rotAng, rotDir, offcenter, matrix_size)
    phan = rotImg3(phan, rotAng, rotDir([2 1 3]), 'linear', false, false);
    phan = shift(phan, offcenter);
    phan = crop(phan, matrix_size);
    phan = phan + 2.2251e-200; % arbitrary number to avoid clipping when rotating
end

% shifts matrix by offset, replaces ends with zeros to undo circular aspect
function phan = shift(input_mat, offcenter)
    phan = circshift(input_mat, offcenter([2 1 3])); % circshift is in format [y x z]
    
    if offcenter(1) < 0 % replace right side with 0s
        xstart = size(input_mat, 2) + offcenter(1);
        xend = size(input_mat, 2);
    else                % replace left side with 0s
        xstart = 1;
        xend = offcenter(1)+1;
    end
    if offcenter(2) < 0
        ystart = size(input_mat, 1) + offcenter(2);
        yend = size(input_mat, 1);
    else
        ystart = 1;
        yend = offcenter(2)+1;
    end
    if offcenter(3) < 0
        zstart = size(input_mat, 3) + offcenter(3);
        zend = size(input_mat, 3);
    else
        zstart = 1;
        zend = offcenter(3)+1;
    end
        
    % put zeros in proper place for each 
    phan(ystart:yend,:,:) = 0;
    phan(:,xstart:xend,:) = 0;
    phan(:,:,zstart:zend) = 0;
end

% crops matrix from center to appropriate size. Assumes input_mat is at
% least matrix_size and and divisble divisble by two in each direction.
% Assumes matrix_size is divisble by two
function phan = crop(input_mat, matrix_size)
    sz = size(input_mat);
    phan = input_mat(sz(1)/2-matrix_size/2+1:sz(1)/2+matrix_size/2, ...
                     sz(2)/2-matrix_size/2+1:sz(2)/2+matrix_size/2, ...
                     sz(3)/2-matrix_size/2+1:sz(3)/2+matrix_size/2);
end