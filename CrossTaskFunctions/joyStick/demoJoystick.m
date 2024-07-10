%Script lets you demo the joy stick out and it's main parameters
%press spacebar to exit
%written by Seth Konig 5/14/2020

figure

%input parameters
joystickThreshold = 0.05;%minimum movement to prevent unwanted drift
newPos = [1920/2 1080/2];
xySensitivity = 25;
xyLimits = [0 1920;0 1080];
debugFlag = true; %if true outputs position of joystick in real-time

%keyboard parameters
KB = hdLabSetupKeyoard();
waitForKeyPress = true;

%run joystick input visualization
while waitForKeyPress
    
    %call joystick posistion
    newPos = updateJoystick(newPos,xySensitivity,xyLimits,joystickThreshold,debugFlag);
    
    %plot new joystick
    plot(newPos(1),newPos(2),'b+');
    axis ij
    axis([xyLimits(1,1) xyLimits(1,2) xyLimits(2,1) xyLimits(2,2)]);
    drawnow
    
    %check for quitting
    [keyIsDown, inputTime, keyCode] = KbCheck();
    if keyIsDown
        if keyCode(KB.space)
            waitForKeyPress = false;
            close all  
        end
    end
    
    WaitSecs(1/60);
end