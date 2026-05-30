clc;
clear;
close all;
% 通过连通区域将目标区域划分为多个类
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
groundtruth = "D:\桌面\一年\test_image\obvious_new_test_image\MSRA\img_mark\";
filename = split(filename, '.');
filename = filename(1);
gt = imread(groundtruth + filename + ".bmp");
gt = rgb2gray(gt);
gt = imresize(gt,...
             [size(img,1),size(img,2)],...
             'nearest');

figure;
imshow(gt, 'Border','tight');


%% 连通域标记
% 8邻域连通
L = bwlabel(gt, 8);


%% 查看目标数量
numObj = max(L(:));
fprintf('检测到 %d 个目标\n',numObj);

%% 创建结果图
result = zeros(size(img),'uint8');

%% 先处理背景
bgMask = (L==0);
bgMean = zeros(1,3);

for c = 1:3
    channel = double(img(:,:,c));
    bgMean(c) = mean(channel(bgMask));
end



for c = 1:3
    temp = result(:,:,c);
    temp(bgMask) = uint8(bgMean(c));
    result(:,:,c) = temp;
end

%% 再处理每个目标
for k = 1:numObj
    fprintf('处理目标 %d\n',k);
    mask = (L==k);
    meanRGB = zeros(1,3);
    %% RGB均值
    for c = 1:3
        channel = double(img(:,:,c));
        meanRGB(c) = mean(channel(mask));
    end
    fprintf('RGB = [%.2f %.2f %.2f]\n',...
            meanRGB(1),...
            meanRGB(2),...
            meanRGB(3));
    %% 重建
    for c = 1:3
        temp = result(:,:,c);
        temp(mask) = uint8(meanRGB(c));
        result(:,:,c) = temp;
    end
end
%% 显示结果
figure;
imshow(result,'Border','tight');
title('区域均值重建');

%% 显示标签图
% figure;
% imagesc(L);
% axis image;
% colorbar;