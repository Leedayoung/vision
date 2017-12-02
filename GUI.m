function [] = GUI()
window_w = 700;
window_h = 700;

addpath('UI_resource');

S.fh = figure('units','pixels',...
                                  'position',[500 0 window_w window_h],...
                                  'menubar','none',...
                                  'numbertitle','off',...
                                  'name','�������� ���� ��',...
                                  'resize','off');

%% Menubar section
open_img = imread('open_icon.png');
save_img = imread('save_icon.png');
S.menubar_panel = uipanel('Position',[0/window_w 675/window_h 700/window_w 25/window_h]);

S.menubar_load = uicontrol('Parent', S.menubar_panel,...
                                   'Position', [0 0 25 25],...
                                    'cdata', open_img,...
                                    'callback',{@load_image,S});
                                
S.menubar_save = uicontrol('Parent', S.menubar_panel,...
                                   'Position', [25 0 25 25],...
                                    'cdata', save_img ,...
                                    'callback',{@save_image,S});

%% Image section
% S.im_panel = uicontrol('Position',[25/window_w 285/window_h 650/window_w 390/window_h]);
%
b1 = imread('pastel_1.jpg');         
b1 =imresize(b1, [700 700]);
b2 = imread('pastel_2.jpg');         
b2 =imresize(b2, [700 700]);
b3 = imread('pastel_3.jpg');         
b3 =imresize(b3, [700 700]);
S.total = uicontrol('position', [0 0 700 675],...
                            'cdata', b1);
S.im_before = uicontrol('units','pix',...
                                    'position',[50 350 250 300]);
S.im_original = uicontrol('units','pix',...
                                    'position',[0 0 0 0]);
                                
S.im_after = uicontrol('units','pix',...
                                    'position',[400 350 250 300]);
 
S.tag_before = uicontrol('FontSize', 12,...
                                    'FontName', '���� ����',...
                                   'Position', [145 295 50 30],...
                                    'string', 'Before', ...
                                    'cdata', imresize(b2, [30 50]));
                                
S.tag_after = uicontrol( 'FontSize', 12,...
                                    'FontName', '���� ����',...
                                   'Position', [505 295 50 30],...
                                    'string', 'After',...
                                    'cdata', imresize(b2, [30 50]));
                        
                                
 %% Control Section        

% S.ctrl_panel = uipanel('Position',[25/window_w 25/window_h 650/window_w 235/window_h],...
%                                   'BackgroundColor', 'white');
S.ctrl_panel = uicontrol('Position', [25 25 650 250],...
                                  'cdata', b1);

% Expression
S.ctrl_expression = uicontrol('style', 'pop', 'FontSize', 16,...
                                    'FontName', '���� ����',...
                                    'FontWeight', 'bold',...
                                    'string',{'�̼�';'���'},...
                                   'Position', [50 200 90 50]);
                               
S.ctrl_expression_bar = uicontrol('style', 'slide',...
                                    'unit','pix',...
                                    'string','�̼�',...
                                    'min',0,'max',9,'val',4.5,...
                                    'SliderStep',[0.1 0.1],...
                                   'Position', [160 213 410 38]);
 
 %% Hair
 S.ctrl_hair = uicontrol('FontSize', 16,...
                                    'FontName', '���� ����',...
                                    'FontWeight', 'bold',...
                                    'string','����',...
                                   'Position', [50 150 90 40],...
                                   'cdata', imresize(b3, [40 90]));
                               
 S.ctrl_hair_chosen = uicontrol('FontSize', 16,...
                              'Position', [160 150 40 40],...
                               'BackgroundColor', 'w');
                           

%% Color Lense
 S.ctrl_lense = uicontrol('FontSize', 16,...
                                    'FontName', '���� ����',...
                                    'FontWeight', 'bold',...
                                    'string','����',...
                                   'Position', [350 150 90 40],...
                                   'cdata', imresize(b3, [40 90]));
                               
 S.ctrl_lense_chosen = uicontrol('FontSize', 16,...
                              'Position', [460 150 40 40],...
                               'BackgroundColor', 'black');
                               
%% Cry was deleted!
% S.ctrl_cry = uicontrol('Parent', S.ctrl_panel,...
%                                     'FontSize', 16,...
%                                     'string','���',...
%                                     'Enable','off',...
%                                    'Position', [25 140 70 50]);
%                      
% S.ctrl_cry_bar = uicontrol('Parent', S.ctrl_panel,...
%                                     'style', 'slide',...
%                                     'unit','pix',...
%                                     'string','�̼�',...
%                                     'min',1,'max',10,'val',5,...
%                                     'SliderStep',[0.1 0.1],...
%                                    'Position', [115 140 450 50]);


%% Change!
S.change = uicontrol('FontSize', 16,...
                                    'FontName', '���� ����',...
                                    'FontWeight', 'bold',...
                                    'style','pushbutton',...
                                     'units','pix',...
                                    'position',[600 110 50 75],...
                                    'string','��ȯ');

%% Set params
para = containers.Map;
para('mouth') = 0;
para('eye') = 0;
para('hair') = [255 255 255];
para('lense') = [0 0 0];

%% Install call back
set(S.menubar_load,'callback',{@load_image,S});
set(S.menubar_save,'callback',{@save_image,S});
set(S.change,'callback',{@apply,S, para});
set(S.ctrl_hair, 'callback',{@load_hair_color,S, para});
set(S.ctrl_lense, 'callback',{@load_lense_color,S, para});

function [] = load_image(varargin)
S = varargin{3};
[filename,filepath]=uigetfile({'*.*','All Files'},...
  'Select Image');
filename = [filepath, filename];
I = imread(filename);
set(S.im_original,'cdata',I);

I = imresize(I, [300 250]);
set(S.im_before,'cdata',I);
set(S.im_after,'cdata',I);

function [] = save_image(varargin)
S = varargin{3};
[filename,filepath]=uiputfile( ...
{'*.jpg;*.tif;*.png;*.gif;',...
 'All Image Files (*.jpg,*.tif,*.png,*.gif)';
 '*.*',  'All Files (*.*)'},...
 'Save as');

I_after = get(S.im_after, 'cdata');
imwrite(I_after, [filepath, filename]);


function [] = apply(varargin)
S = varargin{3};
para = varargin{4};
I_before = get(S.im_original, 'cdata');

expression_str = get(S.ctrl_expression, 'string');
expression_choice = get(S.ctrl_expression, 'val');
expression_level = get(S.ctrl_expression_bar, 'value');


%% Set level of expression
% ���� ���
% mouthsetting = 0~9
% eyesetting = = `10 ~19
% ���� ���
% mouthsetting = 10~19
% eyesetting = 0~9

if(expression_str{expression_choice} == '�̼�')
    para('mouth') = expression_level;
    para('eye')= expression_level + 10;
elseif(expression_str{expression_choice} == '���')
    para('mouth')= expression_level + 10;
    para('eye') = expression_level;
end
    
I_after = test_affine(I_before, para);

set(S.im_after,'cdata',imresize(I_after, [300 250]));    

            
function [] = load_hair_color(varargin)
S = varargin{3};
para = varargin{4};
color = uisetcolor();
para('hair') = round(255 * color);
set(S.ctrl_hair_chosen, 'BackgroundColor', color);

function [] = load_lense_color(varargin)
S = varargin{3};
para = varargin{4};
color = uisetcolor();
para('lense') = round(255 * color);
set(S.ctrl_lense_chosen, 'BackgroundColor', color);