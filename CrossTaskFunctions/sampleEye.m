function gazeData = sampleEye(eyeTracked)
%function calls [Eye Link] eye tracker to get most recently avaibale gaze 
%position and turns this 4 element output
%Turned into generic function and remvoed extranesous stuff by Seth Konig 2/18/2020
%
% Inputs: 
%   1) eyeTracked: index of eye tracked; starts at 0 in Eyelink so +1 in Matlab
%
% Outputs:
%   1) gazeData: time, horizontal (x), vertical (y), and pupil value of
%   most current eye tracking sample. 

gazeData = NaN(4,1);

eye_track = Eyelink( 'newestfloatsample' );
gazeData(1) = eye_track.time;
gazeData(2) = eye_track.gx( eyeTracked+1 );
gazeData(3) = eye_track.gy( eyeTracked+1 );
gazeData(4) = eye_track.pa( eyeTracked+1 );

end