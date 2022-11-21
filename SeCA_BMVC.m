%clc; clear all; close all;
%% Global variables

addpath('./utils')
path = './demo';

% setting up 
lambda = [620,540,450];
listing = dir(path);
file_name_list =  {listing.name};
start_point = 3 + ismember('.DS_Store',file_name_list);

%% loop through input images, video sequence 650:860 start_point:numel(file_name_list)
for file_number =  start_point:numel(file_name_list) 
  file_name = file_name_list{file_number};
  I = im2double(imread(sprintf('%s/%s',path,file_name)));
  I = rgb2lin(I);
  fprintf('%s\n',file_name);
  [m,n,c] = size(I);
  win_size =  floor(min(m,n)*0.01)*2 + 1;
  %% Estimate uniform background light
  [bglight,bg,~,~,final_candidate] = estimate_A_ICCV(I,file_name, ones(m,n));
  %% Estimate transmission map
   d = estimateTransmission(I, bg);
    %% Estimate non-uniform background light 
    [bglight,bg,MaxLocation,P] = estimate_A_ICCV(I,file_name,d);
    %% Recover image along the range
    if (bglight(1) ~= -1) 
        t = zeros(m,n,c); t(:,:,1) = d;
        for color = 2:3
            t(:,:,color) = d.^((-0.00113*lambda(color)+1.62517)*bglight(1)./(-0.00113*lambda(1)+1.62517)./bglight(color));
        end
        J_proposed = zeros(m,n,c);
        for color =1:3
            J_proposed(:,:,color) = (I(:,:,color) - bg(:,:,color))./t(:,:,color) + bg(:,:,color);
            J_proposed(:,:,color) = max(J_proposed(:,:,color),0); J_proposed(:,:,color) = min(J_proposed(:,:,color),1);
        end 
       imwrite(J_proposed, sprintf('./results/%s_DBL.png',file_name(1:length(file_name)-4)));
       
        d = estimateTransmission(J_proposed, bg);   
        eta  = (log(d)-min(log(d(:)))) ./ (max(log(d(:))) - min(log(d(:))));    

        if (bglight(1) == 0)
            J_idx = (max(d(:))-min(d(:)))./(d-min(d(:))) .* log(J_proposed(:,:,2)) ./ log(bg(:,:,2)) ;
        else
            J_idx = (max(d(:))-min(d(:)))./(d-min(d(:))) .* log(J_proposed(:,:,1)) ./ log(bg(:,:,1)) ;
        end
        zeta = quantile(J_idx(:), 0.01); zeta = min(zeta, 1);
        zeta = max(0, zeta);
        
        Q = adapt_to_map(J_proposed,bg, Normalised_d );
        L = rgb2xyz(Q);
        lum_L = (sum(sum(L(:,:,2) > 1)) ./ m/n) ;
        %% look for largest zeta
        if (lum_L < 0.005)
        zeta = 1; 
        else 
        %           %  fprintf("ahhhh....\n");
         if (zeta  > 0.05)
             Q = adapt_to_map(lin2rgb(J_proposed),lin2rgb(bg).^zeta, Normalised_d );
             L = rgb2xyz(Q);
             lum_L = (sum(sum(L(:,:,2) > 1)) ./ m/n) ;
             while (lum_L < 0.005)
                 zeta = zeta+0.05;
                 Q = adapt_to_map(lin2rgb(J_proposed),lin2rgb(bg).^zeta, eta );
                 L = rgb2xyz(Q);
                 lum_L = (sum(sum(L(:,:,2) > 1)) ./ m/n) ;
             end
         end
        end
        zeta = zeta - 0.05;
        J_SeCA = adapt_to_map(lin2rgb(J_proposed),lin2rgb(bg).^zeta, eta ); % returns srgb
        imwrite(J_SeCA, sprintf('./results/%s_SeCA.png',file_name(1:length(file_name)-4)));
    end
   % toc
end
      


