%%
clear all; clc;

%% Run car detection algorithm

% Load video
Video = VideoReader('videoplayback_short.mp4');
%Video = VideoReader('car2.mp4');

Object_Detector = vision.ForegroundDetector(...
       'NumTrainingFrames', 50, ... 
       'InitialVariance', 30*30);

% Read the first 25 frames to get the background
for i = 1:25
    frame = readFrame(Video);
    Object = step(Object_Detector, frame);
end

% Create a video player object for displaying video frames.
videoPlayer = vision.VideoPlayer('Name', 'Detected Vehicles');
videoPlayer.Position(3:4) = [650,400];

% Main loop to detect cars in each video frame
while hasFrame(Video)
    frame = readFrame(Video); 
    Object = step(Object_Detector, frame);    
    box = car_detector(frame, Object);

    % A measurement is considered to be the center of a bounding box
    % NOTE: I am not sure how multiple boxes are handled internally in the function, we need to check this

    centers = zeros(size(box, 1), 2);
    % Compute the center for each bounding box
    for i = 1:size(box, 1)
        centers(i, 1) = box(i, 1) + box(i, 3)/2;    % center_x = x + width/2
        centers(i, 2) = box(i, 2) + box(i, 4)/2;    % center_y = y + height/2
    end





    % TODO: IMPLEMENT HERE THE FUNCTIONALITY FOR THE FILTERS





    box = double(box);
    dim = 10;

    % Add all the box positions and the centers to the frame
    position = [
        box(:, 1:2), box(:, 3:4);
        centers - [ones(size(box, 1), 1)*dim/2, ones(size(box, 1), 1)*dim/2] , ones(size(box, 1), 1)*dim, ones(size(box, 1), 1)*dim
    ];
    position = int32(position);
    shape_inserter = vision.ShapeInserter('BorderColor','Black');
    shapes = shape_inserter(frame, position);
    Number_of_Vehicle = size(box, 1);
    all_shapes = insertText(shapes, [10, 10], Number_of_Vehicle, 'BoxOpacity', 1, 'FontSize', 14, BoxColor = 'red');


    step(videoPlayer, all_shapes);


    pause(0.06)

end