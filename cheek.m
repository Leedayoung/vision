function imgFace = cheek(LeftEye, RightEye, imgFace)
% 
%     imgFace = fillLeft(LeftEye, imgFace);
%     imgFace = fillRight(RightEye, imgFace);
    
end

function imgFace_ = fillLeft(Eye, imgFace)
    x = Eye(1, 1);
    y = Eye(1, 2) + uint32(1.2 * Eye(1, 4));
    h = uint32(Eye(1, 4) / 2);
    w = uint32(Eye(1, 3) / 2);
    x = uint32((x + x + w)/2);
    
    gap = 2;   
    
    [~, wlen] = size(x:gap:x+w);
    [~, hlen] = size(y:gap:y+h);

    imgFace(y:gap:y+h, x:gap:x+w, 1) = 255;
    imgFace(y:gap:y+h, x:gap:x+w, 2) = 174;
    imgFace(y:gap:y+h, x:gap:x+w, 3) = 200;
    imgFace_ = imgFace;
end


function imgFace_ = fillRight(Eye, imgFace)
    x = Eye(1, 1);
    y = Eye(1, 2) + uint32(1.2 * Eye(1, 4)); % I(x, y,:) =~~
    w = uint32(Eye(1, 4) / 2);
    h = uint32(Eye(1, 3) / 2);
    x = uint32((x + x + w)/2  - (w/2));

    gap = 2;
        
    [~, wlen] = size(x:gap:x+w);
    [~, hlen] = size(y:gap:y+h);

    imgFace(y:gap:y+h, x:gap:x+w, 1) = 255;
    imgFace(y:gap:y+h, x:gap:x+w, 2) = 174;
    imgFace(y:gap:y+h, x:gap:x+w, 3) = 200;
    imgFace_ = imgFace;
end