function The_Box = car_detector(frame, Object)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This code is a variation of the code written by:                          %
    %       Hakkı Egemen Gülpınar  /  Seher Bengisu Akbulut                     %
    %       Mersin University Department of Computer Engineering                %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Morphological Operation to Remove Noise
    Structure = strel('square', 3);
    Noise_Free_Object = imopen(Object, Structure);


    %Locate the Object
    Bounding_Box = vision.BlobAnalysis('CentroidOutputPort', false, 'AreaOutputPort', false, ...
        'BoundingBoxOutputPort', true, ...
        'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 1400);
    %Inserting the Box 
    The_Box = step(Bounding_Box, Noise_Free_Object);
    % Drawing the Rectangle
    Detected_Vehicle = insertShape(frame, 'Rectangle', The_Box, 'Color', 'yellow');
    % Counting Vehicles
    Number_of_Vehicle = size(The_Box, 1);

    %Inserting Text Operations 
    Detected_Vehicle = insertText(Detected_Vehicle, [10 10], Number_of_Vehicle, 'BoxOpacity', 1,'FontSize', 14);


    % Main functionality
    Noise_Free_Object = imopen(Object, Structure);
    The_Box = step(Bounding_Box, Noise_Free_Object);    % The_Box = [x_top_left y_top_left width height]

end