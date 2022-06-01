%%%%%%%%%%%%%%%%%%
% Evaluation code for CIEDE2000 colour accuracy on annotated Sea-thru dataset
% Author: Chau Yi Li (janicelicy@gmail.com), May 2022
%%%%%%%%%%%%%%%%%%

addpath('~/Downloads/LabelMeToolbox-master/XMLtools'); % path to LabelMe Toolbox
path = '~/Downloads/collection/Images/users/janli113/seathru/';
seathru_set  = 'D3';
listing = dir(path);
result_path = '~/Downloads/D3/Raw';
file_name_list = {listing.name}; 
start_point = 3 + ismember('.DS_Store',file_name_list);
FC = zeros(1,3);
total_NP  = 0;
CIEDE2000 = {}; 

%% Get reference colour of each patch from reference colour chart
[v, xml] = loadXML('~/Downloads/ref_dkg_reference/dkg_reference.xml');  
name = {v.annotation.object.name};
reference = zeros(18,3); 
I_ref = im2double(imread('~/Downloads/DKG_reference.png'));
[m,n,~] = size(I_ref); 
watermask = zeros(m,n);
for neutral_count = [7:24]
    NB_location = find(strcmp(name, sprintf('%d', neutral_count)));  
    if (numel(NB_location) > 0)% contains labelled water
        for i = 1:numel(NB_location) % enable only water (including occluded part)
            X = str2num(char({v.annotation.object(NB_location(i)).polygon.pt.x}));
            Y = str2num(char({v.annotation.object(NB_location(i)).polygon.pt.y}));
            P = poly2mask(X, Y, m,n); 
            watermask = watermask | P;
            for c = 1:3
                current = I_ref(:,:,c);
                reference(neutral_count-6,c) = mean(current(P));
            end
        end
    end
end

total_count  = 1;
for neutral_count =  7%:24        
    for file_count = [48:numel(file_name_list)] %[start_point+1:46]%, 
        file_name = file_name_list{file_count};
        file_name = file_name(1:length(file_name)-4);
        [v, xml] = loadXML(sprintf('~/Downloads/collection/Annotations/users/janli113/seathru/%s.xml', file_name));
        if (isfield(v.annotation, 'object'))
            name = {v.annotation.object.name};      
            NB_location = find(strcmp(name, sprintf('%d', neutral_count)));
            if (numel(NB_location) > 0)
                for i = 1:numel(NB_location) % enable only water (including occluded part)
                    X = str2num(char({v.annotation.object(NB_location(i)).polygon.pt.x}));
                    Y = str2num(char({v.annotation.object(NB_location(i)).polygon.pt.y}));
                    %I = im2double(imread(sprintf('%s/%s.png',result_path,file_name)));
                    %[m,n,~] = size(I);  
                    n = 1992; m = 1330;
                    %m = 1840; n=      1228;

                    if max(max(X), max(Y)) > max(m,n)
                        P = poly2mask(X/4, Y/4, m,n);
                    else
                        P = poly2mask(X, Y, m,n);
                        fprintf('%s\n', file_name);
                        
                    end
                    for c = []%1:3
                        current_I = I(:,:,c);
                        Q = current_I(P);
                        FC(c) = mean(Q);
                    end
                    %CIE2000(total_count, :) = [file_count, neutral_count,  imcolordiff(reference(neutral_count-6,:), FC, "Standard", "CIEDE2000"), FC(1),FC(2),FC(3)]; 
                    total_count  = total_count+1;   
                end
            end
        end 
    end    
end 

%% Print results
for neutral_count = []%  7:24        
    fprintf('%d %.2f\n', neutral_count, mean(CIE2000(CIE2000(:,2) == neutral_count, 3)));
end