function [Volmax] = InterpStep1_maxImage(list,tvec)
% This function takes a temporal max projection of all the 3D images in the
% time series. This isn't 



ImRaw1 =tiffreadVolume(list{tvec(1)});

tvec(1) = [];
Volmax = ImRaw1;
for t=tvec


    ImRaw1 =tiffreadVolume(list{t});
    
    Volmax = max(Volmax,ImRaw1);
    
    
end
end







% list = dir('*.tif');
% readfilename1 = list(tvec(1)).name;
% ImRaw1 =tiffreadVolume(readfilename1);
% 
% tvec(1) = [];
% Volmax = ImRaw1;
% for t=tvec
% 
%     readfilename1 = list(t).name;
%     ImRaw1 =tiffreadVolume(readfilename1);
%     %ImRaw1 = im2double(ImRaw1);
%     
%     Volmax = max(Volmax,ImRaw1);
%     
%     
% end
% end