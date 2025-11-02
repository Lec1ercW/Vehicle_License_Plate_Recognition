% ----------------------------------------------------------------------- %
% Author: HUAXUAN WANG, wanghuaxuan2000@163.com
% Date  : 2022/06/30
% Copyright (C) 2022 HUAXUAN WANG. All Rights Reserved.
% ----------------------------------------------------------------------- %
% 使用说明：请将待识别图像移至workspace文件夹下的target中，将本程序第16行的imread中的文件名更改为待识别图像文件名
% ----------------------------------------------------------------------- %

clc;
clear all;
close all;

%% 图象预处理

% 导入图像，将图像像素设置为1000*1000
image = imread('.\target\0jpg');
im1 = imresize(image, [1000, 1000]);
pic = im1;
figure(1)
subplot(3, 3, 1); imshow(im1);

% 提取图象 S 通道信息
fig1 = rgb2hsv(im1);
im2 = fig1(:, :, 2);
subplot(3, 3, 2); imshow(im2);

% 增强图像对比度，并进行二值化
im3 = imadjust(im2);
im4 = im2bw(im3);
subplot(3 ,3, 3); imshow(im4);

% 对图像进行平滑处理，并提取二值化图像中的白色部分
se1 = strel('rectangle', [20, 20]);
im5 = imclose(im4, se1);
[m ,n] = size(im5);
for i = 1:m
    for j = 1:n
        if im5(i, j) == 0
            pic(i, j, :) = 255;
        end
    end
end
im6 = pic;
subplot(3, 3, 4); imshow(im6);

% 对图像中蓝色区域进行提取
im6r = im6(:, :, 1);
im6g = im6(:, :, 2);
im6b = im6(:, :, 3);
for i = 1:m
    for j = 1:n
        if im6b(i, j)<65 || im6r(i, j)>100 || im6g(i, j)>100
            pic(i, j, :) =255;
        end
    end
end
im7 = pic;
subplot(3, 3, 5); imshow(im7);

% 提取新图象 S 通道信息
fig5 = rgb2hsv(im7);
im8 = fig5(:, :, 2);
subplot(3, 3, 6); imshow(im8);

% 增强新图像对比度，并进行二值化
se2 = [0 1 0; 1 1 1; 0 1 0];
fig4 = imdilate(im8, se2);
fig5 = imdilate(fig4, se2);
im9 = imadjust(fig4);
im10 = im2bw(im9);
subplot(3 ,3, 7); imshow(im10);

% 对提取图像进行膨胀处理，进一步提取特征，为保证下一步切割顺利，再次进行平滑处理。
fig2 = imdilate(im10, se2);
fig3 = imdilate(fig2, se2);
im11 = bwareaopen(fig3, 4000);
im12 = imclose(im11, se1);
subplot(3, 3, 8); imshow(im12);

%% 从原图像中切割出车牌部分

% 寻找车牌位置
p1 = zeros(5000, 2);
h1 = 1;
for i = 1: m-51
    for j = 1: n-81
        if im12(i, j) == 1
            for k = 1:10
                if im12(i, j+k) == 1 && im12(i+k, j) == 1  && im12(i, j+70+k) == 1 && im12(i+40+k, j) == 1 
                    p1(h1, 1) = i;
                    p1(h1, 2) = j;
                    h1 = h1+1;
                end
            end
        end
    end
end

for i = 1:500
    if p1(i, 1) == 0 && p1(i, 2) == 0
        p1(i, 1) = m+n;
    % elseif abs(p1(i, 2) - n/2)*2/n > 0.95 || abs(p1(i, 1) - m/2)*2/m >0.95
    %    p1(i, 2) = m+n;  
    end
end

s1 = sum(p1,2);
min1 = min(s1);
[row1, column1] = find(s1 == min1);
X1 = p1(row1, 1);
Y1 = p1(row1, 2);

p2 = zeros(5000, 2);
h2 = 1;
for i = 51: m
    for j = 81: n
        if im12(i, j) == 1
            for k = 1:10
                if im12(i, j-70+k) == 1 && im12(i-40+k, j) == 1 && im12(i, j-k) == 1 && im12(i-k, j) == 1
                    p2(h2, 1) = i;
                    p2(h2, 2) = j;
                    h2 = h2+1;
                end
            end
        end
    end
end

for i = 1:500
    if p2(i, 1) == 0 && p2(i, 2) == 0
        p2(i, 1) = -m-n;
    % elseif abs(p2(i, 2) - n/2)*2/n > 0.95 || abs(p2(i, 1) - m/2)*2/m >0.95
    %    p2(i, 1) = -m-n;  
    end
end

s2 = sum(p2,2);
max1 = max(s2);
[row2, column2] = find(s2 == max1);
X2 = p2(row2, 1);
Y2 = p2(row2, 2);

