% Perform analyses on spectrum

% author: Daniel Robin
% email: daniel.robin.1@ulaval.ca

function results = awg_analyse(lambda, T)

    TdB = 10*log10(T);

    num_channels = size(T, 2);
    center_channel = floor(num_channels / 2) + 1;
    
    % insertion loss
    IL = abs(max(TdB(:,center_channel)));
    
    % non-uniformity
    NU = abs(max(TdB(:,1))) - IL;
    
    % 10dB bandwidth
    t0 = TdB(:,center_channel);
    ic = find(t0 == max(t0), 1);
    ia = find(t0(1:ic) < -10,1,'last');
    ib = ic + find(t0(ic:end) < -10,1,'first');
    BW10 = (lambda(ib) - lambda(ia)) * 1e3;
    
    % 3dB bandwidth
    ia = find(t0(1:ic) < -3,1,'last');
    ib = ic + find(t0(ic:end) < -3,1,'first');
    BW3 = (lambda(ib) - lambda(ia)) * 1e3;
    
    % Crosstalk level
    XT = -100;
    for i = 1:num_channels
        if i ~= center_channel
            xt = max(TdB(ia:ib,i));
            XT = max(XT, xt);
        end
    end
    
    % Channel spacing
    sp1 = abs(lambda(ia) - lambda(ic));
    sp2 = abs(lambda(ib) - lambda(ic));
    CS = max(sp1, sp2) * 1e3;
    
    % create table
    results = table([IL; NU; CS; BW3; BW10; XT], 'RowNames', ...
        {
            'Insertion loss [dB]'
            'Loss non-uniformity [dB]'
            'Channel spacing [nm]'
            '3dB bandwidth [nm]'
            '10dB bandwidth [nm]'
            'Crosstalk level [dB]'
        }, 'VariableNames', {'Value'});
    