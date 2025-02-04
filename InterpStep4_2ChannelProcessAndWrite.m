function [NewImageListCh0,NewImageListCh1] = InterpStep4_2ChannelProcessAndWrite(ListCh0,ListCh1,crop_obj,fitobject,tvec,savepath,readpath)
% This function loops over the image volumes in 'ListCh0' and 'ListCh1', performs
% the interpolation using the 'fitobject', uses the 'crop_obj' to crop, and
% then saves the resulting 3D image to a tiff stack in the path 'savepath'.
% New iamge lists with the new filenames are the output.
%
% INPUT:
%           ListCh0: list of channel 0 file names of the deskewed image volumes
%               (to use this function must be in the path to these images)
%           ListCh1: list of channel 1 file names of the deskewed image volumes
%               (to use this function must be in the path to these images)
%           crop_obj: output of InterpStep3_getCropObject
%           fitobject: fit object used for interpolation from InterpStep2_autoGetVerticesV6
%           savepath: path of where you would like to save new interpolated
%               image volumes

% OUTPUT:
%           NewImageListCh0: list of file names for new interpolated image
%               volumes of Channel 0
%           NewImageListCh1: list of file names for new interpolated image
%               volumes of Channel 1

% Written by TV.


% initialize the new image lists
NewImageListCh0 = ListCh0;
NewImageListCh1 = ListCh1;

readfilename = ListCh0{1};
readfilename = strcat(readpath,'/',readfilename);
ImRaw0 =tiffreadVolume(readfilename);
[sx,sy,sz] = size(ImRaw0);

% size of image matrix (the z dimension is actually 113 but from 102
% they're zeros
% sx = 1024;
% sy = 960;
% sz = 113;
[X,Y] = ndgrid(1:sx,1:sy);

%using the fitobject evaluate the fit surface once and it will be used for
%all images
Z = feval(fitobject,X,Y);

Nframes = numel(ListCh0);
for t=1:Nframes
    NewImageListCh0{t} = sprintf('imCh0_%05d.tif',t);
    NewImageListCh1{t} = sprintf('imCh1_%05d.tif',t);
end


for t=tvec
    

    fprintf('processing @ timepoint %04d',t);
    
    % read in the raw deskewed image from the image file list
    readfilename = ListCh0{t};
    readfilename = strcat(readpath,'/',readfilename);
    ImRaw0 =tiffreadVolume(readfilename);


    readfilename1 = ListCh1{t};
    readfilename1 = strcat(readpath,'/',readfilename1);
    ImRaw1 =tiffreadVolume(readfilename1);


    
    % currently ImRaw is a uint16 and must be converted to a double for
    % interpolation.
    ImRaw0 = im2double(ImRaw0);
    ImRaw1 = im2double(ImRaw1);
    
    % perform the interpolation using the Z from the feval
    InterpMat0 = NaN(sx,sy,sz);
    InterpMat1 = NaN(sx,sy,sz);
    for layer= 1:sz
        InterpLayer0 = interpn(ImRaw0,X,Y,Z+layer-1,'nearest');
        InterpMat0(:,:,layer) = InterpLayer0;
        
        InterpLayer1 = interpn(ImRaw1,X,Y,Z+layer-1,'nearest');
        InterpMat1(:,:,layer) = InterpLayer1;
    end
    % set any NaN values to 0
    InterpMat0(isnan(InterpMat0)) = 0;
    InterpMat1(isnan(InterpMat1)) = 0;
    
    % crop the image using the crop object
    InterpmatCrop0 = imcrop3(InterpMat0,crop_obj);
    InterpmatCrop1 = imcrop3(InterpMat1,crop_obj);
    
    % Now convert image back to uint16 because it makes for a smaller file
    % size
    InterpmatCrop0 = im2uint16(InterpmatCrop0);
    InterpmatCrop1 = im2uint16(InterpmatCrop1);
    
    
    sz_new = size(InterpmatCrop0,3);
    
    % write the new image volume as a multi-image tiff at the designated
    % location: savepath
    filename0 = strcat(savepath,'/',sprintf('imCh0_%05d.tif',t));
    imwrite(InterpmatCrop0(:,:,1),filename0);
    
    filename1 = strcat(savepath,'/',sprintf('imCh1_%05d.tif',t));
    imwrite(InterpmatCrop1(:,:,1),filename1);
    
    
    for ii = 2:sz_new
        imwrite(InterpmatCrop0(:,:,ii),filename0,'WriteMode','append');
        imwrite(InterpmatCrop1(:,:,ii),filename1,'WriteMode','append');
    end
    
    % create a new image list
    NewImageListCh0{t} = sprintf('imCh0_%05d.tif',t);
    NewImageListCh1{t} = sprintf('imCh1_%05d.tif',t);
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
end % time loop
end % function


