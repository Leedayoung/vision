clear all;
I = imread('jehun.jpg');
I = imresize(I, [224,224]);

[Face, imgFace, LeftEye, RightEye, Mouth, LeftEyebrow,  RightEyebrow] = detectFacialRegions(I);
Mouth(1,2) = Mouth(1,2) + uint8(Mouth(1,4)*1/10);
Mouth(1,4) = uint8(Mouth(1,4)*7/10);
tform1 = affine2d([1 0.33 0; 0 1 0; 0 0 1]); %두번째 파라미터값을 조정해 입술의 기울기 조정
tform2 = affine2d([1 -0.33 0; 0 1 0; 0 0 1]);
M1_UL = [Mouth(1,2), Mouth(1,1)];
M2_UL = [Mouth(1,2), Mouth(1,1)+Mouth(1,3)/2];
M1_LR = [Mouth(1,2)+Mouth(1,4), Mouth(1,1)+Mouth(1,3)/2];
M2_LR = [Mouth(1,2)+Mouth(1,4), Mouth(1,1)+Mouth(1,3)];
M1 = imgFace(M1_UL(1):M1_LR(1),M1_UL(2):M1_LR(2),:);
M2 = imgFace(M2_UL(1):M2_LR(1),M2_UL(2):M2_LR(2),:);
%Color = [0 0 0; 0 0 0; 0 0 0;];
Color = imgFace(Mouth(1,2)-2,Mouth(1,1)-2,:);
Color2 = imgFace(Mouth(1,2)-2,Mouth(1,1)+Mouth(1,3)+2,:);
%B1 = imwarp(M1,tform1,'View');
%B2 = imwarp(M2,tform2);

B1 = imwarp(M1,tform1,'FillValues',[Color(1,1,1);Color(1,1,2);Color(1,1,3)]);
B2 = imwarp(M2,tform2,'FillValues',[Color2(1,1,1);Color2(1,1,2);Color2(1,1,3)]);

t_M1_UL = M1_UL;
t_M1_UR = [(M1_UL(1)*3+M1_LR(1))/4, M1_LR(2)];
t_M1_LL = [(M1_LR(1)*3+M1_UL(1))/4, M1_UL(2)];
t_M1_LR = M1_LR;

t_M2_UL = [(M2_UL(1)*3+M2_LR(1))/4, M2_UL(2)];
t_M2_UR = [M2_UL(1), M2_LR(2)];
t_M2_LL = [M2_LR(1), M2_UL(2)];
t_M2_LR = [(M2_LR(1)*3+M2_UL(1))/4, M2_LR(2)];

[x1,y1,~] = size(M1);
B3 = imresize(B1, [x1,y1]);
for n=0:x1-1
    for m = 0:y1-1
        x = B3(n+1,m+1,:);
        if (isequal(x(:,:),[Color(1,1,1),Color(1,1,2),Color(1,1,3)]) == 0)
            imgFace(Mouth(1,2)+n,Mouth(1,1)+m,:) = x;
        end
    end
end

%imgFace(Mouth(1,2):Mouth(1,2)+x1-1,Mouth(1,1):Mouth(1,1)+y1-1,:) = B3(:,:,:);
[x2,y2,~] = size(M2);
B4 = imresize(B2, [x2,y2]);
for n=0:x2-1
    for m = y1:y1+y2-1
        x = B4(n+1,m-y1+1,:);
        if (isequal(x(:,:),[Color2(1,1,1),Color2(1,1,2),Color2(1,1,3)]) == 0)
            imgFace(Mouth(1,2)+n,Mouth(1,1)+m,:) = x;
        end
    end
end

%imgFace(int32(t_M1_UL(1)), int32(t_M1_UL(2)), :) = [0, 0, 255];
%imgFace(int32(t_M1_UR(1)), int32(t_M1_UR(2)), :) = [0, 0, 255];
%imgFace(int32(t_M1_LL(1)), int32(t_M1_LL(2)), :) = [0, 0, 255];
%imgFace(int32(t_M1_LR(1)), int32(t_M1_LR(2)), :) = [0, 0, 255];
%imgFace(int32(t_M2_UL(1)), int32(t_M2_UL(2)), :) = [0, 0, 255];
%imgFace(int32(t_M2_UR(1)), int32(t_M2_UR(2)), :) = [0, 0, 255];
%imgFace(int32(t_M2_LL(1)), int32(t_M2_LL(2)), :) = [0, 0, 255];
%imgFace(int32(t_M2_LR(1)), int32(t_M2_LR(2)), :) = [0, 0, 255];


%imgFace(Mouth(1,2):Mouth(1,2)+x2-1,Mouth(1,1)+y1:Mouth(1,1)+y1+y2-1,:) = B4(:,:,:);

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

figure;
G = imgaussfilt(imgFace,0.8);
G = imgFace;
[x,y,~] = size(G);
I(Face(1,2):Face(1,2)+x-1,Face(1,1):Face(1,1)+y-1,:) = imgFace;
imshow(I);