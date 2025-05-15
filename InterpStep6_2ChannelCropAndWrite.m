function [] = InterpStep6_2ChannelCropAndWrite(ListCh0,ListCh1,crop_obj,tvec,savepath,readpath)

% this function takes already decurved images and crops them smaller to keep
% only relatively vertical cells

% INPUT:
%           ListCh0: list of channel 0 file names of the interpolated image volumes
%           ListCh1: list of channel 1 file names of the interpolated image volumes
%           crop_obj: output of InterpStep3_getCropObject
%           savepath: path of where you would like to save new interpolated
%               image volumes
%           readpath: path of where the original interpolated images volumes are

for t=tvec
    
    fprintf('processing @ timepoint %04d',t);

    % read in the raw deskewed image from the image file list
    readfilename = ListCh0{t};
    readfilename = strcat(readpath,'/',readfilename);
    ImRaw0 =tiffreadVolume(readfilename);


    readfilename1 = ListCh1{t};
    readfilename1 = strcat(readpath,'/',readfilename1);
    ImRaw1 =tiffreadVolume(readfilename1);

    % currently ImRaw is a uint16 and must be converted to a double
    ImRaw0 = im2double(ImRaw0);
    ImRaw1 = im2double(ImRaw1);

    % crop the image using the crop object
    InterpmatCrop0 = imcrop3(ImRaw0,crop_obj);
    InterpmatCrop1 = imcrop3(ImRaw1,crop_obj);
    
    % Now convert image back to uint16 because it makes for a smaller file size
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