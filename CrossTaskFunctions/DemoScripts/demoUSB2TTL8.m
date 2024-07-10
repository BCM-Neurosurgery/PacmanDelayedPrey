%Script shows how to read/write TTL pulses using USB2TTL8!
%read/write code based on http://labhackers.com/usb2ttl8.html &
%ping code based on http://blog.labhackers.com/?tag=usb2ttl8
%uses Psychtoolbox timer...not sure how accurate it is, ~1 ms supposedly
%
% Should try not to run anything else
%
%define Serial Port
sconn = serial('COM4','BaudRate', 128000, 'DataBits', 8);
numTestPulses = 1e4;

% Open port for communication
fopen(sconn)


results = NaN(1,numTestPulses);
for tP = 1:numTestPulses
    tx_time = GetSecs();
    fprintf(sconn, 'PING\n'); 
    r = fscanf(sconn,'%s');
    rx_time = GetSecs();
    if r
        results(tP) = rx_time-tx_time;
    else
        fprintf('\nerror occured')
        fclose(sconn);
    end
end
fclose(sconn);
results = results*1000;%to conver to milliseconds
%% Plot Results

figure
hist(results,100)
box off
xlabel('Ping Roundtrip Time (ms)')
ylabel('Ping Count')
xlim([0 ceil(max(results))])
title('USB2TTL8 Roundtrip Ping Latency in Matlab')
%% Pring Results
fprintf('\nLabHackers, USB Serial Rx - Tx Latency Stats')
fprintf('\nAverage: {%.3f} msec', mean(results));
fprintf('\nMedian: {%.3f} msec' , median(results));
fprintf('\nMin: {%.3f} msec' , min(results));
fprintf('\nMax: {%.3f} msec', max(results));
fprintf('\nStdev: {%.3f} msec', std(results));

%%

