
function R = reconstruct_laplacian_pyramid(pyr)

r = size(pyr{1},1);
c = size(pyr{1},2);
nlev = length(pyr);

% start with low pass residual
R = pyr{nlev};
filter = pyramid_filter;
for l = nlev - 1 : -1 : 1
    % EF_upsample, and add to current level
    odd = 2*size(R) - size(pyr{l});
    R = pyr{l} + EF_upsample(R,odd,filter);
%     if (l<=3)
%         figure, subplot(2,1,1), imshow(pyr{l}); subplot(2,1,2), imshow(R);
%         title('reconstruction');
%     end
end
