function  [Face, imgFace, LeftEye, RightEye, Mouth, LeftEyebrow,  RightEyebrow] = detectFacialRegions(I)
%  This function is to find the facial regions (eyes, mouth and eyebrows)
%  Reference:
%  Silva, Caroline; Schnitman, Leizer ;  Oliveira, Luciano. "Detection of Facial Landmarks
%  Using Local-Based Information". The 19th edition of the Brazilian Conference on Automation - CBA 2012, 
%  Campina Grande, PB, Brazil (oral presentation), September 3, 2012. 
%
%  Copyright 2014 by Caroline Pacheco do E.Silva
%  If you have any problem, please feel free to contact Caroline Pacheco do E.Silva.
%  lolyne.pacheco@gmail.com
%%

%To detect Face
 FDetect = vision.CascadeObjectDetector('FrontalFaceCART');
 Face = step(FDetect,I);
 imgFace = (I(Face(1,2):Face(1,2)+Face(1,4),Face(1,1):Face(1,1)+Face(1,3),:));

 LeftEye = [0 0 0 0];
 RightEye = [0 0 0 0];
%  %To detect Left Eye
%  EyeDetect = vision.CascadeObjectDetector('LeftEyeCART');
%  Eye=step(EyeDetect,imgFace);
%  LeftEye  = Eye(1,:);
%  %To detect Right Eye
% %
%  RightEye = Eye(2,:);
 
%To detect Mouth
 MouthDetect = vision.CascadeObjectDetector('Mouth','MergeThreshold',16);
 findMouth=step(MouthDetect,imgFace);
 orderMouth= sortrows(findMouth,2);
 posMouth = size(findMouth,1);
 Mouth = orderMouth(posMouth,:);

%To detect Left Eyebrow
 LeftEyebrow   = LeftEye;
 LeftEyebrow(4) = (LeftEyebrow(4)/2)-4;
 LeftEyebrow(3) = LeftEyebrow(3);
 LeftEyebrow(4) = uint8(LeftEyebrow(4));
 LeftEyebrow(3) = uint8(LeftEyebrow(3));

%To detect Right Eyebrow
 RightEyebrow  = RightEye;
 RightEyebrow(4) =  (RightEyebrow(4)/2);
 RightEyebrow(3) = RightEyebrow(3);
 RightEyebrow(4) = uint8(RightEyebrow(4));
 RightEyebrow(3) = uint8(RightEyebrow(3));

end