% 定义裁剪区域并进行裁剪
x1 = min(X1)+4;
y1 = min(Y1)+4;
x2 = max(X2)-4;
y2 = max(Y2)-4;
rect = [y1, x1, y2-y1, x2-x1];
im13 = imcrop(im4, rect);
 figure(2)
 imshow(im13);

%% 将车牌部分再次进行分割，得到单个字符

% 参照车牌国际标准，进行第一次分割，并将切割结果放入im14中
[m, n] = size(im13);
n1 = 0.1511*n;
n2 = 0.2807*n;
n3 = 0.3307*n;
n4 = 0.4602*n;
n5 = 0.5898*n;
n6 = 0.7193*n;
n7 = 0.8489*n;

rect1 = [0, 0, n1, m];
rect2 = [n1, 0, n2-n1, m];
rect3 = [n3, 0, n4-n3, m];
rect4 = [n4, 0, n5-n4, m];
rect5 = [n5, 0, n6-n5, m];
rect6 = [n6, 0, n7-n6, m];
rect7 = [n7, 0, n-n7, m];

 figure(3)
pic1 = imresize(imcrop(im13, rect1), [100, 50]);  im14(:, :, 1) = pic1(:, :);
     subplot(1, 7, 1); imshow(im14(:, :, 1));
pic2 = imresize(imcrop(im13, rect2), [100, 50]);  im14(:, :, 2) = pic2(:, :);
     subplot(1, 7, 2); imshow(im14(:, :, 2));
pic3 = imresize(imcrop(im13, rect3), [100, 50]);  im14(:, :, 3) = pic3(:, :);
     subplot(1, 7, 3); imshow(im14(:, :, 3));
pic4 = imresize(imcrop(im13, rect4), [100, 50]);  im14(:, :, 4) = pic4(:, :);
     subplot(1, 7, 4); imshow(im14(:, :, 4));
pic5 = imresize(imcrop(im13, rect5), [100, 50]);  im14(:, :, 5) = pic5(:, :);
     subplot(1, 7, 5); imshow(im14(:, :, 5));
pic6 = imresize(imcrop(im13, rect6), [100, 50]);  im14(:, :, 6) = pic6(:, :);
     subplot(1, 7, 6); imshow(im14(:, :, 6));
pic7 = imresize(imcrop(im13, rect7), [100, 50]);  im14(:, :, 7) = pic7(:, :);
     subplot(1, 7, 7); imshow(im14(:, :, 7));


