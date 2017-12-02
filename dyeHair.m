function [Image_origin] = dyeHair(Image,hairSetting)
    %% Show image
    Image_origin = Image;
    %% Convert to gray scale
    if size(Image,3)==3 % RGB image
        Image=rgb2gray(Image);
    end
    threshold = graythresh(Image)-0.2;
    %% Convert to binary image
%     if(threshold > 0.6)
%         threshold = threshold-0.3;
%     else 
%         threshold = 0.3;
%     end

    Image =~im2bw(Image,threshold);
    %% Remove all object containing fewer than 30 pixels
    Image = bwareaopen(Image,30);
    Image = imfill(Image,'holes');
    pause(1)
    %% Show image binary image


    %% Label connected components
    [L Ne]=bwlabel(Image);

    propied=regionprops(L,'BoundingBox');
    hold on

    min_i = -1;
    min_h = -1;

    for n=1:Ne
        [r,~] = find(L==n);
        x = int32(min(r));
        if( (min_h == -1) || min_h > x)
            min_i = n;
            min_h = min(r);
        end
    end

    L(L ~= min_i) =0;
    [height,width,~] = size(Image_origin);
    I2 = rgb2gray(Image_origin);

    for y = 1:height
        for x = 1:width
            if(L(y,x) ~=0)
                value = ((255.0 -double(I2(y,x))*3)/255.0);
                Image_origin(y,x,1) = hairSetting(1)/3 +Image_origin(y,x,1)*2/3;
                Image_origin(y,x,2) = hairSetting(2)/3 + Image_origin(y,x,2)*2/3;
                Image_origin(y,x,3) = hairSetting(3)/3 + Image_origin(y,x,3)*2/3;
%                 Image_origin(y,x,1) = uint32(hairSetting(1)) * uint32(Image_origin(y,x,1)) / 255;
%                 Image_origin(y,x,2) = uint32(hairSetting(2)) * uint32(Image_origin(y,x,2)) / 255;
%                 Image_origin(y,x,3) = uint32(hairSetting(3)) * uint32(Image_origin(y,x,3)) / 255;
            end
        end
    end

    hold off
end
