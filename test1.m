clc;
clear;
close all;

addpath("D:\桌面\一年\test_image\MSRC\Image\1\")
addpath("D:\桌面\一年\test_image\MSRC\GroundTruth\1")
%% 读取原始图像
[filename, pathname] = uigetfile( ...
 {'*.bmp;*.jpg;*.png;*.tif;*.jpeg', 'Image Files (*.bmp;*.jpg;*.png;*.tif;*.jpeg)'; ...
         '*.*',                   'All Files (*.*)'}, ...
         'Pick an Image');
fpath=[pathname filename];
img=imread(fpath);
figure;
imshow(img, 'Border','tight');
%% 读取groundtruth
groundtruth = "D:\桌面\一年\test_image\MSRC\GroundTruth\1\";
filename = split(filename, '.');
filename = filename(1);
gt = imread(groundtruth + filename + ".png");
figure;
imshow(gt, 'Border','tight');

%% 分离目标与背景
targetMask = gt;
backgroundMask = ~gt;

%% 计算目标区域RGB均值
targetMode = zeros(1,3);
for c = 1:3
    channel = img(:,:,c);
    pixels = channel(targetMask);
    targetMode(c) = mode(pixels);
end

disp('目标区域RGB众数');
disp(targetMode);

%% 计算背景区域RGB均值
backgroundMode = zeros(1,3);
for c = 1:3
    channel = img(:,:,c);
    pixels = channel(backgroundMask);
    backgroundMode(c) = mode(pixels);
end
disp('背景区域RGB众数');
disp(backgroundMode);

%% 创建结果图像
result = zeros(size(img), 'uint8');

for c = 1:3
    channel = result(:,:,c);
    % 目标区域
    channel(targetMask) = uint8(targetMode(c));
    % 背景区域
    channel(backgroundMask) = uint8(backgroundMode(c));
    result(:,:,c) = channel;
end

%% 显示结果
figure;
imshow(result, 'Border', 'tight');