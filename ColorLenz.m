function imgFace = ColorLenz(Part,eyeColorSetting,imgFace)
%LENZ 이 함수의 요약 설명 위치
%   자세한 설명 위치

for i = 1 : Part(1,4)
    for j = 1: Part(1,3)
        img(i,j,1) =imgFace(Part(2)+i,Part(1)+j,1);
        img(i,j,2) = imgFace(Part(2)+i,Part(1)+j,2);
        img(i,j,3) = imgFace(Part(2)+i,Part(1)+j,3);
    end
end
imagen = img;
%  imagen = imgaussfilt(imagen, 2);

%% Convert to gray scale
if size(imagen,3)==3 % RGB image
    imagen=rgb2gray(imagen);
end

%% Convert to binary image
if (graythresh(imagen)>=0.2)
    threshold = 0.2;
else 
    threshold = graythresh(imagen);
end

imagen =~im2bw(imagen,threshold);
%% Remove all object containing fewer than 30 pixels
imagen = bwareaopen(imagen,5);

I2 = rgb2gray(imgFace);
for i = 1 : Part(1,4)
    for j = 1: Part(1,3)
        if(imagen(i,j) == 1)
            value = ((255.0 -double(I2(Part(1,2)+i,Part(1,1)+j))*3)/255.0);
           imgFace(Part(1,2)+i,Part(1,1)+j,1) = eyeColorSetting(1)*2/3+imgFace(Part(1,2)+i,Part(1,1)+j,1)/3;
            imgFace(Part(1,2)+i,Part(1,1)+j,2) = eyeColorSetting(2)*2/3+imgFace(Part(1,2)+i,Part(1,1)+j,2)/3;
             imgFace(Part(1,2)+i,Part(1,1)+j,3) =eyeColorSetting(3)*2/3+imgFace(Part(1,2)+i,Part(1,1)+j,3)/3;
        end 
    end
end


end
