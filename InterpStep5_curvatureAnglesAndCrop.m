function [xyCrop] = InterpStep5_curvatureAnglesAndCrop(X,Y,Z)

% this function finds the angles of the normals to the flat surface

[nx,ny,nz] = surfnorm(X,Y,Z);

rows = size(X,1);
columns = size(X,2);

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

% get the first row and column and the last row and column
cc = bwconncomp(goodAngles);
stats = regionprops(cc, 'BoundingBox');

bbox = stats.BoundingBox;
firstRow = round(bbox(2));
lastRow = round(firstRow+bbox(4));
firstColumn = round(bbox(1));
lastColumn = round(firstColumn+bbox(3));

if lastRow > rows
    lastRow = rows;
end

if lastColumn > columns
    lastColumn = columns;
end

xyCrop = [firstRow,lastRow,firstColumn,lastColumn];

end