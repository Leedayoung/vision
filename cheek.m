function imgFace = cheek(LeftEye, RightEye, imgFace)
   
%% Set lefteye as lefteye and vice versa
    if(LeftEye(1, 1) > RightEye(1, 1))
        temp = LeftEye;
        LeftEye = RightEye;
        RightEye = temp;
    end
    
%% Fill Pink Blusher
    imgFace = fillLeft(LeftEye, imgFace);
    imgFace = fillRight(RightEye, imgFace);
    

end

function imgFace_ = fillLeft(Eye, imgFace)
    x = uint32(Eye(1, 1));
    y = uint32(Eye(1, 2)) + uint32(1.2 * Eye(1, 4));
    h = uint32(Eye(1, 4) / 2);
    w = uint32(Eye(1, 3) / 2);
    x = uint32((x + x + w)/2  - (w/2));
    
    gap = 2;   
    
    [~, wlen] = size(x:gap:x+w);
    [~, hlen] = size(y:gap:y+h);

    imgFace(y:gap:y+h, x:gap:x+w, 1) = 255;
    imgFace(y:gap:y+h, x:gap:x+w, 2) = 174;
    imgFace(y:gap:y+h, x:gap:x+w, 3) = 200;
%     imgFace(x:gap:x+w, y:gap:y+h, 1) = 255;
%     imgFace(x:gap:x+w, y:gap:y+h, 2) = 174;
%     imgFace(x:gap:x+w, y:gap:y+h, 3) = 200;

   %% Filter
    sub_imgFace = imcrop(imgFace,[uint32(x-w/2) uint32(y-h/2) 2*w 2*h]);
    filt_sub_imgFace = imgaussfilt(sub_imgFace,4);
    imgFace(uint32(y-h/2):uint32(y-h/2)+2*h, uint32(x-w/2):uint32(x-w/2)+2*w, :) = filt_sub_imgFace; 
    imgFace_ = imgFace;
end


function imgFace_ = fillRight(Eye, imgFace)
    x = uint32(Eye(1, 1));
    y = uint32(Eye(1, 2)) + uint32(1.2 * Eye(1, 4)); % I(x, y,:) =~~
    w = uint32(Eye(1, 4) / 2);
    h = uint32(Eye(1, 3) / 2);
    x = uint32((x + x + w)/2  + (w/2));

    gap = 2;
        
    [~, wlen] = size(x:gap:x+w);
    [~, hlen] = size(y:gap:y+h);

    imgFace(y:gap:y+h, x:gap:x+w, 1) = 255;
    imgFace(y:gap:y+h, x:gap:x+w, 2) = 174;
    imgFace(y:gap:y+h, x:gap:x+w, 3) = 200;
%     imgFace(x:gap:x+w, y:gap:y+h, 1) = 255;
%     imgFace(x:gap:x+w, y:gap:y+h, 2) = 174;
%     imgFace(x:gap:x+w, y:gap:y+h, 3) = 200;

   %% Filtering
    sub_imgFace = imcrop(imgFace,[uint32(x-w/2) uint32(y-h/2) 2*w 2*h]);
    filt_sub_imgFace = imgaussfilt(sub_imgFace,4);
    imgFace(uint32(y-h/2):uint32(y-h/2)+2*h, uint32(x-w/2):uint32(x-w/2)+2*w, :) = filt_sub_imgFace; 
    imgFace_ = imgFace;
end