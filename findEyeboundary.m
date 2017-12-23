function [rePart] = findEyeboundary(Part,imgFace)
%FINDEYEBOUNDARY 이 함수의 요약 설명 위치
%   자세한 설명 위치
A = Part;

x = A(1,1);
y = A(1,2);
w = A(1,3);
h = A(1,4);
rePart = Part;

for i = -6:6
    h = h+i;
    L = imgFace(int32(y+h), int32(x+w), 1)/3+imgFace(int32(y+h), int32(x+w), 2)/3+imgFace(int32(y+h), int32(x+w), 3)/3;
    R = imgFace(int32(y+h), int32(x), 1)/3+ imgFace(int32(y+h), int32(x), 2)/3+ imgFace(int32(y+h), int32(x), 3)/3;
    M1 = (imgFace(int32(y+h), int32(x+w/4), 1)/3+ imgFace(int32(y+h), int32(x+w/4), 2)/3+ imgFace(int32(y+h), int32(x+w/4), 3)/3);
    M2 = (imgFace(int32(y+h), int32(x+w/2), 1)/3+ imgFace(int32(y+h), int32(x+w/2), 2)/3+ imgFace(int32(y+h), int32(x+w/2), 3)/3);
    M3 = (imgFace(int32(y+h), int32(x+3*w/4), 1)/3+ imgFace(int32(y+h), int32(x+3*w/4), 2)/4+ imgFace(int32(y+h), int32(x+3*w/4), 3)/3);
    M = M1/3 + M2/3 + M3/3;
    
    if((L/2+R/2)>=M)
        diff = (L/2+R/2)-M;
    else
        diff = M-(L/2+R/2);
    end
    
    lines(i+7) = diff;
    h = A(1,4);
end

index = find(lines==min(min(lines)));
index = index-7;

rePart(4) = rePart(4)+index(1);


end
