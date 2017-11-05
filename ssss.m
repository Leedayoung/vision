I = imread('taehee.jpg');
%To detect Mouth
MouthDetect = vision.CascadeObjectDetector('Mouth','MergeThreshold',50);
BB=step(MouthDetect,I);
figure,
imshow(I); hold on
for i = 1:size(BB,1)
 rectangle('Position',BB(i,:),'LineWidth',4,'LineStyle','-','EdgeColor','r');
end
title('Mouth Detection');
hold off;

%To detect Eyes
EyeDetect = vision.CascadeObjectDetector('LeftEyeCART');
BB=step(EyeDetect,I);
figure,imshow(I);
%plot(BB);
rectangle('Position',BB(2,:),'LineWidth',4,'LineStyle','-','EdgeColor','b');
title('Eyes Detection');