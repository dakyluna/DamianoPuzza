% DataAcquisition.m
% Questo script gestisce l'acquisizione dei dati dai sensori di uno smartphone.
% Vengono configurati i sensori, acquisiti i dati per una serie di gesti e salvati
% in un file MAT, oltre che in un file CSV contenente le annotazioni per ciascuna acquisizione.

%% Inizializzazione
% Chiude tutte le figure, pulisce le variabili e la command window
close all; clear; clc;

%% Configurazione del dispositivo mobile
% Creazione dell'oggetto mobiledev per accedere ai sensori dello smartphone
smartphone = mobiledev;

% Abilitazione dei sensori necessari per l'acquisizione
smartphone.AccelerationSensorEnabled = 1;
smartphone.MagneticSensorEnabled = 1;
smartphone.OrientationSensorEnabled = 1;
smartphone.AngularVelocitySensorEnabled = 1;
smartphone.SampleRate = 100; % Frequenza di campionamento (100 Hz)

% Recupero e visualizzazione dei sensori attivi
availableSensorsStr = getAvailableSensors(smartphone);
disp(['Sensori disponibili: ', availableSensorsStr]);

%% Impostazione dei parametri utente
% Richiede all'utente di inserire l'ID del soggetto e il modello dello smartphone
personID = input('Inserisci l''ID del soggetto (es. "P1"): ', 's');
smartphoneModel = input('Inserisci il modello dello smartphone: ', 's');

% Richiede all'utente di specificare la mano utilizzata (accetta solo "dx" o "sx")
while true
    hand = input('Mano utilizzata (dx/sx): ', 's');
    if ismember(hand, {'dx', 'sx'}),
        break;
    else
        disp('Input non valido!');
    end
end

%% Caricamento o creazione della struttura dati
% Se esiste già un file con le acquisizioni precedenti, lo carica; 
% altrimenti, inizializza una nuova struttura dati
if exist('signalsStructFile.mat', 'file')
    load('signalsStructFile.mat');
    disp('File caricato con successo!');
else
    signalsStructFile = struct();
    disp('File creato con successo!');
end

% Dizionario gesti (24 + scarto)
allGestures = [arrayfun(@(x) sprintf('Class %d', x), 0:23, 'UniformOutput', false), {'Class 24'}];

%% Acquisizione dei dati per ciascun gesto (5 ripetizioni per ogni gesto)
% Ciclo principale: per ogni gesto definito in allGestures
for gestureIdx = 1:length(allGestures)
    gestureID = allGestures{gestureIdx};
    
     % Ciclo per le 5 ripetizioni dell'acquisizione per il gesto corrente
    for rep = 1:5

        % Se il soggetto non è ancora presente nella struttura dati, lo inizializzo
        if ~isfield(signalsStructFile, personID)
            signalsStructFile.(personID) = struct();
        end
        
        % Variabile per gestire l'interruzione manuale dell'acquisizione
        acquisitionInterrupted = false;

        % Visualizzazione informazioni sull'acquisizione corrente
        disp(['Gesto: ', gestureID, ' - Ripetizione: ', num2str(rep)]);
        disp('Premi INVIO per iniziare o "q" per uscire e salvare...');

        % Controlla l'input utente: se digita "q" viene interrotta la sessione di acquisizione
        userInput = input('', 's');
        if strcmpi(userInput, 'q')
            acquisitionInterrupted = true;
            break;
        end
        
        %% Acquisizione dei dati dai sensori
        % Avvio della registrazione dei dati
        smartphone.Logging = 1;
        pause(3.5); %dovrebbe essere 2,5 ma spesso i campionamenti sono meno di 250
        % Arresto della registrazione
        smartphone.Logging = 0;
        
        % Recupero dei dati dai vari sensori
        [acc, ~] = accellog(smartphone);
        [gyro, ~] = angvellog(smartphone);
        [mag, ~] = magfieldlog(smartphone);
        [orientation, ~] = orientlog(smartphone);
        % Pulizia dei log per preparare l'acquisizione successiva
        smartphone.discardlogs;
        
        %% Verifica e preparazione dei dati acquisiti
        % Controlla se il numero di campioni acquisiti è sufficiente (almeno 250)
        if any([size(acc,1), size(gyro,1), size(mag,1), size(orientation,1)] < 250)
            error('Acquisizione troppo corta!');
        end

        % Taglio a 250 campioni
        acc = acc(1:250,:);
        gyro = gyro(1:250,:);
        mag = mag(1:250,:);
        orientation = orientation(1:250,:);
        
        %% Salvataggio dei dati acquisiti nella struttura
        % Costruisce un nome univoco per l'acquisizione basato su gesto e ripetizione
        acqName = ['acquisition_', num2str((gestureIdx-1)*5 + rep)];
        % Salva i dati e le informazioni associate nella struttura per il soggetto
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

    % Se l'utente ha interrotto l'acquisizione (digitando "q"), esce dal ciclo dei gesti
    if acquisitionInterrupted
        disp('Acquisizione interrotta dall''utente.');
        break;
    end
end

%% Salvataggio finale dei dati acquisiti
% Salva la struttura dati in un file MAT
save('signalsStructFile.mat', 'signalsStructFile');
disp('Acquisizioni completate e salvate!');

%% Generazione della tabella CSV delle annotazioni
% Crea una tabella vuota per raccogliere i metadati di ogni acquisizione
dataTable = table();
subjects = fieldnames(signalsStructFile);

% Ciclo attraverso ogni soggetto e le relative acquisizioni
for subjIdx = 1:length(subjects)
    personID = subjects{subjIdx};
    acquisitions = fieldnames(signalsStructFile.(personID));
    
    for acqIdx = 1:length(acquisitions)
        acqName = acquisitions{acqIdx};
        data = signalsStructFile.(personID).(acqName);
        
        % Creazione di una nuova riga con i metadati dell'acquisizione corrente
        newRow = table({personID}, acqIdx, {data.Hand}, {data.SmartphoneModel}, ...
            {data.AvailableSensors}, {data.GestureID}, ...
            'VariableNames', {'ID_Subject', 'Idx_Acquisition', 'Hand', ...
            'Smartphone_model', 'Available_Sensors', 'ID_Gesture'});

        % Aggiunge la nuova riga alla tabella dei metadati
        dataTable = [dataTable; newRow];
    end
end

% Salva la tabella dei metadati in un file CSV (senza nomi delle variabili
%                                               così c'è corrispondenza con
%                                               il mergedSignalStruct).
writetable(dataTable, 'Metadati.csv', 'WriteVariableNames', false);
disp('File Metadati.csv generato con tutte le acquisizioni!');

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