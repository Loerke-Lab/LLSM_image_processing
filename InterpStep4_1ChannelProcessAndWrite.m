function [NewImageListCh1] = InterpStep4_1ChannelProcessAndWrite(ImageListCh1,crop_obj,fitobject,savepath)
% This function loops over the image volumes in 'ImageListCh1', performs
% the interpolation using the 'fitobject', uses the 'crop_obj' to crop, and
% then saves the resulting 3D image to a tiff stack in the path 'savepath'.
% A new image list with the new filenames is the output.
%
% INPUT:
%           ImageListCh1: list of file names of the deskewed image volumes
%               (to use this function must be in the path to these images)
%           crop_obj: output of InterpStep3_getCropObject
%           fitobject: fit object used for interpolation from InterpStep2_autoGetVerticesV6
%           savepath: path of where you would like to save new interpolated
%               image volumes

% OUTPUT:
%           NewImageListCh1: list of file names for new interpolated image
%               volumes

% Written by TV.




readfilename = ImageListCh1{1};
ImRaw0 =tiffreadVolume(readfilename);
[sx,sy,sz] = size(ImRaw0);
[X,Y] = ndgrid(1:sx,1:sy);

% initialize the new image lists
NewImageListCh1 = ImageListCh1;

%using the fitobject evaluate the fit surface once and it will be used for
%all images
Z = feval(fitobject,X,Y);

Nframes = numel(ImageListCh1);

for t=1:Nframes
    
    fprintf('segmentation @ timepoint %04d',t);
    
    % read in the raw deskewed image from the image file list
    readfilename1 = ImageListCh1{t};
    ImRaw1 =tiffreadVolume(readfilename1);
    
    % currently ImRaw is a uint16 and must be converted to a double for
    % interpolation. convert to double
    ImRaw1 = im2double(ImRaw1);
    
    % perform the interpolation using the Z from the feval
    InterpMat1 = NaN(sx,sy,sz);
    for layer= 1:sz
        InterpLayer1 = interpn(ImRaw1,X,Y,Z+layer);
        InterpMat1(:,:,layer) = InterpLayer1;
    end
    % set any NaN values to 0
    InterpMat1(isnan(InterpMat1)) = 0;
    
    % crop the image using the crop object
    InterpmatCrop1 = imcrop3(InterpMat1,crop_obj);
    InterpmatCrop1 = im2uint16(InterpmatCrop1);    

    
    sz_new = size(InterpmatCrop1,3);
    
    % write the new image volume as a multi-image tiff at the designated
    % location: savepath
    filename1 = strcat(savepath,'/',sprintf('imCh1_%05d.tif',t));
    imwrite(InterpmatCrop1(:,:,1),filename1);    
    for ii = 2:sz_new
        imwrite(InterpmatCrop1(:,:,ii),filename1,'WriteMode','append');
    end
    
    % create a new image list
    NewImageListCh1{t} = sprintf('imCh1_%05d.tif',t);
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
end % time loop
end % function


