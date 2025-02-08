% FeatureExtraction.m
% Estrazione feature per classificazione

%% Inizializzazione
close all; clear; clc;
load('signalsStructFile.mat');

% Sottoinsieme gesti target (esempio)
targetGestures = {'Class 0', 'Class 2', 'Class 3', 'Class 24'};
% Inizializzazione tabella vuota con le colonne corrette
featureNames = {
    'AccMeanX', 'AccMeanY', 'AccMeanZ', ...
    'AccStdX', 'AccStdY', 'AccStdZ', ...
    'AccEnergyX', 'AccEnergyY', 'AccEnergyZ', ...
    'GyroMeanX', 'GyroMeanY', 'GyroMeanZ', ...
    'GyroMaxX', 'GyroMaxY', 'GyroMaxZ', ...
    'CorrX', 'CorrY', 'CorrZ'};

% Inizializzazione della matrice delle feature
featureMatrix = [];
labels = [];

% Ottieni lista dei soggetti
subjects = fieldnames(signalsStructFile);

%% Estrazione feature
for subjIdx = 1:length(subjects)
    % Ottieni ID del soggetto
    personID = subjects{subjIdx};
    
    % Ottieni tutte le acquisizioni per questo soggetto
    acquisitions = fieldnames(signalsStructFile.(personID));
    
    for acqIdx = 1:length(acquisitions)
        % Ottieni i dati dell'acquisizione
        acqName = acquisitions{acqIdx};
        data = signalsStructFile.(personID).(acqName);
        
        % Verifica se il gesto è tra quelli target
        if ismember(data.GestureID, targetGestures)
            % Vettore per memorizzare tutte le feature nell'ordine corretto
            featureVector = [];

            % Accelerometro
            acc_mean = mean(data.acc);
            acc_std = std(data.acc);
            acc_energy = sum(data.acc.^2)/250;
            
            featureVector = [featureVector, acc_mean, acc_std, acc_energy];
            
            % Giroscopio
            gyro_mean = mean(data.gyro);
            gyro_max = max(abs(data.gyro));
            
            featureVector = [featureVector, gyro_mean, gyro_max];
            
            % Correlazione
            corrValues = zeros(1,3);
            for axis = 1:3
                corrValues(axis) = corr(data.acc(:,axis), data.gyro(:,axis));
            end
            featureVector = [featureVector, corrValues];
            
            % Aggiungi il vettore delle feature alla matrice
            featureMatrix = [featureMatrix; featureVector];
            
            % Aggiungi la label
            [~, labelIdx] = ismember(data.GestureID, targetGestures);
            labels = [labels; labelIdx - 1];
        end
    end
end

% Verifica che le dimensioni corrispondano
if size(featureMatrix, 2) ~= length(featureNames)
    error(['Il numero di colonne in featureMatrix (', num2str(size(featureMatrix, 2)), ...
           ') non corrisponde al numero di nomi di feature (', num2str(length(featureNames)), ').']);
end

% Creazione della tabella finale
featureTable = array2table(featureMatrix, 'VariableNames', featureNames);
featureTable.Label = categorical(labels);

% Salvataggio
save('GestureFeatures.mat', 'featureTable');
writetable(featureTable, 'GestureFeatures.csv');
disp('Feature estratte correttamente!');
disp('Ora puoi aprire il Classification Learner utilizzando il comando:');
disp('classificationLearner');


