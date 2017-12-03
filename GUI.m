function [] = GUI()
window_w = 700;
window_h = 630;

addpath('UI_resource');

S.fh = figure('units','pixels',...
                                  'position',[500 45 window_w window_h],...
                                  'menubar','none',...
                                  'numbertitle','off',...
                                  'name','Áõ¸í»çÁø º¸Á¤ Åø',...
                                  'resize','off');

%% Menubar section
open_img = imread('open_icon.png');
save_img = imread('save_icon.png');
S.menubar_panel = uipanel('Position',[0/window_w 605/window_h 700/window_w 25/window_h]);

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
b1 =imresize(b1, [630 700]);
b2 = imread('pastel_2.jpg');         
b2 =imresize(b2, [630 700]);
b3 = imread('pastel_3.jpg');         
b3 =imresize(b3, [630 700]);
S.total = uicontrol('position', [0 0 700 605],...
                            'cdata', b1,...
                            'enable', 'inactive');
S.im_before = uicontrol('units','pix',...
                                    'position',[50 280 250 300],...
                            'enable', 'inactive');
S.im_original = uicontrol('units','pix',...
                                    'position',[0 0 0 0],...
                            'enable', 'inactive');
                                
S.im_after = uicontrol('units','pix',...
                                    'position',[400 280 250 300],...
                            'enable', 'inactive');
 
S.tag_before = uicontrol('FontSize', 12,...
                                    'FontName', '¸¼Àº °íµñ',...
                                   'Position', [145 235 50 30],...
                                    'string', 'Before', ...
                                    'cdata', imresize(b2, [30 50]),...
                            'enable', 'inactive');
                                
S.tag_after = uicontrol( 'FontSize', 12,...
                                    'FontName', '¸¼Àº °íµñ',...
                                   'Position', [505 235 50 30],...
                                    'string', 'After',...
                                    'cdata', imresize(b2, [30 50]),...
                            'enable', 'inactive');
                        
                                
 %% Control Section        

% S.ctrl_panel = uipanel('Position',[25/window_w 25/window_h 650/window_w 235/window_h],...
%                                   'BackgroundColor', 'white');
S.ctrl_panel = uicontrol('Position', [25 25 650 200],...
                                  'cdata', b1,...
                            'enable', 'inactive');

% Expression
S.ctrl_expression = uicontrol('style', 'pop', 'FontSize', 16,...
                                    'FontName', '¸¼Àº °íµñ',...
                                    'FontWeight', 'bold',...
                                    'string',{'¹Ì¼Ò';'¿ï»ó'},...
                                   'Position', [50 150 90 50]);
                               
S.ctrl_expression_bar = uicontrol('style', 'slide',...
                                    'unit','pix',...
                                    'string','¹Ì¼Ò',...
                                    'min',0,'max',5,'val',2.5,...
                                    'SliderStep',[0.1 0.1],...
                                   'Position', [160 167 400 38]);
 
 %% Hair
 S.ctrl_hair = uicontrol('FontSize', 16,...
                                    'FontName', '¸¼Àº °íµñ',...
                                    'FontWeight', 'bold',...
                                    'string','¿°»ö',...
                                   'Position', [50 100 90 40],...
                                   'cdata', imresize(b3, [40 90]),...
                            'enable', 'inactive');
                               
 S.ctrl_hair_chosen = uicontrol('FontSize', 16,...
                              'Position', [160 100 40 40],...
                               'BackgroundColor', 'w');
                           
for i = 1:6
 S.ctrl_hair_recommand(i) = uicontrol('FontSize', 16,...
                              'Position', [160 + 60 * i 100 40 40]);
end 

%% Color Lense
 S.ctrl_lense = uicontrol('FontSize', 16,...
                                    'FontName', '¸¼Àº °íµñ',...
                                    'FontWeight', 'bold',...
                                    'string','·»Áî',...
                                   'Position', [50 50 90 40],...
                                   'cdata', imresize(b3, [40 90]),...
                            'enable', 'inactive');
                               
 S.ctrl_lense_chosen = uicontrol('FontSize', 16,...
                              'Position', [160 50 40 40],...
                               'BackgroundColor', 'black');

                           
