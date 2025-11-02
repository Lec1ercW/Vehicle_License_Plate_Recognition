% model Í¼Ïñ´¦Àí³ÌÐò

clc;
clear all;
close all;

pic = imread('D.jpg');
im1 = im2bw(pic)
imshow(im1);
[m, n] = size(im1);
im2 = ones(m, n);
for i = 1: m
    for j = 1: n
        if im1(i, j) == 0
            im2(i, j) = 1;
        else
            im2(i, j) = 0;
        end
    end
end
imshow(im2);


