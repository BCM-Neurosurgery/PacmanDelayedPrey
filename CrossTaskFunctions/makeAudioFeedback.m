function [sf,rwdSound,norwdSound] = makeAudioFeedback(sf)
%Function generates a series of pure tones used for feedback.
%turned into own function, Seth Konig 2/19/2020
%
% Inputs:
%   1) sf: sound frequency
%
% Ouputs:
%   1) sf: sampling frequency of tone
%   2) rwdSound: pure tone sinusoid used for positive feedback/reward
%   3) norwdSound: pure tone sinusoid used for negative feedback/unrewarded

if nargin < 1
        sf = 22050; % sample frequency (Hz)  
end


%set sound parameters
d = 0.1;                     % duration - each tone (s)
n = sf * d;                 % number of samples
stmp = (1:n) / sf;             % sound data preparation


for sounds = 1:2
    switch sounds
        case 1
            cf = [440 523.25 698.46];   % rising 3 notes
        case 2
            cf = [440 220 220]; % falling 2 notes;
    end

    s = [];
    for i = 1:length(cf)
        s = [s sin(2 * pi * cf(i) * stmp)];   % sinusoidal modulation
    end
    
    %   sound(s, sf);               % sound presentation
    switch sounds
        case 1
            rwdSound = s;   % rising 3 notes
        case 2
            norwdSound = s;   % falling 2 notes
    end
end

end