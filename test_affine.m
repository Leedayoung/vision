clear all;
I = imread('by.jpg');
I = imresize(I, [224,224]);

[Face, imgFace, LeftEye, RightEye, Mouth, LeftEyebrow,  RightEyebrow] = detectFacialRegions(I);

%setting value
mouthSetting = 3;
eyeSetting = 13;

mouthRatio = 1;
eyeRatio = 2.8;
imgFace = twoSideTransform(imgFace, Mouth, mouthSetting,mouthRatio);
imgFace = twoSideTransform(imgFace,LeftEye,eyeSetting,eyeRatio);
imgFace = twoSideTransform(imgFace,RightEye,eyeSetting,eyeRatio);

G = imgFace;
[x,y,~] = size(G);
I(Face(1,2):Face(1,2)+x-1,Face(1,1):Face(1,1)+y-1,:) = imgFace;
imshow(I);

function [imgFace] = twoSideTransform(imgFace, Part, setting, ratio)
    
    if setting > 10
        setting = -(setting-10);
    end
    setting_val = setting/10.0;
    
    tform1 = affine2d([1 setting_val 0; 0 1 0; 0 0 1]);
    tform2 = affine2d([1 -setting_val 0; 0 1 0; 0 0 1]);
    
    Part(1,2) = Part(1,2) + uint8(Part(1,4)*ratio/10);
    Part(1,4) = uint8(Part(1,4)*7/10);
    
    M1_UL = [Part(1,2); Part(1,1)];
    M2_UL = [Part(1,2); Part(1,1)+Part(1,3)/2];
    M1_LR = [Part(1,2)+Part(1,4); Part(1,1)+Part(1,3)/2];
    M2_LR = [Part(1,2)+Part(1,4); Part(1,1)+Part(1,3)];

   if setting_val >= 0
        t_M1_UL = M1_UL;
        t_M1_UR = [(M1_UL(1)+M1_LR(1)*setting_val)/(1+setting_val), M1_LR(2)];
        t_M1_LL = [(M1_LR(1)+M1_UL(1)*setting_val)/(1+setting_val), M1_UL(2)];
        t_M1_LR = M1_LR;

        t_M2_UL = [(M2_UL(1)+M2_LR(1)*setting_val)/(1+setting_val), M2_UL(2)];
        t_M2_UR = [M2_UL(1), M2_LR(2)];
        t_M2_LL = [M2_LR(1), M2_UL(2)];
        t_M2_LR = [(M2_LR(1)+M2_UL(1)*setting_val)/(1+setting_val), M2_LR(2)];
    else
        setting_val = -setting_val;
        t_M1_UL = [(M1_UL(1)+(M1_LR(1))*setting_val)/(1+setting_val), M1_UL(2)];
        t_M1_UR = [M1_UL(1), M1_LR(2)];
        t_M1_LL = [M1_LR(1), M1_UL(2)];
        t_M1_LR = [(M1_LR(1)-(M1_LR(1)-M1_UL(1))*setting_val), M1_LR(2)];

        t_M2_UL = M2_UL;
        t_M2_UR = [(M2_UL(1)+M2_LR(1)*setting_val)/(1+setting_val), M2_LR(2)];
        t_M2_LL = [(M1_LR(1)-(M1_LR(1)-M1_UL(1))*setting_val), M1_LR(2)];
        t_M2_LR = M2_LR; 
