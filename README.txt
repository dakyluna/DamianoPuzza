IoT per l'Industria dei Videogame e della Realtà Virtuale  
 
Tesina - Gruppo 15 

Struttura del Repository  
- `DataAcquisition.m`: Script per l'acquisizione dati dai sensori dello smartphone.  
- `DataVisualization.m`: Script per visualizzare i segnali e generare il file CSV delle annotazioni.  
- `FeatureExtraction.m`: Script per l'estrazione delle feature e preparazione dei dati per la classificazione (Opzione 1).  
- `signalsStructFile.mat`: Dataset strutturato delle acquisizioni.  
- `Metadati.csv`: Annotazioni delle acquisizioni (ID soggetto, gesto, sensori, ecc.).  
- `GestureFeatures.csv`: Feature estratte per il classificatore (Opzione 1).  
- `README.txt`: Questo file.  

---

Contenuto del file .csv (Metadati.csv)
Ogni riga corrisponde a un'acquisizione e include:

ID_Subject: Identificativo del soggetto (es. "P1").

Idx_Acquisition: Numero progressivo dell'acquisizione per il soggetto.

Hand: Mano utilizzata ("dx" o "sx").

Smartphone_model: Modello dello smartphone (es. "Samsung Galaxy S24").

Available_Sensors: Sensori attivi durante l'acquisizione (es. "1-2-3" per accelerometro, giroscopio e magnetometro, "5" per tutti attivi).

ID_Gesture: Classe del gesto eseguito (es. "Class 4", "Class 24" per lo scarto).


Protocollo di Acquisizione

Specifiche Tecniche
Posizione del sensore: Fissato al polso dell'utente.

Frequenza di campionamento: 100 Hz.

Durata acquisizione: 2.5 secondi (250 campioni).

Gesti acquisiti:

24 gesti definiti nel dizionario (Figura 1 del documento).

5 acquisizioni per gesto + 5 acquisizioni per classe di scarto (movimenti casuali).

Totale: 125 acquisizioni per soggetto (25 gesti × 5 ripetizioni).

Istruzioni per l'utente
Partire da una posizione ferma.

Eseguire il gesto seguendo il percorso indicato nel dizionario.

Rimanere fermi fino al termine dell'acquisizione.

🛠️ Funzionamento degli Script
1. Acquisizione Dati (DataAcquisition.m)
Input richiesti:

ID del soggetto (es. "P1").

Modello dello smartphone.

Mano utilizzata ("dx" o "sx").

ID del gesto da eseguire (es. "Class 3").

Output:

signalsStructFile.mat: Dati dei sensori in struttura nidificata.

Salvataggio automatico dopo ogni acquisizione.

2. Visualizzazione Dati (DataVisualization.m)
Funzionalità:

Genera grafici per accelerometro, giroscopio, magnetometro e orientazione.

Crea il file Metadati.csv con le annotazioni.

Permette di rieseguire la visualizzazione per acquisizioni specifiche.

3. Estrazione Feature (FeatureExtraction.m) - Opzione 1
Feature estratte:

Media, deviazione standard, energia (accelerometro e giroscopio).

Correlazione tra accelerometro e giroscopio.

Output:

GestureFeatures.mat: Tabella delle feature per il Classification Learner.

GestureFeatures.csv: File CSV di riferimento.