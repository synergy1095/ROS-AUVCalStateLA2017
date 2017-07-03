clear;
clc;

%% Useful commands
% hostname -I
% rosinit('10.85.43.217');
% rosshutdown;
% !synclient HorizEdgeScroll=0 HorizTwoFingerScroll=0
% roboticsAddons
% folderpath = '/home/diego/catkin_ws/src';
% rosgenmsg(folderpath);

%% Initialize subscriber and publishers
fcdPub = rospublisher('/front_cam_distance','auv_cal_state_la_2017/FrontCamDistance');
bcdPub = rospublisher('/bottom_cam_distance','auv_cal_state_la_2017/BottomCamDistance');
tiPub = rospublisher('/target_info','auv_cal_state_la_2017/TargetInfo');
fcdMsg = rosmessage('auv_cal_state_la_2017/FrontCamDistance');
bcdMsg = rosmessage('auv_cal_state_la_2017/BottomCamDistance');
tiMsg = rosmessage('auv_cal_state_la_2017/TargetInfo');

cviSub = rossubscriber('/cv_info');

%% Initializa variables
frontCam = false;
bottomCam = false;
testTimer = 0;

%% Rate of loop (10Hz)
rate = rosrate(10);

while 1
    %% Default data
    fcdMsg.FrontCamForwardDistance = 0;
    fcdMsg.FrontCamHorizontalDistance = 0;
    fcdMsg.FrontCamVerticalDistance = 0;
    bcdMsg.BottomCamForwardDistance = 0;
    bcdMsg.BottomCamHorizontalDistance = 0;  
    bcdMsg.BottomCamVerticalDistance = 0;
    tiMsg.State = 0;
    tiMsg.Angle = 0;
    tiMsg.Height = 0;
    tiMsg.Direction = 0;
    
    %% Receive Msg
    cviMsg = receive(cviSub) ;
    
    %% Evaluate inputs
    if cviMsg.CameraNumber == 1 && ~frontCam
        %camera = cv.VideoCapture();
        frontCam = true; 
        bottomCam = false;
    elseif cviMsg.CameraNumber == 2 && ~bottomCam
        %camera = cv.VideoCapture();
        frontCam = false;
        bottomCam = true;
    elseif cviMsg.CameraNumber == 0 && (frontCam || bottomCam)
        frontCam = false;
        bottomCam = false;
        testTimer = 0;
    end
            
    
    %% Run camera
    if frontCam
        testTimer = FrontCamera(testTimer, tiMsg, cviMsg.TaskNumber, cviMsg.GivenColor, cviMsg.GivenShape, cviMsg.GivenLength, cviMsg.GivenDistance);
    end
    
    if bottomCam
        BottomCamera(cviMsg.TaskNumber, cviMsg.GivenColor, cviMsg.GivenShape, cviMsg.GivenLength, cviMsg.GivenDistance);
    end
    
    %% Send Msg
    send(fcdPub, fcdMsg);
    send(bcdPub, bcdMsg);
    send(tiPub, tiMsg);
    
    %% Loop rate (10Hz)
    waitfor(rate);
end

%% Front Camera
function timer = FrontCamera(testTimer, tiMsg, taskNum, givenC, givenS, givenL, givenD)
    %fprintf('taskNum: %d ,givenC: %d ,givenS: %d ,givenL: %.2f ,givenD: %.2f', taskNum, givenC, givenS, givenL, givenD); 
    timer = testTimer + 0.1;
    if timer >= 10 
        tiMsg.State = 1;
        tiMsg.Angle = 90;
        tiMsg.Height = -4;
        tiMsg.Direction = 1; 
        disp('Object found. Sending data to master...');
    %elseif timer >= 20
        %tiMsg.State = 1;
        %tiMsg.Angle = 0;
        %tiMsg.Height = 0;
        %tiMsg.Direction = 0;
    else
        disp('Finding object...');
        disp(timer);
    end
    
    return
end

%% Bottom Camera
function BottomCamera(taskNum, givenC, givenS, givenL, givenD)
    frintf('taskNum: %d ,givenC: %d ,givenS: %d ,givenL: %.2f ,givenD: %.2f', taskNum, givenC, givenS, givenL, givenD);  
end