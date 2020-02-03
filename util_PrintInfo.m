function util_PrintInfo(AWG)

    s = MeasureAWG(AWG);
    
    p = tablePrinter;
    p.addRow('Design center frequency&%.1fTHz', AWG.nu0)
    p.addRow('Design center wavelength&%.3fµm', AWG.lambda0)
    p.addRow('Number of arrayed waveguides&%i', AWG.N)
    p.addRow('Grating order&%i', AWG.m)
    p.addRow('Focal length&%.1fµm', AWG.Lf)
    p.addRow('Length difference deltaL&%.1fµm', s.deltaL)
    p.print()
    
    
%     fprintf('Input waveguide width&%.1f µm', AWG.Wi)
%     fprintf('Array waveguide width&%.1f µm', AWG.Wa)
%     fprintf('Output waveguide width&%.1f µm', AWG.Wo)
%     fprintf('Number of output channels&%i', AWG.No)
    
    fprintf("\n")
    
    p.clear()
    p.setTitle('Predicted performance')
    p.addRow('Free spectral range&%s&(%s)',     fmt_freq(s.FreeSpectralRange),fmt_length(3e-4/s.FreeSpectralRange))
    p.addRow('Full device bandwidth&%s&(%s)',   fmt_freq(s.DeviceBandwidth),fmt_length(3e-4/s.DeviceBandwidth))
    p.addRow('Channel -3dB bandwidth&%s&(%s)',  fmt_freq(s.ChannelBW3),fmt_length(3e-4/s.ChannelBW3))
    p.addRow('Channel -10dB bandwidth&%s&(%s)', fmt_freq(s.ChannelBW10),fmt_length(3e-4/s.ChannelBW10))
    p.addRow('Channel -40dB bandwidth&%s&(%s)', fmt_freq(s.ChannelBW40),fmt_length(3e-4/s.ChannelBW40))
    p.addRow('Channel spacing&%s&(%s)',         fmt_freq(s.ChannelSpacing),fmt_length(3e-4/s.ChannelSpacing))
    p.addRow('Max output channels&%i',          s.MaxOutputChannels)
    p.print()
end

function str = fmt_freq(val)
    if val < 1
        val = val * 1e3;
        if val < 1
            val = val * 1e3;
            str = sprintf('%fMHz',val);
        else
            str = sprintf('%.1fGHz',val);
        end
    else
        str = sprintf('%.1fTHz',val);
    end
end

function str = fmt_length(val)
    if val < 1
        val = val * 1e3;
        if val < .5
            str = sprintf('%fnm',val);
        else
            str = sprintf('%.1fnm',val);
        end
    else
        str = sprintf('%.1fµm',val);
    end
end
