function channel = get_red_channel(image, win_size, method)
%% method = 0: min; method = 1: max; method = 2: std; 
switch method 
    case 0
        channel = ordfilt2(image,1,ones(win_size, win_size),'symmetric');
    case 1
        channel = ordfilt2(image,win_size^2,ones(win_size, win_size),'symmetric'); 
    case 2
        channel = stdfilt(image,ones(win_size, win_size));
    otherwise
end
end