%% 对im14中的图象进行二次裁剪
for k = 1: 7
    
    % 首先对首尾字符进行处理
    if k == 1 || k == 7
        piccut = im14(:, :, k);
        [m, n] = size(piccut);
        m1 = 0; m2 = 0;
        
        %搜索裁剪的上边界
        for i = 1: 1: m/2
            count1 = 0;
            for j = 1: n
                if piccut(i, j) == 0
                    count1 = count1+1;
                end
            end
            if count1 <= 6
                m1 = i+4;
                break
            end
        end
        
        %搜索裁剪的下边界
        for i = m: -1: m/2
            count2 = 0;
            for j = 1: n
                if piccut(i, j) == 0
                    count2 = count2+1;
                end
            end
            if count2 <= 6
                m2 = i-4;
                break
            end
        end
        if m2 == 0;
            m2 = m;
        end
        
       % 首先根据行数，做高度方向的裁剪
        rect10 = [0, m1, n, m2-m1];
        im15 = imcrop(piccut, rect10);
        [m, n] = size(im15);
        n1 = 0; n2 = 0;
        
        % 搜索裁剪的左边界
        for j = 1: 1: n/2
            count3 = 0;
            for i = 1: m
                if piccut == 0
                    count3 = count3+1;
                end
            end
            if count3 <= 6
                n1 = j+4;
                break
            end
        end
        
        % 搜索裁剪的右边界
        for j = n: -1: n/2
            count4 = 0;
            for i = 1: m
                if piccut(i, j) == 0
                    count4 = count4+1;
                end
            end
            if count4 <= 6
                n2 = j-4;
                break
            end
        end
        if n2 == 0;
            n2 = n;
        end
        
        % 对图像进行二次处理
        rect11 = [n1, 0, n2-n1, m];
        im16 = imresize(imcrop(im15, rect11), [100,50]);
        im14(:, :, k) = im16;
    end
    
    % 搜索图像切割边界
    picpro = im14(:, :, k);
    [m, n] = size(picpro);
    m1 = 0; m2 = 0;
    
    if k == 1
        
        % 搜索切割的上边界
        for i = 1: 1: m/2
            count1 = 0;
            for j = 1: n
                if picpro(i, j) == 0
                    count1 = count1+1;
                end
            end
            if count1 >= 5
                 m1 = i+1;
                 break
            end
        end

        % 搜索切割的下边界
         for i = m: -1: m/2
            count2 = 0;
            for j = 1: n
                  if picpro(i, j) == 0
                      count2 = count2+1;
                  end
            end
            if count2 >= 5
                m2 = i-1;
                break
            end
        end
        if m2 == 0
            m2 = m;
        end

        % 首先根据行数，做高度方向的裁剪
        rect12 = [0, m1, n, m2-m1];
        im17 = imcrop(picpro, rect12);
        [m, n] = size(im17);
        n1 = 0; n2 = 0;

        % 寻找切割的左边界
        for j = 1: 1: n/2
            count3 = 0;
            for i = 1: m
                if im17(i, j) == 0
                    count3 = count3+1;
                end
            end
            if count3 >= 6
                n1 = j+1;
                break
            end
        end

        % 寻找切割的右边界
        for j = n: -1: n/2
            count4 = 0;
            for i = 1:m
                if im17(i, j) == 0
                    count4 = count4+1;
                end
            end
            if count4 >= 6
                n2 = j-1;
                break
            end
        end
        if n2 == 0;
            n2 = n;
        end

        % 完成切割工作
        rect13 = [n1, 0, n2-n1, m];
        im18 = imresize(imcrop(im17, rect13), [40, 20]);
        fipic(:, :, k) = im18;
        
    else
        % 搜索切割的上边界
        for i = m/2: -1: 1
            count1 = 0;
            for j = 1: n
                if picpro(i, j) == 0
                    count1 = count1+1;
                end
            end
            if count1 <= 5
                 m1 = i+1;
                 break
            end
        end

        % 搜索切割的下边界
         for i = m/2: 1: m
            count2 = 0;
            for j = 1: n
                  if picpro(i, j) == 0
                      count2 = count2+1;
                  end
            end
            if count2 <= 5
                m2 = i-1;
                break
            end
        end
        if m2 == 0
            m2 = m;
        end

        % 首先根据行数，做高度方向的裁剪
        rect12 = [0, m1, n, m2-m1];
        im17 = imcrop(picpro, rect12);
        [m, n] = size(im17);
        n1 = 0; n2 = 0;

        % 寻找切割的左边界
        for j = n/2: -1: 1
            count3 = 0;
            for i = 1: m
                if im17(i, j) == 0
                    count3 = count3+1;
                end
            end
            if count3 <= 6
                n1 = j+1;
                break
            end
        end

        % 寻找切割的右边界
        for j = n/2: 1: n
            count4 = 0;
            for i = 1:m
                if im17(i, j) == 0
                    count4 = count4+1;
                end
            end
            if count4 <= 6
                n2 = j-1;
                break
            end
        end
        if n2 == 0
            n2 = n;
        end

        % 完成切割工作
        rect13 = [n1, 0, n2-n1, m];
        im18 = imresize(imcrop(im17, rect13), [40, 20]);
        fipic(:, :, k) = im18;
    end
    
    %创建路径保存并展示
    name = 'VLPR';
    datasavename = [name datestr(now, 5) datestr(now, 7)];
    mkdir(datasavename);
    save(['.\' datasavename '\',num2str(k),'.jpg'],'im18')
    figure(4)
    subplot(1, 7, k); imshow(im18);
end


%% 对分割后的图象进行识别

for k = 1: 7
    
    % 根据字符位置确定搜索范围
    if k == 1
        kmin = 35;
        kmax = 65;
    elseif k == 2
        kmin = 11;
        kmax = 34;
    else
        kmin = 1;
        kmax = 34;
    end
    
    % 模板比对
    for k2 = kmin: kmax
        frame = strcat('.\model\', num2str(k2), '.jpg');
        model1 = imread(frame);
        model2 = imresize(im2bw(model1), [40, 20]);
        cont = zeros(40, 20);
        for i = 1: 40
            for j = 1: 20
                cont(i, j) = model2(i, j) - fipic(i, j, k);
            end
        end
        
        count = 0;
        for i = 1: 40
            for j = 1:20
                if cont(i, j) == 0
                    count = count+1;
                end
            end
        end
        
        rig(k2, 1) = count;
    end
    
    % 模板寻找
    [loc, num] = max(rig);
    resu(k) = num;
    rig = 0;
end


%% 输出车牌
[~, ~, data1] = xlsread('codebook.xlsx');
data2 = xlsread('codebooknum.xlsx');
for i = 1: 7
    a = resu(i);
    if a <= 10
        answer(i) = num2str(data2(a));
    else
        answer(i) = data1{a, 1};
    end
end

figure(5)
imshow(imresize(image,0.5));
outp = strcat('图中车牌为：', answer);
xlabel(outp);
    
    

            
    

