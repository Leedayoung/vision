
------------------ID Photo Revision Program README.txt------------------


 README

 ID Photo Revision Program is useful facial expression change tool. You
 can modify your faical expression to smiley or depressing by clicking 
 button, Furthermore you can adjust the intensity of the expresion can 
 be adjusted by moving bar. Also you can modify image hair color or pup-
 il color what you want by clicking change button.

 Below is a short description of each file.

------------------------------------------------------------------------
 <test_set1>
  
 ID photo image files which are well-applied to our application.

------------------------------------------------------------------------
 <ColorLenz.m>
 
 It changes the pupil color of the face inside the given image. 

 Input parameters:
 Part: sholud be each eyeRegion extracted by extracted detect Facial regions() func.
 eyeColorSetting: RGB color values to change, each value is 0~255
 imgFace: imgFace region extracted detectFacialRegions() func.

------------------------------------------------------------------------
 <GUI.m>
 
 UI code of our application.
    
------------------------------------------------------------------------
 <buildDetector.m>

 build face parts detector object  
 
 Input parameters:
 thresholdFace (optional): MergeThreshold for face detector (Default: 1)
 thresholdParts (optional): MergeThreshold for face parts detector (Default: 1)
 stdsize (optional): size of normalized face (Default: 176)
 
-------------------------------------------------------------------------
 <cheek.m>
 
 Based on the position of both eyes, gives a pink colored effect on the imgFace cheeks  

 Input parameters:
 LeftEye: LeftEye eyeRegion extracted by extracted detect Facial regions() func.
 RightEye: LeftEye eyeRegion extracted by extracted detect Facial regions() func.
 imgFace: imgFace region extracted detectFacialRegions() func.

-------------------------------------------------------------------------
 <detectFaceParts.m>

 detect faces with parts

 [bbox,bbX,faces,bbfaces] = detectFaceParts(detector,X,thick)

 Input parameters:
 detector: the detection object built by buildDetector
 X: image data which should be uint8
 thick(optional): thickness of bounding box (default:1)

--------------------------------------------------------------------------
 <detectFacialRegions.m>

 This function is to find the facial regions (eyes, mouth and eyebrows) on given image

 then return location of facial regions(Face, imgFace, LeftEye, RightEye, Mouth, LeftEyebrow, RightEyebrow)
 with bbox formation.

--------------------------------------------------------------------------
 <dyeHair.m>

 It changes the hair color of the face inside the given image

 Input parameters:
 Image : whole image of given image
 hairSetting : RGB color values to change, each value is 0~255

--------------------------------------------------------------------------
 <findEyeboundary.m>
 
 It find the boundary between eye and eyelid.

 Input parameters:
 Part: Eye Face region which is not devided to eye and eyelid
 ImgFace: imgFace region extracted detectFacialRegions() func.

---------------------------------------------------------------------------
 <image_processing.m>

 find facial region on given image and change it's parameter

 Input parameters:
 I_before: previous image, before processing
 para: setting parameters.

----------------------------------------------------------------------------
 <main.m>

 execute this file to run our application.

----------------------------------------------------------------------------

 CONTACT

 If you have questions or find bug or improvement point, please contact 
 by send email to jjunho2@postech.ac.kr / kjdr86@postech.ac.kr / dayoung@postech.ac.kr/ hyeonjun1882@postech.ac.kr

