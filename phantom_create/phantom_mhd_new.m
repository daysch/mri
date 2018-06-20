% creates a phantom of matrix_size in three dimensions. The available types
% are 'rectangular', and 'ellipsoidal' Extent is specified in number of points in
% each direction [x y z]. offcenter is an array of three points [x y z] 
% denoting how far from the center the object resides. Intensity determines
% the color of the grayscale image

function phan = phantom_mhd_new(matrix_size, type, phantom_extent, offcenter, intensity)
phan = [];
switch type
    case 'rectangular'
        %% cubic phantom
        if nargin==2
            phantom_extent = [matrix_size/4, matrix_size/4, matrix_size/4];
            offcenter = [0 0 0];
            intensity = 1;
        elseif nargin==3
            offcenter = [0 0 0];
            intensity = 1;
        elseif nargin==4
            intensity = 1;
        end
        if max(phantom_extent)>matrix_size/2
            error('phantom too big for matrix')
        elseif max(abs(offcenter) + phantom_extent)>matrix_size/2
            error('phantom too far offcenter')
        else
            phan = zeros(matrix_size,matrix_size,matrix_size);
            phantom_on_x= (matrix_size/2-phantom_extent(1)+1+offcenter(1)):(matrix_size/2+phantom_extent(1)+offcenter(1));
            phantom_on_y= (matrix_size/2-phantom_extent(2)+1+offcenter(2)):(matrix_size/2+phantom_extent(2)+offcenter(2));
            phantom_on_z= (matrix_size/2-phantom_extent(3)+1+offcenter(3)):(matrix_size/2+phantom_extent(3)+offcenter(3));
            phan(phantom_on_x,phantom_on_y,phantom_on_z) ...
                = ones(phantom_extent(1)*2,phantom_extent(2)*2,phantom_extent(3)*2);

        end
        
        case 'ellipsoidal'
        if nargin==2
            phantom_extent = [matrix_size/4, matrix_size/4, matrix_size/4];
            offcenter = [0 0 0];
            intensity = 1;
        elseif nargin==3
            offcenter = [0 0 0];
            intensity = 1;
        elseif nargin==4
            intensity = 1;
        end
        if phantom_extent>matrix_size/2
            error('phantom too big for matrix')
        elseif max(abs(offcenter) + phantom_extent)>matrix_size/2
            error('phantom too far offcenter')
        else
            phan = zeros(matrix_size,matrix_size,matrix_size);

            for x = 1:matrix_size
                for y = 1:matrix_size
                    for z = 1:matrix_size
                        if (((matrix_size/2+.5-x+offcenter(1))/phantom_extent(1))^2+...
                            ((matrix_size/2+.5-y+offcenter(2))/phantom_extent(2))^2+...
                            ((matrix_size/2+.5-z+offcenter(3))/phantom_extent(3))^2)<1
                                phan(x,y,z)=1;
                        else
                        end
                    end
                end
            end
        end
        
    otherwise
        error('not a valid phantom type')
end

phan = phan * intensity;
end

% figure(2); surf(x,z,squeeze(phan(:,matrix_size/2,:)));shading interp; colormap('gray')
