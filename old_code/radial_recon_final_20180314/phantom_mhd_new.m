% creates a phantom of matrix_size in three dimensions. The available types
% are 'complex' which is the Modified Shepp-Logan phantom, 'cubic',
% 'spherical', 'rods', which are 7 rods extending to the edge of the FOV,
% and 'cylinder'. Radius is specified in number of points <matrix_size/2 and
% offcenter is an array of three points [x y z] denoting how far from the
% center the object resides

function phan = phantom_mhd_new(matrix_size, type, phantom_radius, offcenter)
phan = [];
switch type
    case 'complex'
        %% complex phantom
        phan = zeros(matrix_size,matrix_size,matrix_size);
        for n = 1:(matrix_size/2-1);
            phan((matrix_size/2-n):(matrix_size/2+n-1),(matrix_size/2-n):(matrix_size/2+n-1),n)= phantom('Modified Shepp-Logan', n*2);
            phan((matrix_size/2-n):(matrix_size/2+n-1),(matrix_size/2-n):(matrix_size/2+n-1),(matrix_size-n))= phantom('Modified Shepp-Logan', n*2);
        end
        phan(:,:,matrix_size/2)= phantom('Modified Shepp-Logan', matrix_size);
    case 'cubic'
        %% cubic phantom
        if nargin==2
            phantom_radius = matrix_size/4;
            offcenter = [0 0 0];
        elseif nargin==3
            offcenter = [0 0 0];
        end
        if phantom_radius>matrix_size/2
            disp('phantom too big for matrix')
        elseif (max(offcenter)+phantom_radius)>matrix_size || abs((min(offcenter)-phantom_radius))>matrix_size
            disp('phantom too far offcenter')
        else
            phan = zeros(matrix_size,matrix_size,matrix_size);
            phantom_on_x= (matrix_size/2-phantom_radius+1+offcenter(1)):(matrix_size/2+phantom_radius+offcenter(1));
            phantom_on_y= (matrix_size/2-phantom_radius+1+offcenter(2)):(matrix_size/2+phantom_radius+offcenter(2));
            phantom_on_z= (matrix_size/2-phantom_radius+1+offcenter(3)):(matrix_size/2+phantom_radius+offcenter(3));
            phan(phantom_on_x,phantom_on_y,phantom_on_z) ...
                = ones(phantom_radius*2,phantom_radius*2,phantom_radius*2);

        end
        
        case 'spherical'
            if nargin==2
            phantom_radius = matrix_size/4;
            offcenter = [0 0 0];
        elseif nargin==3
            offcenter = [0 0 0];
        end
        if phantom_radius>matrix_size/2
            disp('phantom too big for matrix')
        elseif (max(offcenter)+phantom_radius)>matrix_size || abs((min(offcenter)-phantom_radius))>matrix_size
            disp('phantom too far offcenter')
        else
            phan = zeros(matrix_size,matrix_size,matrix_size);
            for x = 1:matrix_size
                for y = 1:matrix_size
                    for z = 1:matrix_size
                        if sqrt((matrix_size/2+.5-x-offcenter(1))^2+...
                                (matrix_size/2+.5-y-offcenter(2))^2+...
                                (matrix_size/2+.5-z-offcenter(3))^2)<phantom_radius
                           phan(x,y,z)=1;
                        else
                        end
                    end
                end
            end
        end
    case 'rods' % seven rods
       phan = zeros(matrix_size,matrix_size,matrix_size);
       if nargin==2
            phantom_radius = matrix_size/16;
            offcenter = [0 0 0];
        elseif nargin==3
            offcenter = [0 0 0];
        end
        if phantom_radius>matrix_size/2
            disp('phantom too big for matrix')
        elseif (max(offcenter)+phantom_radius)>matrix_size || abs((min(offcenter)-phantom_radius))>matrix_size
            disp('phantom too far offcenter')
        else
            phantom_radius = phantom_radius/4;
            if phantom_radius<1
                phantom_radius = 1;
            end
            for x = 1:matrix_size
                for y = 1:matrix_size
                    if sqrt((matrix_size/2+.5-x-offcenter(1))^2+...
                            (matrix_size/2+.5-y-offcenter(2))^2)<phantom_radius
                        phan(x,y,:)=ones(1,1,matrix_size);
                    elseif sqrt((matrix_size/2+.5-x-offcenter(1)+phantom_radius*3)^2+...
                            (matrix_size/2+.5-y-offcenter(2))^2)<phantom_radius
                        phan(x,y,:)=ones(1,1,matrix_size);
                    elseif sqrt((matrix_size/2+.5-x-offcenter(1)-phantom_radius*3)^2+...
                            (matrix_size/2+.5-y-offcenter(2))^2)<phantom_radius
                        phan(x,y,:)=ones(1,1,matrix_size);
                    elseif sqrt((matrix_size/2+.5-x-offcenter(1)-phantom_radius*1.5)^2+...
                            (matrix_size/2+.5-y-offcenter(2)-phantom_radius*2.2)^2)<phantom_radius
                        phan(x,y,:)=ones(1,1,matrix_size);
                    elseif sqrt((matrix_size/2+.5-x-offcenter(1)-phantom_radius*1.5)^2+...
                            (matrix_size/2+.5-y-offcenter(2)+phantom_radius*2.2)^2)<phantom_radius
                        phan(x,y,:)=ones(1,1,matrix_size);
                    elseif sqrt((matrix_size/2+.5-x-offcenter(1)+phantom_radius*1.5)^2+...
                            (matrix_size/2+.5-y-offcenter(2)-phantom_radius*2.2)^2)<phantom_radius
                        phan(x,y,:)=ones(1,1,matrix_size);
                    elseif sqrt((matrix_size/2+.5-x-offcenter(1)+phantom_radius*1.5)^2+...
                            (matrix_size/2+.5-y-offcenter(2)+phantom_radius*2.2)^2)<phantom_radius
                        phan(x,y,:)=ones(1,1,matrix_size);
                    else
                    end
                end
            end
        end
    case 'cylinder' % squat cylinder
       phan = zeros(matrix_size,matrix_size,matrix_size);
       if nargin==2
            phantom_radius = matrix_size/4;
            offcenter = [0 0 0];
        elseif nargin==3
            offcenter = [0 0 0];
        end
        if phantom_radius>matrix_size/2
            disp('phantom too big for matrix')
        elseif (max(offcenter)+phantom_radius)>matrix_size || abs((min(offcenter)-phantom_radius))>matrix_size
            disp('phantom too far offcenter')
        else
        phantom_on_z= (matrix_size/2-phantom_radius+1+offcenter(3)):(matrix_size/2+phantom_radius+offcenter(3));
           for x = 1:matrix_size
                for y = 1:matrix_size
                    if sqrt((matrix_size/2+.5-x-offcenter(1))^2+...
                           (matrix_size/2+.5-y-offcenter(2))^2)<phantom_radius
                       phan(x,y,phantom_on_z)=1;
                        else
                    end
                end
            end
        end
        
    otherwise
        disp('not a valid phantom type')
end
end

% figure(2); surf(x,z,squeeze(phan(:,matrix_size/2,:)));shading interp; colormap('gray')
