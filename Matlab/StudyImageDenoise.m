% NLM: https://www.mathworks.com/help/images/ref/imnlmfilt.html
% BL:  https://www.mathworks.com/help/images/ref/imbilatfilt.html

%%
imRGB = imread('peppers.png');
noisyRGB = imnoise(imRGB,'gaussian',0,0.01);
noisyLAB = rgb2lab(noisyRGB); % double

%% estimate noise
roi = [210,24,52,41];
patch = imcrop(noisyLAB,roi);
patchSq = patch.^2;
edist = sqrt(sum(patchSq,3));
patchSigma = sqrt(var(edist(:)));

%% NLM
denoisedLAB = imnlmfilt(noisyLAB,'DegreeOfSmoothing',1.5*patchSigma); % double outpyt
denoisedRGB = lab2rgb(denoisedLAB,'Out','uint8');

%% BL
spatialSigma = 50;
denoisedLAB_bl = imbilatfilt(noisyLAB, 2 * patchSigma, spatialSigma);
denoisedRGB_bl = lab2rgb(denoisedLAB_bl,'Out','uint8');

%%
montage({noisyRGB, denoisedRGB, denoisedRGB_bl, imRGB});