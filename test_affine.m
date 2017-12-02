function I_after = test_affine(I_before, para)

I = I_before;


%Settings 
mouthSetting = para('mouth');
eyeSetting = para('eye');
hairSetting = para('hair');
eyeColorSetting = para('lense');

I = dyeHair(I,hairSetting);


[Face, imgFace, LeftEye, RightEye, Mouth, LeftEyebrow,  RightEyebrow] = detectFacialRegions(I);
% 
% LeftEyebrow = findEyeboundary(LeftEyebrow,imgFace);
% RightEyebrow = findEyeboundary(RightEyebrow,imgFace);

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

%%
%setting value

mouthRatio = 1;
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

function [imgFace] = oneSideTransform(imgFace, Part, setting, ratio)
    
    if setting > 10
        setting = -(setting-10);
    end
    setting_val = setting/10.0;
    
    tform = affine2d([1 setting_val 0; 0 1 0; 0 0 1]);
    
    Part(1,2) = Part(1,2) + uint8(Part(1,4)*ratio/10);
    Part(1,4) = uint8(Part(1,4)*7/10);
    
    M_UL = [Part(1,2); Part(1,1)];
    M_LR = [Part(1,2)+Part(1,4); Part(1,1)+Part(1,3)/2];
    
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
    
    Part = imgFace(M_UL(1):M_LR(1),M_UL(2):M_LR(2),:);
    [x,y,~] = size(Part);
    
    Part = imwarp(Part,tform);
    
    pos = [Part(1, 2), Part(1, 1)];
    dir = 0;
    r = 1;
    
    for i = Part(1,1):Part(1,1)+Part(1,3)
        for j = Part(1,2):Part(1,2)+Part(1,4)
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
    
    Part = imresize(Part, [x,y]);
    for n=0:x-1
        for m = 0:y-1
            x = Part(n+1,m+1,:);
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
        for m = y:y+y2-1
            x =  RightPart(n+1,m-y+1,:);
             if (  m1*(Part(1,1)+m) + n1 - (Part(1,2)+n) ) < 0 && (  m2*(Part(1,1)+m) + n2 - (Part(1,2)+n) ) > 0
                imgFace(Part(1,2)+n,Part(1,1)+m,:) = x;
             end
        end
    end
    

    M = imgFace(M_UL(1):M2_LR(1),M_UL(2):M2_LR(2),:);
    
    froms = [t_M_UL; t_M2_UL; t_M2_UR; t_M2_LR; t_M_LR; t_M_LL];
    tos = [t_M_UR; t_M2_UR; t_M2_LR; t_M2_LL; t_M_LL; t_M_UL];
    h = M2_LR(1) - M_UL(1)+1;
    w = M2_LR(2) - M_UL(2)+1;
    filter_r = 2;

    for k = 1:length(froms)

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

    imgFace(M_UL(1):M2_LR(1),M_UL(2):M2_LR(2),:) = M;
end

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
        t_M1_UL = M1_UL';
        t_M1_UR = [(M1_UL(1)+M1_LR(1)*setting_val)/(1+setting_val), M1_LR(2)];
        t_M1_LL = [(M1_LR(1)+M1_UL(1)*setting_val)/(1+setting_val), M1_UL(2)];
        t_M1_LR = M1_LR';

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

        t_M2_UL = M2_UL';
        t_M2_UR = [(M2_UL(1)+M2_LR(1)*setting_val)/(1+setting_val), M2_LR(2)];
        t_M2_LL = [(M1_LR(1)-(M1_LR(1)-M1_UL(1))*setting_val), M1_LR(2)];
        t_M2_LR = M2_LR'; 
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
    

    M = imgFace(M1_UL(1):M2_LR(1),M1_UL(2):M2_LR(2),:);
    
    froms = [t_M1_UL; t_M2_UL; t_M2_UR; t_M2_LR; t_M1_LR; t_M1_LL];
    tos = [t_M1_UR; t_M2_UR; t_M2_LR; t_M2_LL; t_M1_LL; t_M1_UL];
    h = M2_LR(1) - M1_UL(1)+1;
    w = M2_LR(2) - M1_UL(2)+1;
    filter_r = 2;

    for k = 1:length(froms)

        from = froms(k, :);
        to = tos(k, :);

        xl = int32(from(1));
        yl = int32(from(2));
        xd = (to(1) - from(1))/abs((to(1) - from(1)));
        yd = (to(2) - from(2))/abs((to(2) - from(2)));
        s = abs((to(2) - from(2)) / (to(1) - from(1)));
        temp = 0;
        while (xl - int32(to(1))) * (xl - int32(from(1))) <= 0 && (yl - int32(to(2))) * (yl - int32(from(2))) <= 0
            Xl = int32(xl - M1_UL(1))+1;
            Yl = int32(yl - M1_UL(2))+1;
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

    imgFace(M1_UL(1):M2_LR(1),M1_UL(2):M2_LR(2),:) = M;
end


