function [ im ] = rotImg3( img, teta, ax, method, pad, shrink)
%rotImg3 rotates 3 image
% --- Syntax
%   [ im ] = rotImg3( img, teta, ax, method )
% img is the 3D image (must be cubic), teta is the angle in radians, ax is the 
% axis of rotation for exmple [1 0 0], method can be nearest for nearest
% neighbor of linear interpolation. pad =(true|false) is wheter or not to pad the object
% with nan or to crop the image after the rotation and leave it same size
% shrink determines whether to crop matrix to cube of smallest size while
% by eliminating zeros. min_sz determines smallest size of matrix to
% return. Will pad both sides of each dimension with zeros to make this size.
% 
% example use for rotating a cylinder:
% nS = 30; % cylynder size
% cylBlock = repmat([1 zeros(1,nS-2) 1], nS,1);
% cyl = zeros(nS,nS,nS);
% cyl(:,:,1) = ones(nS,nS);
% cyl(:,:,end) = ones(nS,nS);
% cyl(:,:,2:end-1) = repmat( cylBlock, [1 1 nS-2]);
% rotatedCyl = rotImg3(double(cyl), 1*pi/4 , [0 1 0 ]);
% isosurface(rotatedCyl);

if ~exist('method', 'var')
    method = 'linear';
end
if ~exist('pad', 'var')
    pad = true;
end

if teta == 0
    im = img;
    return;
end

if ~exist('shrink', 'var')
    shrink = true;
end

sz = size(img);
if ~all(sz == sz(1))
    error('rotation requires cubic matrix'); % requiring cubic matrix for simplicity
end
ratM = rotationmat3D(teta, ax);

% padding image
if pad
    s = max(sz);
    imagepad = zeros([3 * s, 3 * s, 3 * s]);
    ss = floor((3*s - sz) / 2);
    imagepad(ss(1)+1:ss(1)+sz(1), ...
        ss(2)+1:ss(2)+sz(2), ...
        ss(3)+1:ss(3)+sz(3)) = img;
else
    imagepad = img;
end

[nd1, nd2, nd3] = size(imagepad);
midx=(nd1+1)/2;
midy=(nd2+1)/2;
midz=(nd3+1)/2;

% rotate about center
ii = zeros(size(imagepad));
idx = find( ~ii );
[X, Y, Z] = ind2sub (size(imagepad) , idx ) ;


XYZt = [X(:)-midx Y(:)-midy Z(:)-midz]*ratM;
XYZt = bsxfun(@plus,XYZt,[midx midy midz]);

xout = XYZt(:,1);
yout = XYZt(:,2);
zout = XYZt(:,3);

imagerotF = interp3(imagepad, yout, xout, zout, method);
im = reshape(imagerotF, size(imagepad));

% shrink image to use minimal size, while maintaining squareness
if shrink
    idx=find(abs(im)>0);
    [mx, my, mz] = ind2sub(size(im), idx);
    min_all = min([mx my mz]);
    max_all = max([mx my mz]);
    im = im(min_all:max_all, min_all:max_all, min_all:max_all);
end

end
