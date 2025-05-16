function [goodAnglesPerim] = InterpStep7_cropXYZandGetBinaryPerimeter(X,Y,Z)

% this function crops the inputs X, Y, and Z from the fit parameters used for
% decurving the image, then gets the binary perimeter for regions with acceptable angles


% Crop #1
vec1 = input('Input ([row min, row max, col min, col max, z min z max]):');

crop_obj_1 = images.spatialref.Cuboid([vec1(3),vec1(4)],[vec1(1),vec1(2)],[vec1(5),vec1(6)]);

cropX1 = imcrop3(X,crop_obj_1);
cropY1 = imcrop3(Y,crop_obj_1);
cropZ1 = imcrop3(Z,crop_obj_1);


% Crop #2
vec2 = input('Input ([row min, row max, col min, col max, z min z max]):');

crop_obj_2= images.spatialref.Cuboid([vec2(3),vec2(4)],[vec2(1),vec2(2)],[vec2(5),vec2(6)]);

cropX2 = imcrop3(cropX1,crop_obj_2);
cropY2 = imcrop3(cropY1,crop_obj_2);
cropZ2 = imcrop3(cropZ1,crop_obj_2);

[nx,ny,nz] = surfnorm(cropX2,cropY2,cropZ2);

rows = size(cropX2,1);
columns = size(cropX2,2);

normals = reshape([nx ny nz], rows,columns,3);

a = zeros(rows,columns);
b = zeros(rows,columns);
c = -ones(rows,columns);

flat = reshape([a b c], rows,columns,3);

% loop through rows, then columns
for r = 1:rows
    for c = 1:columns
        normalVec = squeeze(normals(r,c,:))';
        %flatVec = squeeze(flat(r,c,:))';
        flatVec = [0,0,-1];
        angle(r,c) = atan2d(norm(cross(normalVec,flatVec)),dot(normalVec,flatVec));
    end
end


% get the logical index of angles less than acceptable
goodAngles = angle<3;

% get the perimeter of the region of interest
goodAnglesPerim = bwperim(goodAngles);

end