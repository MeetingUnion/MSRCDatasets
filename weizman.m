addpath("Weizmann_seg\")

imgPath = "D:\matlab\project\weizman\Weizmann_seg\1obj\src_color\";
gtPath = "D:\matlab\project\weizman\Weizmann_seg\1obj\result\";
%% 结果保存路径
savePath = "D:\matlab\project\weizman\Weizmann_seg\1obj\ground\";

%% 如果结果文件夹不存在，则创建
if ~exist(savePath, 'dir')
    mkdir(savePath);
end

%% 获取所有jpg文件
imgFiles = dir(fullfile(imgPath, '*.png'));

for i = 1 : length(imgFiles)

    imageName = imgFiles(i).name;
    fprintf('正在处理: %s\n', imageName);
    img = imread(fullfile(imgPath, imageName));
    
    [~, name, ~] = fileparts(imageName);

    % 对应GT路径
    gtFile = fullfile(gtPath, name + ".png");

    if ~exist(gtFile, "file")
        fprintf('找不到GT: %s\n', gtFile);
        continue;
    end

    % 读取GT
    gt = imread(gtFile);
    
    % 红色区域
    redMask = (gt(:,:,1)==255) & ...
              (gt(:,:,2)==0) & ...
              (gt(:,:,3)==0);
    
    % 蓝色区域
    blueMask = (gt(:,:,1)==0) & ...
               (gt(:,:,2)==0) & ...
               (gt(:,:,3)==255);
    
    % 背景
    bgMask = ~(redMask | blueMask);
    
    result = zeros(size(img), 'uint8');
    for k = 0 : 2
        switch k
            case 0
                mask = bgMask;
            case 1
                mask = redMask;
            case 2
                mask = blueMask;
        end
        for c = 1 : 3
            channel = double(img(:,:,c));
            meanValue = mean(channel(mask));
            temp = result(:,:,c);
            temp(mask) = uint8(meanValue);
            result(:,:,c) = temp;
        end
    end

    %% 保存结果
    saveName = fullfile(savePath, name + ".png");
    imwrite(result, saveName);

end
fprintf('全部处理完成！\n');