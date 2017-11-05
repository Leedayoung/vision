%  An example how to use landmarks points
%  The below codes are not optimized. It is straightforward for easy
%  understanding.
%  Copyright 2014 by Caroline Pacheco do E.Silva
%  If you have any problem, please feel free to contact Caroline Pacheco do E.Silva.
%  lolyne.pacheco@gmail.com
%
%  If the algorithm is tested with other databases,  you may need to change
%  some parameters (See the file readme)
%% 

clc
clear all

% read the input image
I = imread('bohyunghan.jpg');
I = imresize(I, [224,224]);

[imgFace, LeftEye, RightEye, Mouth, LeftEyebrow,  RightEyebrow] = detectFacialRegions(I);

% config landmarks to Eyes and Mouth (4 and 5)
landconf = 4;
% landmarks the mouth
imgMouth = (imgFace(Mouth(1,2):Mouth(1,2)+Mouth(1,4),Mouth(1,1):Mouth(1,1)+Mouth(1,3),:));
%imshow(imgMouth
[landMouth, MouthCont] = mouthProcessing(imgMouth,landconf);

imshow(imgFace,'InitialMagnification',50); hold on;
showsLandmarks(landMouth,MouthCont,Mouth,landconf);
