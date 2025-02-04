function [crop_obj] = InterpStep3_getCropObject(Im)
% The interpolated image volume (Im) contains a lot of zeros (black pixels)
% which result from interpolation outside the image volume. This
% function allows the user to see how many of these zeros there are along
% different dimensions of the 3D volume and use that information to
% manually select X, Y, and Z ranges of a cuboid crop region. The point is 
% to exclude places that don't have many cells or adequate tissue depth. 
% For example, if in a certain x-y position we can only see a few microns 
% of a cell's depth it might be best to crop that area out to avoid it and
% reduce image data size. 
% 
% INPUT:
%           Im: 3D interpolated image (i.e. the output of
%                   InterpStep2_autoGetVerticesV6)
%
% OUTPUT:
%           crop_obj: a cuboid crop object to be used as input to 'imcrop3'
%                   to crop interpolated image volumes in the next step
%
% Written by TV

Mask = Im>0;

[sx,sy,sz] = size(Im); 

subplot(1,3,1)
plot(sum(Mask(:,round(sy/2),:),3));
ylabel('Sum of non-zero pixels','FontSize',16)
xlabel('Row pixel position','FontSize',16)
title(['Total rows: ',num2str(sx)],'FontSize',16);


subplot(1,3,2)
plot(sum(Mask(round(sx/2),:,:),3))
ylabel('Sum of non-zero pixels','FontSize',16)
xlabel('Col pixel position','FontSize',16)
title(['Total rolunms: ',num2str(sy)],'FontSize',16);

subplot(1,3,3)
plot(squeeze(sum(Mask,[1,2])))
ylabel('Sum of non-zero pixels','FontSize',16)
xlabel('Z-layer','FontSize',16)
title(['Total Z slices: ',num2str(sz)],'FontSize',16);

% the user inputs a vector of row start and stop, column start and stop,
% and z start and stop values to give the cuboid cropping region. The
% selected values are subjective to what the user wants to keep or exclude.
vec = input('Input ([row min, row max, col min, col max, z min z max]):');


crop_obj = images.spatialref.Cuboid([vec(3),vec(4)],[vec(1),vec(2)],[vec(5),vec(6)]);

croppedIm = imcrop3(Im,crop_obj);

szc = size(croppedIm,3);

% show the n
for ii=1:2:szc
    subplot(1,2,1)
    imshow(Im(:,:,ii),[]);title('Uncropped')
    subplot(1,2,2)
    imshow(croppedIm(:,:,ii),[]);title('Cropped')
    pause;
end

