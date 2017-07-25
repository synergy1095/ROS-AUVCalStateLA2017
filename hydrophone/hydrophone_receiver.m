%rosinit();

clear;
clc;

data = [0,0];
client = tcpip('10.0.0.3',55000,'NetworkRole','Client');
set(client,'InputBufferSize', 16);
set(client,'Timeout',60);
fopen(client);
disp("Client open");

hPub = rospublisher('/hydrophone','auv_cal_state_la_2017/Hydrophone');
h = rosmessage('auv_cal_state_la_2017/Hydrophone');

while 1
    data = fread(client,2,'double');
    disp(data);
    h.Direction = data;
    h.Angle = 999;
    send(hPub, h);
%     pause(1);
end

fclose(client);