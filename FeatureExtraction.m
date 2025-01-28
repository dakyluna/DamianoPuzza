% FeatureExtraction.m
% Estrazione feature per classificazione

%% Inizializzazione
close all; clear; clc;
load('signalsStructFile.mat');

% Sottoinsieme gesti target (esempio)
targetGestures = {'Class 4', 'Class 9', 'Class 2'};
featureTable = table();
subjects = fieldnames(signalsStructFile);

%% Estrazione feature
for subjIdx = 1:length(subjects)
    personID = subjects{subjIdx};
    acquisitions = fieldnames(signalsStructFile.(personID));
    
    for acqIdx = 1:length(acquisitions)
        data = signalsStructFile.(personID).(acquisitions{acqIdx});
        
        if ismember(data.GestureID, targetGestures)
            % Estrazione feature
            features = struct();
            
            % Accelerometro
            features.AccMean = mean(data.acc);
            features.AccStd = std(data.acc);
            features.AccEnergy = sum(data.acc.^2)/250;
            
            % Giroscopio
            features.GyroMean = mean(data.gyro);
            features.GyroMax = max(abs(data.gyro));
            
            % Correlazione
            for axis = 1:3
                corrVal = corr(data.acc(:,axis), data.gyro(:,axis));
                features.(['CorrAxis', num2str(axis)]) = corrVal;
            end
            
            % Conversione a tabella
            tempTable = struct2table(features);
            
            % Aggiunta label progressiva
            [~, labelIdx] = ismember(data.GestureID, targetGestures);
            tempTable.Label = categorical(labelIdx - 1);
            
            featureTable = [featureTable; tempTable];
        end
    end
end

% Rinomina colonne
featureTable.Properties.VariableNames = {
    'AccMeanX', 'AccMeanY', 'AccMeanZ', ...
    'AccStdX', 'AccStdY', 'AccStdZ', ...
    'AccEnergyX', 'AccEnergyY', 'AccEnergyZ', ...
    'GyroMeanX', 'GyroMeanY', 'GyroMeanZ', ...
    'GyroMaxX', 'GyroMaxY', 'GyroMaxZ', ...
    'CorrX', 'CorrY', 'CorrZ', ...
    'Label'};

% Salvataggio
save('GestureFeatures.mat', 'featureTable');
writetable(featureTable, 'GestureFeatures.csv');
disp('Feature estratte correttamente!');
disp('Ora puoi aprire il Classification Learner utilizzando il comando:');
disp('classificationLearner');