clc;
clear;
close all;
%% 根据目标区域均值像素获取groudtruth
%% 原始图像路径
imgPath = "D:\matlab\project\test\MSRC\Image\7\";
%% GroundTruth路径
gtPath = "D:\matlab\project\test\MSRC\GroundTruth\7\";
%% 结果保存路径
savePath = "D:\matlab\project\test\MSRC\Result\7\";
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
    gtFile = fullfile(gtPath, name + ".png");
    % 判断GT是否存在
    if ~exist(gtFile, 'file')
        fprintf('找不到GT: %s\n', gtFile);
        continue;
    end
    % 读取GT
    gt = imread(gtFile);

    % 转logical
    gt = gt > 0;
    % 尺寸检查
    if size(gt,1) ~= size(img,1) || size(gt,2) ~= size(img,2)
        gt = imresize(gt, [size(img,1), size(img,2)]);
    end

    %% mask
    targetMask = gt;
    backgroundMask = ~gt;

    %% 计算目标区域众数
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
    %% 创建结果图像
    result = zeros(size(img), 'uint8');
    for c = 1:3
        channel = result(:,:,c);
        % 目标区域
        channel(targetMask) = uint8(targetMean(c));
        % 背景区域
        channel(backgroundMask) = uint8(backgroundMean(c));
        result(:,:,c) = channel;
    end

    %% 保存结果
    saveName = fullfile(savePath, name + "_result.png");
    imwrite(result, saveName);
end
fprintf('全部处理完成！\n');