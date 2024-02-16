function single_sided_power_spectrum = FFT(X)
     
    FT = abs(fft(X));
    N = length(FT);
    double_sided_power_spectrum = ((FT).^2)./N;
    
    for i = 1:N
        if i<=N/2 || i>=2
             single_sided_power_spectrum(i) = 2.*double_sided_power_spectrum(i);
        elseif i == 1
             single_sided_power_spectrum(i) = double_sided_power_spectrum(i);
        elseif i>=N/2+1
              single_sided_power_spectrum(i) = 0;
        end 
    end
    
end