function T_r = estimateTransmission(I,bg)
    % Estimate transmission map for red colour channel using 
    % RED CHANNEL PRIOR
    % Refine estimation with (i) laplacian matting, if image size (imgSize) < 1800 pixels or (ii) guided filter, otherwise 
    [m, n, ~] = size(I);
    win_size =  floor(min(m,n)*0.01)*2 + 1;
    ratio = zeros(3,1);
    lambda = [620,540,450];
    for i = 1:3
        ratio(i) = (-0.00113*lambda(1)+1.62517)/(-0.00113*lambda(i)+1.62517);
    end
    J0 = ordfilt2(I(:,:,1)./bg(:,:,1),1,ones(win_size, win_size),'symmetric');
    J1 = ordfilt2((1-I(:,:,1))./(1-bg(:,:,1)),1,ones(win_size, win_size),'symmetric');
    J2 = ordfilt2(I(:,:,2)./bg(:,:,2),1,ones(win_size, win_size),'symmetric');
    J3 = ordfilt2(max(0, I(:,:,3)./bg(:,:,3))  .^ ratio(3),1,ones(win_size, win_size),'symmetric');
    J23 = min(J2, J3); J_RED = min(J23, J1);
    J_RED = min(J_RED, 1); J_RED = max(J_RED, 0);

    J1_range = ordfilt2((1-I(:,:,1)),1,ones(win_size, win_size),'symmetric');
    J2_range = ordfilt2(I(:,:,2),1,ones(win_size, win_size),'symmetric');
    J3_range = ordfilt2(I(:,:,3),1,ones(win_size, win_size),'symmetric');
    J_RED_range = min(J1_range,J2_range); J_RED_range = min(J3_range,J_RED_range);
    J_RED_range = 1 - imguidedfilter(J_RED_range,I,'NeighborhoodSize',[win_size,win_size]);
    J_max = max(J_RED_range(:)); J_min = min(J_RED_range(:)); 
    
    J_max = min(J_max,0.9);
    P_init = 1-J_RED;   
    if max(m,n) < 1800
        L = get_laplacian(I);
        A = L + 0.0001 * speye(size(L));
        b = 0.0001 * P_init(:);
        x = A \ b;
        d = reshape(x,[m,n]);
    else
        d = imguidedfilter(P_init_0,I,'NeighborhoodSize',[15 ,15]);
    end
    d = max(d, 0.1);
    T_r = d .* (J_max - J_min) + (J_min);  
end
