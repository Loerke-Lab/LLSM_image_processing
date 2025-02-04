function [fitobject,Verts,X,Y,Z,Vinterp] = InterpStep2_manualGetFitObject(Ideskew,StartingVerts)
% This is an manual method of obtaining the fit object for interpolating
% surfaces. In a for-loop you go through cross sections and select vertices
% of the apical surface that are used to produce the fitobject.

% INPUTS:
%           Ideskew: a deskewed image from one time point or you can use a
%               temporal average or temporal max projection (as from
%               InterpStep1_maxImage).
%           StartingVertices (optional): If you already have some vertices 
%               you can use this function to add more
%               


close all
% get size is 3D image
[sx,sy,sz] = size(Ideskew);


if nargin >1
    Verts = StartingVerts;
else
    Verts  = [];
end

% loop over the columns and draw positions of apical surface. To reduce the
% amount of work and time we only do this on every 50th slice.
colinterval = 50;
firstDrawFlag = true;
meanradius = 10;
for column = (meanradius+1):colinterval:(sy-meanradius-1)

    slice = squeeze(mean(Ideskew(:,(column-meanradius):(column+meanradius),:),2));
    %slice = imadjust(slice);
    imshow(slice,[]);
    ax = get(gcf,'CurrentAxes');
    choice = menu('ZX slice: ','Edit existing points','Add new points','Skip','Done adding points');
    switch choice
        case 1 % Continue
            if firstDrawFlag
                roi = drawpolyline(ax);
                firstDrawFlag = false;
            else % not first draw

                roi = drawpolyline(ax,'Position',VerticesZX,'Selected',true);
                wait(roi)
            end
            VerticesZX = roi.Position;
            Nverts = size(VerticesZX,1);
            VerticesXYZ = [VerticesZX(:,2), repmat(column,Nverts,1),VerticesZX(:,1)];
            Verts = [Verts;VerticesXYZ];
        case 2 % Fresh Draw

            roi = drawpolyline(ax);
            VerticesZX = roi.Position;
            Nverts = size(VerticesZX,1);
            VerticesXYZ = [VerticesZX(:,2), repmat(column,Nverts,1),VerticesZX(:,1)];
            Verts = [Verts;VerticesXYZ];
            firstDrawFlag = false;
        case 3 % Skip
            continue;

        case 4 % eDon
            break;
    end
    
end


rowinterval = 50;
firstDrawFlag = true;
meanradius = 10;
for row = (meanradius+1):rowinterval:(sx-meanradius-1)

    slice = squeeze(mean(Ideskew((row-meanradius):(row+meanradius),:,:),1));
    %slice = imadjust(slice);
    imshow(slice,[])
    ax = get(gcf,'CurrentAxes');
    choice = menu('ZX slice: ','Edit existing points','Add new points','Skip','Done adding points');
    switch choice
        case 1 % Continue
            if firstDrawFlag
                roi = drawpolyline(ax);
                firstDrawFlag = false;
            else % not first draw

                roi = drawpolyline(ax,'Position',VerticesZY,'Selected',true);
                wait(roi)
            end
            VerticesZY = roi.Position;
            Nverts = size(VerticesZY,1);
            VerticesXYZ = [repmat(row,Nverts,1),VerticesZY(:,2),VerticesZY(:,1)];
            Verts = [Verts;VerticesXYZ];
        case 2
            roi = drawpolyline(ax);
            VerticesZY = roi.Position;
            Nverts = size(VerticesZY,1);
            VerticesXYZ = [repmat(row,Nverts,1),VerticesZY(:,2),VerticesZY(:,1)];
            Verts = [Verts;VerticesXYZ];
            firstDrawFlag = false;
        case 3 % Skip
            continue;

        case 4 % eDon
            break;
    end
    
end

[X,Y] = ndgrid(1:sx,1:sy);
fitobject = fit([Verts(:,1),Verts(:,2)],Verts(:,3),'Poly22');
Z = feval(fitobject,X,Y);


for ii= 1:sz
    Vq = interpn(im2double(V),X,Y,Z+ii-1,'nearest');
    Vinterp(:,:,ii) = Vq;
end

% Visualize the apical surface overlayed on the image

% for ii=1:sx
%     
%     imshow(squeeze(Ideskew(ii,:,:)),[]);
%     %Islice = I(ii,:,:);
%     Yslice = Y(ii,:);
%     Zslice = Z(ii,:);
%     hold on
%     plot(Yslice,Zslice,'LineWidth',2,'Color',[1 0 0]);
%     title(num2str(ii));
%     %pause
%     
%     
% end
    


% Z = feval(fitobject,X,Y);
%min(Z(:))
% plot(fitobject,[SurfaceVerticesXYZ(:,1),SurfaceVerticesXYZ(:,2)],SurfaceVerticesXYZ(:,3))
% for ii= 1:113;Vq = interpn(Idoub,X,Y,Z+ii);A(:,:,ii) = Vq;end

end
