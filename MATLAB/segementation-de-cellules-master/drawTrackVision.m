function imOut=drawTrackVision(imIn,jTrack,color);

    shapeInserter = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom', 'CustomBorderColor', color);
    imOut = step(shapeInserter, imIn, [jTrack(1,1), jTrack(1,2), jTrack(2,1), jTrack(2,2)]);
    
end