%         
        
    end
    
    %
    LeftPart = imgFace(M1_UL(1):M1_LR(1),M1_UL(2):M1_LR(2),:);
    RightPart = imgFace(M2_UL(1):M2_LR(1),M2_UL(2):M2_LR(2),:);
    [x1,y1,~] = size(LeftPart);
    [x2,y2,~] = size(RightPart);
    
    Color = imgFace(Part(1,2)+Part(1,4)-2,Part(1,1)-2,:);
    Color2 = imgFace(Part(1,2)+Part(1,4)-2,Part(1,1)+Part(1,3)+2,:);
    
    LeftPart = imwarp(LeftPart,tform1,'FillValues',[Color(1,1,1);Color(1,1,2);Color(1,1,3)]);
    RightPart = imwarp(RightPart,tform2,'FillValues',[Color2(1,1,1);Color2(1,1,2);Color2(1,1,3)]);
    %
    pos = [Part(1, 2), Part(1, 1)];
    dir = 0;
    r = 1;
    
    for x = Part(1,1):Part(1,1)+Part(1,3)
        for y = Part(1,2):Part(1,2)+Part(1,4)
            imgFace(y, x, :) = [0, 0, 0];
        end
    end

    for i = 1 : (Part(1,3)+1) * (Part(1,4)+1)
        temp = [0, 0, 0];
        cnt = 0;
        for a = -r:r
            for b = -r:r
                if (imgFace(pos(1)+a, pos(2)+b, :) == zeros(3))
                    continue;
                end
                temp(1) = temp(1) + imgFace(pos(1)+a, pos(2)+b, 1)/(4*r*r+4*r+1);
                temp(2) = temp(2) + imgFace(pos(1)+a, pos(2)+b, 2)/(4*r*r+4*r+1);
                temp(3) = temp(3) + imgFace(pos(1)+a, pos(2)+b, 3)/(4*r*r+4*r+1);
                cnt  = cnt + 1;
            end
        end
        imgFace(pos(1), pos(2), 1) = temp(1) /  cnt * (4*r*r+4*r+1);
        imgFace(pos(1), pos(2), 2) = temp(2) /  cnt * (4*r*r+4*r+1);
        imgFace(pos(1), pos(2), 3) = temp(3) /  cnt * (4*r*r+4*r+1);
        if (dir == 0)
            if (imgFace(pos(1) + 1, pos(2), :) == zeros(3))
                pos(1) = pos(1) + 1;
            else
                dir = mod((dir+1), 4);
                pos(2) = pos(2) + 1;
            end
        elseif (dir == 1)
            if (imgFace(pos(1), pos(2) + 1, :) == zeros(3))
                pos(2) = pos(2) + 1;
            else
                dir = mod((dir+1), 4);
                pos(1) = pos(1) - 1;
            end
        elseif (dir == 2)
            if (imgFace(pos(1) - 1, pos(2), :) == zeros(3))
                pos(1) = pos(1) - 1;
            else
                dir = mod((dir+1), 4);
                pos(2) = pos(2) - 1;
            end
        else 
            if (imgFace(pos(1), pos(2) - 1, :) == zeros(3))
                pos(2) = pos(2) - 1;
            else
                dir = mod((dir+1), 4);
                pos(1) = pos(1) + 1;
            end
        end 
    end
    %
    
    xy = [t_M1_UL(2) t_M1_UL(1)+1; t_M1_UR(2) t_M1_UR(1)+1];
    %calculate slope and y intercept
    m1 = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
    n1 = xy(2,2)-xy(2,1) * m1;
   
    xy = [t_M1_LL(2) t_M1_LL(1)-1; t_M1_LR(2) t_M1_LR(1)-1];
    %calculate slope and y intercept
    m2 = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
    n2 = xy(2,2)-xy(2,1) * m2;
    
    LeftPart = imresize(LeftPart, [x1,y1]);
    for n=0:x1-1
        for m = 0:y1-1
            x = LeftPart(n+1,m+1,:);
            if (  m1*(Part(1,1)+m) + n1 - (Part(1,2)+n) ) < 0 && (  m2*(Part(1,1)+m) + n2 - (Part(1,2)+n) ) > 0
                imgFace(Part(1,2)+n,Part(1,1)+m,:) = x;
            end
        end
    end
    
    xy = [t_M2_UL(2) t_M2_UL(1)+1; t_M2_UR(2) t_M2_UR(1)+1];
    %calculate slope and y intercept
    m1 = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
    n1 = xy(2,2)-xy(2,1) * m1;
   
    xy = [t_M2_LL(2) t_M2_LL(1)-1; t_M2_LR(2) t_M2_LR(1)-1];
    %calculate slope and y intercept
    m2 = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
    n2 = xy(2,2)-xy(2,1) * m2;
    
    
    RightPart = imresize(RightPart, [x2,y2]);
    for n=0:x2-1
        for m = y1:y1+y2-1
            x =  RightPart(n+1,m-y1+1,:);
             if (  m1*(Part(1,1)+m) + n1 - (Part(1,2)+n) ) < 0 && (  m2*(Part(1,1)+m) + n2 - (Part(1,2)+n) ) > 0
                imgFace(Part(1,2)+n,Part(1,1)+m,:) = x;
             end
        end
    end
%  imgFace(int32(t_M1_UL(1)), int32(t_M1_UL(2)), :) = [0, 0, 211];
%  imgFace(int32(t_M1_UR(1)), int32(t_M1_UR(2)), :) = [0, 0, 211];
%  imgFace(int32(t_M1_LL(1)), int32(t_M1_LL(2)), :) = [0, 0, 211];
%  imgFace(int32(t_M1_LR(1)), int32(t_M1_LR(2)), :) = [0, 0, 211];
%  imgFace(int32(t_M2_UL(1)), int32(t_M2_UL(2)), :) = [0, 0, 211];
%  imgFace(int32(t_M2_UR(1)), int32(t_M2_UR(2)), :) = [0, 0, 211];
%  imgFace(int32(t_M2_LL(1)), int32(t_M2_LL(2)), :) = [0, 0, 211];
%  imgFace(int32(t_M2_LR(1)), int32(t_M2_LR(2)), :) = [0, 0, 211];

end