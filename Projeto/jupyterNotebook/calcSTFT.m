function [outPontosMedioTempo, outSTFT] = calcSTFT(data, fs, valoresFuncaoTipoJanela, countAmostrasSobreposicaoJanelas, countAmostrasLarguraJanela)
    countAmostrasData = length(data);
                
    % dominioFrequencia  ==  ( -N/2 : -N/2 ) * f0  ==  ( -N/2 : -N/2 ) * fs / N  ==  ( -fs/2 : -fs/2 )   (N, Periodo)
    if mod(countAmostrasLarguraJanela, 2) == 0
        dominioFrequencia = -fs/2 : fs/countAmostrasLarguraJanela : fs/2 - fs/countAmostrasLarguraJanela;
    else
        dominioFrequencia = -fs/2 + fs/(2*countAmostrasLarguraJanela) : fs/countAmostrasLarguraJanela : fs/2 - fs/(2*countAmostrasLarguraJanela);
    end
                
    % lista de janelas
    listaJanelas =  1 : countAmostrasLarguraJanela - countAmostrasSobreposicaoJanelas : countAmostrasData - countAmostrasLarguraJanela;
    countJanelas = length(listaJanelas);

    % linspace: Generate linearly spaced vector
    vetorTempo = linspace(0, (countAmostrasData - 1)/fs, countAmostrasData);

    if countAmostrasData / fs > 30
        vetorTempo = vetorTempo./60;
    end

    outSTFT = zeros(countJanelas, 1);
    outPontosMedioTempo = zeros(countJanelas, 1);
                    
    iterJanela = 1;
    % por cada janela
    for iterListaJanelas = listaJanelas
        % janela = excerto da data * valoresFuncaoTipoJanela
        janela = data(iterListaJanelas : iterListaJanelas + countAmostrasLarguraJanela - 1).*valoresFuncaoTipoJanela;

        % Referencia: https://www.mathworks.com/help/signal/ug/discrete-fourier-transform.html
        % fft: Fast Fourier transform
        % fftshift: Shift zero-frequency component to center of spectrum
        janelaCoefsDFT = abs(fftshift(fft(janela)));
        
        % encontrar a frequencia mais relevante
        frequenciaRelevante = dominioFrequencia(janelaCoefsDFT == max(janelaCoefsDFT));

        % guardar valor da frequencia, ignorar valor negativo
        outSTFT(iterJanela) =  frequenciaRelevante(frequenciaRelevante >= 0);

        % valores de tempo desta janela
        vetorTempoJanela = vetorTempo(iterListaJanelas : iterListaJanelas + countAmostrasLarguraJanela - 1);

        % guardar ponto medio valor temporal desta janela
        outPontosMedioTempo(iterJanela) = vetorTempoJanela(round(countAmostrasLarguraJanela/2) + 1);

        iterJanela = iterJanela + 1;
    end

    % plot(x, y)
    plot(outPontosMedioTempo, outSTFT, "bo");
    title("STFT");
    if countAmostrasData / fs > 30
        xlabel("Tempo [min]");
    else
        xlabel("Tempo [seg]");
    end
    ylabel("Frequência [Hz]");
    grid on;
end