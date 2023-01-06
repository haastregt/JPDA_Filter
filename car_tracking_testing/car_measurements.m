function [z, delta_t, bboxes] = car_measurements(video, frame_range)
  
    foregroundDetector = vision.ForegroundDetector('NumGaussians', 2, ...
        'NumTrainingFrames', 100);
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', false, 'CentroidOutputPort', true, ...
        'MinimumBlobArea', 1000);
    
    % Pre-allocate
       
    if nargin < 2
        frame_range = [1, video.NumFrames];
        z = cell(video.NumFrames,1);
        bboxes = cell(video.NumFrames,1);
    else
        video.CurrentTime = frame_range(1)/video.FrameRate;
        z = cell(frame_range(2)-frame_range(1),1);
        bboxes = cell(frame_range(2)-frame_range(1),1);
    end
    
    for i = (frame_range(1)+1):frame_range(2)
        % Read the next video frame
        frame = readFrame(video);
        % Retrieve Foreground
        foreground = step(foregroundDetector, frame);
        % Remove Clutter
        se = strel('disk', 3);
        filteredForeground = imopen(foreground, se);
        % Find Morphological objects
        [centroid, bboxes{i}] = step(blobAnalysis, filteredForeground);    
        z{i} = centroid';
    end

    delta_t = 1/video.FrameRate;
end