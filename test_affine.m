
function I_after = test_affine(I_before, para)

I = I_before;


%Settings 
mouthSetting = para('mouth');
eyeSetting = para('eye');
hairSetting = para('hair');
eyeColorSetting = para('lense');
%hairSetting
I = dyeHair(I,hairSetting);


[Face, imgFace, LeftEye, RightEye, Mouth, LeftEyebrow,  RightEyebrow] = detectFacialRegions(I);

LeftEyebrow = findEyeboundary(LeftEyebrow,imgFace);
RightEyebrow = findEyeboundary(RightEyebrow,imgFace);

%%  Eye coloring

%create copy facial location for colorlenz
LeftEye_forL = LeftEye;
RightEye_forL = RightEye;
LeftEye_forL(1,2) = LeftEye(1,2)+LeftEyebrow(1,4);
LeftEye_forL(1,4) = LeftEye(1,4)-LeftEyebrow(1,4);
RightEye_forL(1,2) = RightEye(1,2)+RightEyebrow(1,4);
RightEye_forL(1,4) = RightEye(1,4)-RightEyebrow(1,4);

imgFace = ColorLenz(LeftEye_forL,eyeColorSetting,imgFace);
imgFace = ColorLenz(RightEye_forL,eyeColorSetting,imgFace);
imgFace = ColorLenz(Mouth, eyeColorSetting,imgFace);
%%
%setting value

mouthRatio = 0;
LeftEyeRatio = 10 * LeftEyebrow(4)/LeftEye(4);
RightEyeRatio = 10 * RightEyebrow(4)/RightEye(4);
imgFace = twoSideTransform(imgFace, Mouth, mouthSetting,mouthRatio);
imgFace = twoSideTransform(imgFace,LeftEye,eyeSetting,LeftEyeRatio);
imgFace = twoSideTransform(imgFace,RightEye,eyeSetting,RightEyeRatio);

G = imgFace;    
[x,y,~] = size(G);
I(Face(1,2):Face(1,2)+x-1,Face(1,1):Face(1,1)+y-1,:) = imgFace;
imshow(I);
I_after =I;

end

