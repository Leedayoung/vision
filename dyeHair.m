function [Image_origin] = dyeHair(Image,hairSetting)
Image_origin = Image;

%% Convert to gray scale
if size(Image,3)==3 % RGB image
    Image=rgb2gray(Image);
end
threshold = graythresh(Image);

%% Convert to binary `image
if(threshold > 0.5)
    threshold = threshold-0.2;
else
    threshold = 0.3;
end
Image =~imbinarize(Image,threshold);

%% Remove all object containing fewer than 30 pixels
Image = bwareaopen(Image,30);
Image = imfill(Image,'holes');
%% Label connected components
[L, Ne]=bwlabel(Image);

min_i = -1;
min_h = -1;
for n=1:Ne
    [r,~] = find(L==n);
    x = int32(min(r));
    if( (min_h == -1) || (min_h > x))
        min_i = n;
        min_h = min(r);
    end
end
L(L ~= min_i) =0;

[height,width,~] = size(Image_origin);
for y = 1:height
    for x = 1:width
        if(L(y,x) ~=0)
            Image_origin(y,x,1) = hairSetting(1)/3 +Image_origin(y,x,1)*2/3;
            Image_origin(y,x,2) = hairSetting(2)/3 + Image_origin(y,x,2)*2/3;
            Image_origin(y,x,3) = hairSetting(3)/3 + Image_origin(y,x,3)*2/3;
        end
    end
end
end