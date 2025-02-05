% DataVisualization.m
% Script per visualizzare i dati

%% Inizializzazione
close all; clc;
load('signalsStructFile.mat');

%% Selezione interattiva per visualizzazione
disp('Elenco utenti disponibili:');
disp(subjects);
while true
    selectedUser = input('Inserisci l''ID del soggetto da visualizzare (es. "P1"): ', 's');
    if ismember(selectedUser, subjects)
        break;
    else
        disp('Utente non valido! Riprova.');
    end
end

% Trova le classi di gesto disponibili per l'utente selezionato
userAcquisitions = signalsStructFile.(selectedUser);
gestureIDs = unique(arrayfun(@(x) userAcquisitions.(x{1}).GestureID, ...
    fieldnames(userAcquisitions), 'UniformOutput', false));

%% Visualizzazione interattiva
continueViewing = true;
while continueViewing
    % Mostra classi di gesto disponibili
    disp('Classi di gesto disponibili:');
    disp(gestureIDs);
    
    % Chiedi all'utente quale classe visualizzare
    while true
        selectedGesture = input('Inserisci l''ID della classe di gesto da visualizzare (es. "Class 0"): ', 's');
        if ismember(selectedGesture, gestureIDs)
            break;
        else
            disp('Classe di gesto non valida! Riprova.');
        end
    end
    
    % Visualizza i dati filtrati
    selectedAcquisitions = fieldnames(userAcquisitions);
    for acqIdx = 1:length(selectedAcquisitions)
        acqName = selectedAcquisitions{acqIdx};
        data = userAcquisitions.(acqName);
        
        % Filtra per classe di gesto
        if strcmp(data.GestureID, selectedGesture)
            % Visualizzazione del grafico
            time = (0:249) / 100; % Assume 100 Hz e 250 campioni
            figure('Name', sprintf('%s - %s - %s', selectedUser, acqName, selectedGesture));
            
            % Accelerometro
            subplot(4, 1, 1);
            plot(time, data.acc);
            title('Accelerometro');
            xlabel('Tempo [s]');
            ylabel('Accelerazione [m/s^2]');
            legend('X', 'Y', 'Z');
            
            % Giroscopio
            subplot(4, 1, 2);
            plot(time, data.gyro);
            title('Giroscopio');
            xlabel('Tempo [s]');
            ylabel('Velocità Angolare [rad/s]');
            legend('X', 'Y', 'Z');
            
            % Magnetometro
            subplot(4, 1, 3);
            plot(time, data.mag);
            title('Magnetometro');
            xlabel('Tempo [s]');
            ylabel('Campo Magnetico [\muT]');
            legend('X', 'Y', 'Z');
            
            % Orientazione
            subplot(4, 1, 4);
            plot(time, data.orientation);
            title('Orientazione');
            xlabel('Tempo [s]');
            ylabel('Gradi [°]');
            legend('X', 'Y', 'Z');
        end
    end
    
    % Chiedi se l'utente vuole continuare a visualizzare
    while true
        userChoice = input('Vuoi visualizzare un''altra classe? [y/n]: ', 's');
        if strcmpi(userChoice, 'y')
            break;
        elseif strcmpi(userChoice, 'n')
            continueViewing = false;
            break;
        else
            disp('Input non valido. Inserisci "y" per continuare o "n" per uscire.');
        end
    end
end

disp('Visualizzazione completata!');