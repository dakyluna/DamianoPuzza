% DataAcquisition.m
% Script per l'acquisizione dei dati dai sensori di uno smartphone

%% Inizializzazione
close all; clear; clc;

% Configurazione del dispositivo
smartphone = mobiledev;

% Attivazione dei sensori
smartphone.AccelerationSensorEnabled = 1;
smartphone.MagneticSensorEnabled = 1;
smartphone.OrientationSensorEnabled = 1;
smartphone.AngularVelocitySensorEnabled = 1;
smartphone.SampleRate = 100; % Frequenza di campionamento (100 Hz)

% Controllo sensori attivi
availableSensorsStr = getAvailableSensors(smartphone);
disp(['Sensori disponibili: ', availableSensorsStr]);

% Parametri utente
personID = input('Inserisci l''ID del soggetto (es. "P1"): ', 's');
smartphoneModel = input('Inserisci il modello dello smartphone: ', 's');

% Scelta della mano
while true
    hand = input('Mano utilizzata (dx/sx): ', 's');
    if ismember(hand, {'dx', 'sx'}),break; else, disp('Input non valido!'); end
end

% Caricamento/Creazione struttura dati
if exist('signalsStructFile.mat', 'file')
    load('signalsStructFile.mat');
    disp('File caricato con successo!');
else
    signalsStructFile = struct();
    disp('File creato con successo!');
end

% Dizionario gesti (24 + scarto)
allGestures = [arrayfun(@(x) sprintf('Class %d', x), 0:23, 'UniformOutput', false), {'Class 24'}];

%% Acquisizione per ogni gesto (5 ripetizioni)
for gestureIdx = 1:length(allGestures)
    gestureID = allGestures{gestureIdx};
    
    for rep = 1:5
        % Creazione campo per soggetto
        if ~isfield(signalsStructFile, personID)
            signalsStructFile.(personID) = struct();
        end
        
        acquisitionInterrupted = false; % Inizializza l'interruzione a false

        % Acquisizione
        disp(['Gesto: ', gestureID, ' - Ripetizione: ', num2str(rep)]);
        disp('Premi INVIO per iniziare o "q" per uscire e salvare...');
        % Controllo input utente
        userInput = input('', 's');
        if strcmpi(userInput, 'q')
            acquisitionInterrupted = true;
            break;
        end
        
        % Acquisizione
        smartphone.Logging = 1;
        pause(3.5); %dovrebbe essere 2,5 ma spesso i campionamenti sono meno di 250
        smartphone.Logging = 0;
        
        % Raccolta dati
        [acc, ~] = accellog(smartphone);
        [gyro, ~] = angvellog(smartphone);
        [mag, ~] = magfieldlog(smartphone);
        [orientation, ~] = orientlog(smartphone);
        smartphone.discardlogs;
        
        % Verifica che ci siano almeno 250 campioni
        if size(acc, 1) < 250
            error('Acquisizione troppo corta! Ripetere il gesto.');
        end

        % Taglio a 250 campioni
        acc = acc(1:250,:);
        gyro = gyro(1:250,:);
        mag = mag(1:250,:);
        orientation = orientation(1:250,:);
        
        % Salvataggio nella struttura
        acqName = ['acquisition_', num2str((gestureIdx-1)*5 + rep)];
        signalsStructFile.(personID).(acqName) = struct(...
            'acc', acc, ...
            'gyro', gyro, ...
            'mag', mag, ...
            'orientation', orientation, ...
            'GestureID', gestureID, ...
            'Hand', hand, ...
            'SmartphoneModel', smartphoneModel, ...
            'AvailableSensors', availableSensorsStr);

        disp(['Acquisizione ', num2str(rep), ' completata.']);
    end

    % Interruzione se l'utente ha premuto "q"
    if acquisitionInterrupted
        disp('Acquisizione interrotta dall''utente.');
        break;
    end
end

% Salvataggio finale
save('signalsStructFile.mat', 'signalsStructFile');
disp('Acquisizioni completate e salvate!');

%% Funzioni
function availableSensorsStr = getAvailableSensors(smartphone)
    sensors = [];
    if smartphone.AccelerationSensorEnabled, sensors = [sensors, 1]; end
    if smartphone.AngularVelocitySensorEnabled, sensors = [sensors, 2]; end
    if smartphone.MagneticSensorEnabled, sensors = [sensors, 3]; end
    if smartphone.OrientationSensorEnabled, sensors = [sensors, 4]; end
    
    % Converti i numeri in cell array di caratteri
    sensorCells = arrayfun(@num2str, sensors, 'UniformOutput', false);
    
    % Unisci con il separatore '-'
    availableSensorsStr = strjoin(sensorCells, '-');
end