function [imgFace] = oneSideTransform(imgFace, Part, setting, ratio, deny)
    
    if setting > 10
        setting = -(setting-10);
    end
    setting_val = setting/10.0;
    
    tform = affine2d([1 setting_val 0; 0 1 0; 0 0 1]);
    
    Part(1,2) = Part(1,2) + uint32(Part(1,4)*ratio/10);
    Part(1,4) = uint32(Part(1,4)*7/10);
    
    Part(1,1) = floor(Part(1,1));
    Part(1,2) = floor(Part(1,2));
    Part(1,3) = floor(Part(1,3));
    Part(1,4) = floor(Part(1,4));
    
    M_UL = [Part(1,2); Part(1,1)];
    M_LR = [Part(1,2)+Part(1,4); Part(1,1)+Part(1,3)];
    
   if setting_val >= 0
        t_M_UL = M_UL';
        t_M_UR = [(M_UL(1)+M_LR(1)*setting_val)/(1+setting_val), M_LR(2)];
        t_M_LL = [(M_LR(1)+M_UL(1)*setting_val)/(1+setting_val), M_UL(2)];
        t_M_LR = M_LR';
    else
        setting_val = -setting_val;
        t_M_UL = [(M_UL(1)+(M_LR(1))*setting_val)/(1+setting_val), M_UL(2)];
        t_M_UR = [M_UL(1), M_LR(2)];
        t_M_LL = [M_LR(1), M_UL(2)];
        t_M_LR = [(M_LR(1)-(M_LR(1)-M_UL(1))*setting_val), M_LR(2)];        
    end
    
    Part1 = imgFace(uint32(M_UL(1)):uint32(M_LR(1)),uint32(M_UL(2)):uint32(M_LR(2)),:);
    [x,y,~] = size(Part1);
    
    Part1 = imwarp(Part1,tform);
    
    pos = [(Part(1, 2)), (Part(1, 1))];
    dir = 0;
    r = 1;
    
    for i = (Part(1,1)):(Part(1,1)+Part(1,3))
        for j = (Part(1,2)):(Part(1,2)+Part(1,4))
            imgFace(j, i, :) = [0, 0, 0];
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
    
    xy = [t_M_UL(2) t_M_UL(1)+1; t_M_UR(2) t_M_UR(1)+1];
    %calculate slope and y intercept
    m1 = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
    n1 = xy(2,2)-xy(2,1) * m1;
   
    xy = [t_M_LL(2) t_M_LL(1)-1; t_M_LR(2) t_M_LR(1)-1];
    %calculate slope and y intercept
    m2 = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
    n2 = xy(2,2)-xy(2,1) * m2;
    
    Partt = imresize(Part1, [x,y]);
    for n=0:x-1
        for m = 0:y-1
            t = Partt(n+1,m+1,:);
            if ((  m1*(Part(1,1)+m) + n1 - (Part(1,2)+n) ) < 0 && (  m2*(Part(1,1)+m) + n2 - (Part(1,2)+n) ) > 0 )
                imgFace(Part(1,2)+n,Part(1,1)+m,:) = t;
            end
        end
    end

    M = imgFace(uint32(M_UL(1)):uint32(M_LR(1)),uint32(M_UL(2)):uint32(M_LR(2)),:);
    
    froms = [t_M_UL; t_M_UR; t_M_LR; t_M_LL];
    tos = [t_M_UR; t_M_LR; t_M_LL; t_M_UL];
    h = M_LR(1) - M_UL(1)+1;
    w = M_LR(2) - M_UL(2)+1;
    filter_r = 2;
    
    for k = 1:length(froms)
        
        if(deny(k)~=0)
            continue
        end
        
        from = froms(k, :);
        to = tos(k, :);

        xl = int32(from(1));
        yl = int32(from(2));
        xd = (to(1) - from(1))/abs((to(1) - from(1)));
        yd = (to(2) - from(2))/abs((to(2) - from(2)));
        s = abs((to(2) - from(2)) / (to(1) - from(1)));
        temp = 0;
        while (xl - int32(to(1))) * (xl - int32(from(1))) <= 0 && (yl - int32(to(2))) * (yl - int32(from(2))) <= 0
            Xl = int32(xl - M_UL(1))+1;
            Yl = int32(yl - M_UL(2))+1;
            X1 = int32(Xl - filter_r);
            X2 = int32(Xl + filter_r);
            Y1 = int32(Yl - filter_r);
            Y2 = int32(Yl + filter_r);
            if X1 <= 0
                X1 = int32(1);
            end
            if X2 > h
                X2 = int32(h);
            end
            if Y1 <= 0
                Y1 = int32(1);
            end
            if Y2 > w
                Y2 = int32(w);
            end

            %M(X1:X2, Y1:Y2, :) = zeros(X2-X1+1, Y2-Y1+1, 3);
            %M(X1:X2, Y1:Y2, :) = imgaussfilt(M(X1:X2, Y1:Y2, :), 0.9);
            TM = imgaussfilt(imgFace(xl-filter_r:xl+filter_r, yl-filter_r:yl+filter_r, :), 1.5);
            M(X1:X2, Y1:Y2, :) = TM(X1-Xl+filter_r+1:X2-Xl+filter_r+1, Y1-Yl+filter_r+1:Y2-Yl+filter_r+1, :);

            if temp > 1
                yl = yl + yd;
                temp = temp - 1;
            else
                xl = xl + xd;
                temp = temp + s;
            end
        end
    end
    
    imgFace(uint32(M_UL(1)):uint32(M_LR(1)),uint32(M_UL(2)):uint32(M_LR(2)),:) = M(1:uint32(M_LR(1)-M_UL(1)+1), 1:uint32(M_LR(2)-M_UL(2)+1), :);
end

function [imgFace] = twoSideTransform(imgFace, Part, setting, ratio)
    Part1 = [(Part(1,1)) (Part(1,2)) (Part(1, 3)/2) (Part(1,4))];
    Part2 = [(Part(1,1)+Part(1, 3)/2) (Part(1,2)) (Part(1, 3)/2) (Part(1,4))];
    imgFace = oneSideTransform(imgFace, Part1, setting, ratio, [0 1 0 0]);
    if setting >=10
        setting = setting -10;
    else
        setting = setting +10;
    end
    imgFace = oneSideTransform(imgFace, Part2, setting, ratio, [0 0 0 1]);

end


