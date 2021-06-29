% revisions:
%   30/10/2020 - Mathieu Walsh - fixed channel spacing calculation
%   29/11/2020 - Mathieu Walsh - fixed non-adjacent crosstalk calculation

function results = analyse(results)
% Perform analysis on output spectrum

    wavelength = results.wavelength;
    transmission = results.transmission;

    TdB = 10*log10(transmission);

    num_channels = size(transmission, 2);
    center_channel = floor(num_channels / 2) + 1;

    % insertion loss
    IL = abs(max(TdB(:,center_channel)));

    % 10dB bandwidth
    t0 = TdB(:,center_channel) + IL;
    ic = find(t0 == max(t0), 1);
    ia = find(t0(1:ic) < -10,1,'last');
    ib = ic + find(t0(ic:end) < -10,1,'first');
    BW = (wavelength(ib) - wavelength(ia)) * 1e3;

    % 3dB bandwidth
    ia = find(t0(1:ic) < -3,1,'last');
    ib = ic + find(t0(ic:end) < -3,1,'first');
    BW3 = (wavelength(ib) - wavelength(ia)) * 1e3;
    
    NU = 0;
    CS = 0;
    XT = 0;
    XTn = 0;
    
    if num_channels > 1
        % non-uniformity
        NU = abs(max(TdB(:,1))) - IL;

        % Adjacent Crosstalk
        if num_channels < 3
            if center_channel - 1 > 0
                XT = max(TdB(ia:ib,center_channel - 1));
            else
                XT = max(TdB(ia:ib,center_channel + 1));
            end
        else
            xt1 = max(TdB(ia:ib,center_channel - 1));
            xt2 = max(TdB(ia:ib,center_channel + 1));
            XT = max(xt1, xt2);
        end

        XT = XT - IL;

        % Non-Adjacent Crosstalk
        XTn = -100;
        for i = 1:num_channels
            if i ~= center_channel &&  i ~= (center_channel - 1) && (i ~= center_channel + 1)
                xt = max(TdB(ia:ib,i));
                XTn = max(XTn, xt);
            end
        end

        XTn = XTn - IL;
        
        % Channel spacing
        if num_channels < 3
            if center_channel - 1 > 0
                ia = find(TdB(:, center_channel - 1) == max(TdB(:, center_channel - 1)), 1);
                CS = 1e3 * abs(wavelength(ia) - wavelength(ic));
            else
                ia = find(TdB(:, center_channel + 1) == max(TdB(:, center_channel + 1)), 1);
                CS = 1e3 * abs(wavelength(ia) - wavelength(ic));
            end
        else
            ia = find(TdB(:, center_channel - 1) == max(TdB(:, center_channel - 1)), 1);
            ib = find(TdB(:, center_channel + 1) == max(TdB(:, center_channel + 1)), 1);
            
            sp1 = abs(wavelength(ia) - wavelength(ic));
            sp2 = abs(wavelength(ib) - wavelength(ic));
            CS = max(sp1, sp2) * 1e3;
        end
    end

    % create table
    results = table([IL; NU; CS; BW3; BW; XT; XTn], 'RowNames', ...
        {
            'Insertion loss (dB)'
            'Loss non-uniformity (dB)'
            'Channel spacing (nm)'
            '-3dB bandwidth (nm)'
            '-10dB bandwidth (nm)'
            'Adjacent channel Crosstalk (dB)'
            'Non-adjacent channel crosstalk (dB)'
        }, 'VariableNames', {'Value'});
end
