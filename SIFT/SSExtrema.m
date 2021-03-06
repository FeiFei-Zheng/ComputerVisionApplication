function [kp] = SSExtrema(DoGPyr)
% DoGPyr - cell array of length noctaves containing the Difference of
% Gaussian pyramid
% kp - cell array of length noctaves containing the detected keypoints. 
% each element is itself a cell array over the ns subband scales. 
    noctaves = length(DoGPyr);
    kp = cell(noctaves,1);
    
    for oc = 1: noctaves 
        stack = DoGPyr{oc};
        [h, w, n] = size(stack);  % n = ns + 2
        suboc = cell(n-2,1);   
        for sub = 2: n-1
            pre = stack(:, :, sub-1);
            next = stack(:, :, sub+1);
            cur = stack(:, :, sub);
            
            % create channels by shifting the image 8 times
            pre_shift = channel(pre);
            cur_shift = channel(cur);
            next_shift = channel(next);
            ch = cat(3, pre, next, pre_shift, cur_shift, next_shift);
            
            [maxM, minM] = detectkp(ch, cur);
            elem.max = maxM;
            elem.min = minM; 
            suboc(sub-1) = {elem};
        end
        kp(oc) = {suboc};
    end
end

function ch = channel(im)
% construct 8 channels for each pixel.
    [h w] = size(im);
    ch = zeros(h, w, 8);
    
    ch(:,:,1) = circshift(im, [1 0]);
    ch(:,:,2) = circshift(im, [-1 0]);
    ch(:,:,3) = circshift(im, [0 1]);
    ch(:,:,4) = circshift(im, [0 -1]);
    ch(:,:,5) = circshift(im, [1 1]);
    ch(:,:,6) = circshift(im, [-1 -1]);
    ch(:,:,7) = circshift(im, [1 -1]);
    ch(:,:,8) = circshift(im, [-1 1]);
end

function [maxM, minM] = detectkp(ch, cur)
% Detect the keypoints on current image by using channels.
    ch_min = min(ch, [], 3, 'includenan');
    ch_max = max(ch, [], 3, 'includenan');
    
    maxl = cur > ch_max;  % get logical matrix for max
    minl = cur < ch_min;  % get logical matrix for min
    
    cur(isnan(cur)) = 0; 
    
    [y_max, x_max, val_max] = find(maxl .* cur);
    maxM = [x_max, y_max, val_max];
    [y_min, x_min, val_min] = find(minl .* cur);
    minM = [x_min, y_min, val_min];
end
