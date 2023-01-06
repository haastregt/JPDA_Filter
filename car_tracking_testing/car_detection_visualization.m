clear, clc
% Load video
video = VideoReader('/Data/car2.mp4');

foregroundDetector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 100);
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', true, ...
    'MinimumBlobArea', 250);

figure(1),
% subplot(3,1,1)
% title('Foreground')
% subplot(3,1,2)
% title("Filtered Foreground")
% subplot(3,1,3)
% title("Results")
for i = 0:video.NumFrames
    % Read the next video frame
    frame = readFrame(video); 
    % Retrieve Foreground
    foreground = step(foregroundDetector, frame);
    % Remove Clutter
    se = strel('disk', 3);
    filteredForeground = imopen(foreground, se);
    % Find Morphological objects
    [centroid, bbox] = step(blobAnalysis, filteredForeground);
    
    % Results
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    
    imshow(result)
%     subplot(3,1,1), imshow(foreground)
%     subplot(3,1,2), imshow(filteredForeground)
%     subplot(3,1,3), imshow(result)
    
end