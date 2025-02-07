%% MergeAcquisitions.m
% Questo script carica il file signalsStructFile contenente le acquisizioni
% raggruppate per soggetto e crea un nuovo file MAT in cui le acquisizioni sono
% unite in un'unica struttura, rinumerate in ordine sequenziale.
%
% Ad esempio, se il primo soggetto ha acquisizioni da 1 a 125 e il secondo da 1 a 125,
% il nuovo file conterrà acquisizioni da 1 a 250, con prima le acquisizioni del primo
% soggetto e poi quelle del secondo, per garantire una corrispondenza tra acquisizioni
% nel file .mat e nel file .csv (in cui a causa dei label le acquisizioni sono slittate di 1).

%% Caricamento del file signalsStructFile
if exist('signalsStructFile.mat', 'file')
    load('signalsStructFile.mat', 'signalsStructFile');
    disp('File signalsStructFile caricato con successo.');
else
    error('File signalsStructFile.mat non trovato!');
end

%% Inizializzazione della struttura per le acquisizioni unite
mergedSignalsStruct = struct();
acqCounter = 1;  % Contatore per rinumerare le acquisizioni

% Ottiene i nomi dei soggetti presenti nella struttura
subjects = fieldnames(signalsStructFile);

%% Ciclo su ciascun soggetto
for subjIdx = 1:length(subjects)
    subjectID = subjects{subjIdx};
    disp(['Elaborazione del soggetto: ', subjectID]);
    
    % Ottiene i nomi delle acquisizioni per il soggetto corrente
    subjectAcquisitions = fieldnames(signalsStructFile.(subjectID));
    
    % Riordina le acquisizioni in base all'indice numerico presente nel nome del campo.
    % I nomi sono del tipo 'acquisition_<numero>'
    acqNums = zeros(length(subjectAcquisitions), 1);
    for j = 1:length(subjectAcquisitions)
        acqName = subjectAcquisitions{j};
        % Estrae la parte numerica
        numPart = sscanf(acqName, 'acquisition_%d');
        acqNums(j) = numPart;
    end
    % Ordina i nomi in base al numero estratto
    [~, sortIdx] = sort(acqNums);
    sortedAcqNames = subjectAcquisitions(sortIdx);
    
    % Aggiunge le acquisizioni del soggetto corrente alla struttura unificata
    for j = 1:length(sortedAcqNames)
        newFieldName = sprintf('acquisition_%d', acqCounter);
        mergedSignalsStruct.(newFieldName) = signalsStructFile.(subjectID).(sortedAcqNames{j});
        acqCounter = acqCounter + 1;
    end
end

%% Salvataggio della struttura unificata in un nuovo file MAT
save('mergedSignalsStructFile.mat', 'mergedSignalsStruct');
disp('Le acquisizioni unite sono state salvate in mergedSignalsStructFile.mat');
