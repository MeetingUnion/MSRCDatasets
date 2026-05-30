clc;
clear;
close all;
%% 根据目标区域像素众数获取groudtruth

%% 原始图像路径
imgPath = "D:\桌面\一年\test_image\obvious_new_test_image\MSRA\img_yuan\有晴网络\";
%% GroundTruth路径
gtPath = "D:\桌面\一年\test_image\obvious_new_test_image\MSRA\img_mark\";
%% 结果保存路径
savePath = "D:\桌面\一年\test_image\obvious_new_test_image\MSRA\Result\";
%% 如果结果文件夹不存在，则创建
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

%% 获取所有jpg文件
imgFiles = dir(fullfile(imgPath, '*.jpg'));

%% 开始批处理
for i = 1:length(imgFiles)
    % 当前图像名
    imgName = imgFiles(i).name;
    fprintf('正在处理: %s\n', imgName);

    % 读取原图
    img = imread(fullfile(imgPath, imgName));
    % 获取不带后缀文件名
    [~, name, ~] = fileparts(imgName);
    % 对应GT路径
    gtFile = fullfile(gtPath, name + ".bmp");
    % 判断GT是否存在
    if ~exist(gtFile, 'file')
        fprintf('找不到GT: %s\n', gtFile);
        continue;
    end
    % 读取GT
    gt = imread(gtFile);
    
    gt = rgb2gray(gt);
    gt = imresize(gt,...
             [size(img,1),size(img,2)],...
             'nearest');

    % 8邻域连通
    L = bwlabel(gt, 8);
    % 查看目标数量
    numObj = max(L(:));
    fprintf('检测到 %d 个目标\n',numObj);
    
    % 创建结果图
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

    % 处理每个目标
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

    %% 保存结果
    saveName = fullfile(savePath, name + ".png");
    imwrite(result, saveName);
end
fprintf('全部处理完成！\n');