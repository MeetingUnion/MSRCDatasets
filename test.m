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
targetMean = zeros(1,3);

for c = 1:3
    channel = img(:,:,c);
    targetMean(c) = mean(channel(targetMask));
end

disp('目标区域RGB均值:');
disp(targetMean);

%% 计算背景区域RGB均值
backgroundMean = zeros(1,3);
for c = 1:3
    channel = img(:,:,c);
    backgroundMean(c) = mean(channel(backgroundMask));
end
disp('背景区域RGB均值:');
disp(backgroundMean);

%% 创建结果图像
result = img;
%% 将目标区域赋值为目标平均像素
for c = 1:3
    channel = result(:,:,c);
    channel(targetMask) = uint8(targetMean(c));
    result(:,:,c) = channel;
end

%% 将背景区域赋值为背景平均像素
for c = 1:3
    channel = result(:,:,c);
    channel(backgroundMask) = uint8(backgroundMean(c));
    result(:,:,c) = channel;
end

%% 显示结果

figure;
imshow(result, 'Border', 'tight');