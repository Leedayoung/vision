clear all;
I = imread('by.jpg');
I = imresize(I, [224,224]);

[Face, imgFace, LeftEye, RightEye, Mouth, LeftEyebrow,  RightEyebrow] = detectFacialRegions(I);
Mouth(1,2) = Mouth(1,2) + uint8(Mouth(1,4)*1/10);
Mouth(1,4) = uint8(Mouth(1,4)*7/10);
tform1 = affine2d([2 0.33 0; 0 1 0; 0 0 1]);
tform2 = affine2d([2 -0.33 0; 0 1 0; 0 0 1]);
M1 = imgFace(Mouth(1,2):Mouth(1,2)+Mouth(1,4),Mouth(1,1):Mouth(1,1)+Mouth(1,3)/2,:);
M2 = imgFace(Mouth(1,2):Mouth(1,2)+Mouth(1,4),Mouth(1,1)+Mouth(1,3)/2:Mouth(1,1)+Mouth(1,3),:);
%Color = [0 0 0; 0 0 0; 0 0 0;];
Color = imgFace(Mouth(1,2)-2,Mouth(1,1)-2,:);
Color2 = imgFace(Mouth(1,2)-2,Mouth(1,1)+Mouth(1,3)+2,:);
%B1 = imwarp(M1,tform1,'View');
%B2 = imwarp(M2,tform2);

B1 = imwarp(M1,tform1,'FillValues',[Color(1,1,1);Color(1,1,2);Color(1,1,3)]);
B2 = imwarp(M2,tform2,'FillValues',[Color2(1,1,1);Color2(1,1,2);Color2(1,1,3)]);

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

%imgFace(Mouth(1,2):Mouth(1,2)+x2-1,Mouth(1,1)+y1:Mouth(1,1)+y1+y2-1,:) = B4(:,:,:);

figure
G = imgaussfilt(imgFace,0.8);
[x,y,~] = size(G);
I(Face(1,2):Face(1,2)+x-1,Face(1,1):Face(1,1)+y-1,:) = imgFace;
imshow(I);