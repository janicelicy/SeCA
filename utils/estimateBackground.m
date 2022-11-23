function [bglight,bg,MaxLocation,Regressed_ans,final_candidate, bg2, final_with_no_border,Ratio_candidate,channel, bglight_CC ] = estimate_A_ICCV(I,file_name,d)
    %%%%%%%%%%%%%%%%%
    % Estimate A* and A(x,y) 
    %%%%%%%%%%%%%%%%
    %% read image and initialise variables
    [m,n,c] = size(I);% 
    bg = zeros(m,n,c); bglight = [-1,-1,-1]; 
    MaxLocation = -1; Regressed_ans = zeros(3,2); 
  
    %% Checking for ratio and low variance here
    lambda = [620,540,450];     
    block_size = max(15,floor(min(m/100,n/100)));
    block_size = min(31,floor(block_size/2)*2 + 1);
    boarder_size = 5;
    ratio = zeros(3,1);
    for i = 1:3
        ratio(i) = (-0.00113*lambda(1)+1.62517)/(-0.00113*lambda(i)+1.62517);
    end
    channel = get_red_channel(mean(I,3), block_size, 2) < 0.01;
    %% Obtain ratio candidate and variance candidate
    Ratio_candidate =  ((log(I(:,:,2)) ./ log(I(:,:,1)) < 0.8)) .*  ((log(I(:,:,3)) ./ log(I(:,:,1)) < 0.7))  .*  (I(:,:,1) < 1) .*  (I(:,:,2) < 1) .*  (I(:,:,3) < 1);
    Ratio_candidate = ordfilt2(Ratio_candidate, 1, ones(block_size, block_size),'symmetric');
    Ratio_Var_candidate =  Ratio_candidate .* (channel); % reason on the selected threshold 0.01
    
    %% Anything smaller than 255 is not candidate
    CC = bwconncomp(Ratio_Var_candidate); 
    numPixels = cellfun(@numel,CC.PixelIdxList);
    idx = numPixels < block_size^2; %why 225? variance in a 15x15 window 
    for it = find(idx)
        Ratio_Var_candidate(CC.PixelIdxList{it}) = 0;
    end
    %% image closing with a square of size block_size^2
    SE = strel('square', block_size);
    final_candidate = 1-imclose(1-Ratio_Var_candidate,SE);
    %% remove small regions again
    CC = bwconncomp(final_candidate);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    idx = numPixels < block_size^2; %why 225? variance in a 15x15 window 
    for it = find(idx)
        final_candidate(CC.PixelIdxList{it}) = 0;
    end
    final_with_no_border = Ratio_Var_candidate;
    final_candidate(1:boarder_size,:) = 0; final_candidate(m-boarder_size+1:m,:) = 0; 
    final_candidate(:,1:boarder_size) = 0; final_candidate(:,n-boarder_size+1:n) = 0;
    K = Ratio_Var_candidate .* I; 
  
    %% Get binary's connected component
    CC = bwconncomp(final_candidate); % Add condition, only calculatiing if CC.NumObjects > 0
    CC_label = bwlabel(final_candidate);
    if (CC.NumObjects > 0)
        %% 
        Dif = max(K(:,:,2), K(:,:,3)) - K(:,:,1);
        location = find((Dif >= quantile(Dif(find(Ratio_Var_candidate == 1)), 0.99)));
        V = reshape(I,[],3);
        V(location, 1) = 1; V(location, 2:3) = 0; V = reshape(V,m,n,3);
        %%
        CC_number = max(unique(CC_label));
        bglight_CC = [];
        Pixel_List = [];
        pixel_sum = [];
        for i = 1:CC_number
            J = CC_label == i;
            if (sum(J(location)) ~= 0)
               bglight_CC =  [bglight_CC, i];
               pixel_sum = [pixel_sum, sum(J(location))];
            end
        end
        % the list of CC with more probable pixels 
        if numel(bglight_CC) == 1
            list_CC = bglight_CC;
        else
            list_CC = bglight_CC(pixel_sum > quantile(pixel_sum, 0.5));
        end
        for i = list_CC
            J = CC_label == i;
            Pixel_List = [Pixel_List; find(J == 1)];
        end
    
       
       Pixel_List = [];
        for i = 1 :CC_number
            J = CC_label == i;
            Pixel_List  = [Pixel_List; find(J == 1)];
        end
        colour_list = {'r','g','b'};
        X = zeros(m,n);
        X(Pixel_List) = 1;
        final_candidate = X;
        %figure; imshow(X);
        [row, col] = ind2sub([m,n],find(X == 1)); ops = find(col > 600);
        link2 = log(K); link2(isinf(link2)) = 0;
        y1 = reshape(link2, [], 3);
        for c = 1:3
             mdl = fitlm( row , (y1(find(X == 1),c)) ,'RobustOpts','on');
             Regressed_ans(c,:) = mdl.Coefficients.Estimate;
        end
       
        all_neg = 1; 
        for i = 1:3
            all_neg = (Regressed_ans(i,2)<0) && all_neg;
        end
       
        % (:,2) is the slope
        if ~((Regressed_ans(1,2)<Regressed_ans(2,2)) & (Regressed_ans(1,2) < Regressed_ans(3,2)) & all_neg)
            Regressed_ans(:,2) = 0;
        end
        MaxBRDiff = max(Dif(:));
        location = find(Dif == MaxBRDiff); MaxLocation = location(1);
        [max_row, max_col] = ind2sub([m,n],MaxLocation);        
        location = find((Dif > quantile(Dif(:), 0.99)));
        [mean_row, mean_col] = ind2sub([m,n],location);
        mean_row = mean(mean_row);
        %fprintf('%s : %d\n', file_name,numel(location));
        for c = 1:3
            I_v = reshape(I(:,:,c), [], 1); 
            %I_v(location) = 1;
            bglight(c) = median(I_v(location));
        end
        mean_bglight =  bglight;
       
        if (exist('d', 'var')) % Interpolate A
             % bglight = K(max_row,max_col,:);
             bg = zeros(m,n,3); X = [1:m]' .* ones(m,n); 
            % Similar triangle
%             max_row = 1;
             d_bglight = d(max_row,max_col);
            if (sum(sum(d == ones(m,n))) == m*n)
                %% d is all 1's
                for i = 1:3
                    bg(:,:,i) = bglight(i)*exp(Regressed_ans(i,2).* (X-max_row));
                end
            else
                mean_d = mean(d(location));
               % fprintf('d bglight %.4f; average %.4f', log(d_bglight), log(mean_d));
               % figure; imshow(log(d)./log(d_bglight));
                mean_bg =  bg;
                for i = 1:3
                    bg(:,:,i) = bglight(i)*exp(Regressed_ans(i,2).* (X-max_row).*(log(d)./log(d_bglight)));
                    mean_bg(:,:,i) = mean_bglight(i) *exp(Regressed_ans(i,2).* (X-mean_row).*(log(d)./log(mean_d)));
                end
                bg  = mean_bg;
                
            end
        else
             for i = 1:3
                bg(:,:,i) = bglight(i)*exp(Regressed_ans(i,2).*(X-max_row) );
             end            
        end
        X = zeros(m,n);
        X(Pixel_List) = 1;
        final_candidate = final_candidate .* V;
        MaxLocation  = mean_row;
end
