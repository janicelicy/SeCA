function [out, Q] = adapt_to_map(I,A,D, idx, ws_xyz)
[m,n,c] = size(I);

if ~exist('idx', 'var')
    idx = 1;
end


if ~exist('ws_xyz', 'var')
    ws_xyz = [0.95047; 1; 1.08883]; % 'whitepoint': D65
end
%% convert to xyz
% default- 'ColorSpace': 'srgb', 'whitepoint': D65

I_xyz = rgb2xyz(reshape(I,[],c));
A_xyz_all = rgb2xyz(reshape(A,[],c));


%% create matrix
bradford = [0.8951000,  0.2664000, -0.1614000;-0.7502000,  1.7135000,  0.0367000; 0.0389000, -0.0685000,  1.0296000];
von_kries = [ 0.4002400,  0.7076000, -0.0808100;-0.2263000,  1.1653200,  0.0457000; 0.0000000,  0.0000000,  0.9182200];
M_A = bradford;
Q = I_xyz;
rho_d = M_A * reshape(ws_xyz, 3,1);
inv_MA  = inv(M_A);
for i = 1:m*n
    A_xyz = A_xyz_all(i,:);
    % preserve Y
    %A_xyz = A_xyz ./ (A_xyz(2));
    rho_s = M_A * reshape(A_xyz, 3,1);  % transform from xyz to LMS
    %M = inv(M_A) * diag(rho_d ./ rho_s) * M_A;
    Q(i,:) = (inv_MA * diag((rho_d ./ rho_s).^D(i)) * M_A * (I_xyz(i,:)'))';
end

Q = reshape(Q, m,n,3);
out = xyz2rgb(Q);