for i = 1:6
 S.ctrl_lense_recommand(i) = uicontrol('FontSize', 16,...
                              'Position', [160 + 60 * i 50 40 40],...
                               'BackgroundColor', 'w');
end


%% Change!
S.change = uicontrol('FontSize', 16,...
                                    'FontName', '¸¼Àº °íµñ',...
                                    'FontWeight', 'bold',...
                                    'style','pushbutton',...
                                     'units','pix',...
                                    'position',[600 80 50 75],...
                                    'string','º¯È¯');

%% Set params
para = containers.Map;
para('mouth') = 0;
para('eye') = 0;
para('hair') = [255 255 255];
para('lense') = [0 0 0];

%% Set Default Hair Color
n = 255;
set(S.ctrl_hair_recommand(1), 'BackgroundColor', [120/n 61/n 61/n]);
set(S.ctrl_hair_recommand(2), 'BackgroundColor', [98/n 0 89/n]);
set(S.ctrl_hair_recommand(3), 'BackgroundColor', [86/n 86/n 86/n]);
set(S.ctrl_hair_recommand(4), 'BackgroundColor', [0 0 147/n]);
set(S.ctrl_hair_recommand(5), 'BackgroundColor', [52/n 7/n 51/n]);
set(S.ctrl_hair_recommand(6), 'BackgroundColor', [170/n 0 0]);

%% Set Default Lense Color
n = 255;
set(S.ctrl_lense_recommand(1), 'BackgroundColor', [120/n 61/n 61/n]);
set(S.ctrl_lense_recommand(2), 'BackgroundColor', [98/n 0 89/n]);
set(S.ctrl_lense_recommand(3), 'BackgroundColor', [86/n 86/n 86/n]);
set(S.ctrl_lense_recommand(4), 'BackgroundColor', [0 0 147/n]);
set(S.ctrl_lense_recommand(5), 'BackgroundColor', [52/n 7/n 51/n]);
set(S.ctrl_lense_recommand(6), 'BackgroundColor', [170/n 0 0]);

%% Install call back
set(S.menubar_load,'callback',{@load_image,S});
set(S.menubar_save,'callback',{@save_image,S});
set(S.change,'callback',{@apply,S, para});
set(S.ctrl_hair_chosen, 'callback',{@load_hair_color,S, para});
set(S.ctrl_lense_chosen, 'callback',{@load_lense_color,S, para});
for i = 1:6
    set( S.ctrl_hair_recommand(i), 'callback',{@set_hair_color,S, i, para});
    set( S.ctrl_lense_recommand(i), 'callback',{@set_lense_color,S, i, para});
end 

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

function [] = set_hair_color(varargin)
S = varargin{3};
i = varargin{4};
para = varargin{5};

color = get(S.ctrl_hair_recommand(i), 'BackgroundColor');
para('hair') = round(255 * color);
set(S.ctrl_hair_chosen, 'BackgroundColor', color);

function [] = set_lense_color(varargin)
S = varargin{3};
i = varargin{4};
para = varargin{5};

color = get(S.ctrl_lense_recommand(i), 'BackgroundColor');
para('lense') = round(255 * color);
set(S.ctrl_lense_chosen, 'BackgroundColor', color);

function [] = apply(varargin)
S = varargin{3};
para = varargin{4};
I_before = get(S.im_original, 'cdata');

expression_str = get(S.ctrl_expression, 'string');
expression_choice = get(S.ctrl_expression, 'val');
expression_level = get(S.ctrl_expression_bar, 'value');


%% Set level of expression
% ¿ô´Â °æ¿ì
% mouthsetting = 0~9
% eyesetting = = `10 ~19
% ½½ÇÂ °æ¿ì
% mouthsetting = 10~19
% eyesetting = 0~9

if(expression_str{expression_choice} == '¹Ì¼Ò')
    para('mouth') = expression_level;
    para('eye')= expression_level + 10;
elseif(expression_str{expression_choice} == '¿ï»ó')
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