<h1 align="center">POLIcalling</h1>

## Introduzione

L’obiettivo del progetto POLIcalling è la realizzazione di un sintetizzatore a sintesi additiva con tre oscillatori progettato per lavorare in stretta unione con qualsiasi DAW.

Il risultato ottenuto è uno strumento stand-alone che riceve come input la tastiera MIDI della DAW (nel nostro caso Ableton) e rinvia il segnale processato direttamente a una traccia audio dello stesso programma, garantendo una perfetta integrazione tra le due parti.

Questo sintetizzatore non si limita a offrire un controllo sui parametri essenziali, come l’inviluppo ADSR del volume, ma si avvale anche della tecnologia di JUCE per creare e modulare effetti sonori quali il chorus e il riverbero.

Infine, grazie all’uso del dispositivo Arduino UNO, il progetto offre all’utente un’esperienza dinamica e coinvolgente: sensori e comandi fisici permettono di plasmare il suono in tempo reale, rendendo ogni performance unica e viva.

---

## Index

1. [Synth Module](#synth-module)  
2. [Music Effects Module](#music-effects-module)  
   a. [Chorus](#a-chorus)  
   b. [Riverbero](#b-riverbero)  
3. [Arduino UNO Module](#arduino-uno-module)  

---

## Synth Module

Il sintetizzatore è composto da tre oscillatori indipendenti, ognuno con la possibilità di selezionare tra sette forme d’onda differenti. Ogni oscillatore dispone di uno slider dedicato per regolarne il volume in modo preciso.

Per arricchire il suono, ogni oscillatore è dotato di un effetto ensemble che simula la presenza di più oscillatori simili ma leggermente sfalsati, conferendo maggiore spessore e profondità al timbro complessivo.

L’inviluppo del volume di tutti e tre gli oscillatori viene gestito con un’unica ADSR, permettendo di modellare attacco, decadimento, sustain e rilascio in modo semplice e intuitivo. Inoltre, un filtro passa basso (LPF) regolabile tramite uno slider agisce simultaneamente su tutti gli oscillatori, modulandone il carattere tonale complessivo.

La sintesi sonora vera e propria è implementata con SuperCollider, che garantisce un controllo dettagliato e una qualità audio elevata. Parallelamente, l’interfaccia grafica che comprende gli slider di controllo e il visualizzatore in tempo reale della forma d’onda è stata sviluppata con Processing, offrendo un’interazione dinamica e un feedback visivo immediato per l’utente.

---

## Music Effects Module

Il segnale audio, dopo essere stato elaborato da SuperCollider, ritorna nella DAW dove può essere indirizzato a una traccia audio dedicata. Su questa traccia, gli effetti sonori creati con la potenza e la flessibilità di JUCE vengono applicati in cascata, offrendo una nuova dimensione espressiva al suono.

Gli effetti principali sviluppati per POLIcalling sono il Chorus e il Riverbero, realizzati interamente con JUCE, che permettono di arricchire il timbro con profondità, movimento e spazialità, ampliando notevolmente le possibilità creative.

<div align="center">
  <img src="Images/Music Effects Interface picture.JPG" alt="Interfaccia JUCE effetti Chorus e Riverbero" />
</div>

### a. Chorus

- **Rate**  
  Definisce la frequenza di oscillazione dell’LFO che modula il tempo di delay. Parametri di rate bassi generano modulazioni lente e ondulatorie; valori elevati producono modulazioni rapide, fino a un effetto vicino al vibrato.

- **Depth**  
  Determina la quantità di deviazione del tempo di delay introdotta dall’LFO. Con depth ridotta l’oscillazione del delay è minima, per un chorus sottile e naturale; aumentando la depth si ottengono escursioni di pitch più ampie e un carattere più “liquido”.

- **CentreDelay**  
  Imposta il tempo di ritardo di base intorno al quale l’LFO applica la modulazione. Un centreDelay breve crea un chorus più brillante e compatto; un valore maggiore rende l’effetto più corposo, avvicinandosi al doubling modulato.

- **Feedback**  
  Regola la quantità di segnale processato che viene reimmesso nel feedback del chorus. Feedback positivi rinforzano la risonanza dell’effetto; feedback negativi introducono inversioni di fase, generando interferenze timbriche particolari.

- **MixChorus**  
  Bilancia il segnale pulito (dry) con quello processato dal chorus (wet). Valori bassi mantengono il chorus in sottofondo; valori alti portano in primo piano l’effetto modulato.

### b. Riverbero

- **Size**  
  Regola il tempo di decadimento complessivo (RT60) simulando diverse dimensioni dello spazio. Aumentando la size si ottiene una coda più lunga, come in un ambiente ampio; riducendola si accorcia la coda, tipica di stanze più piccole.

- **Damp**  
  Imposta il coefficiente di smorzamento delle alte frequenze nel feedback network. Con damping ridotto le alte frequenze permangono più a lungo, generando un riverbero brillante; aumentandolo si applica un filtraggio low-pass più marcato, scurendo il tail.

- **Freeze (∞)**  
  Attiva il congelamento del buffer di riverbero: il contenuto corrente viene bloccato in un loop a feedback unitario, producendo una coda infinita finché il controllo rimane abilitato.

- **Width**  
  Controlla la distribuzione stereo del feedback di riverbero. Riducendo la width il segnale rimane centrato; ampliandola si introduce uno spostamento di fase tra i canali sinistro e destro, creando un’immagine stereo più ampia.

- **Mix**  
  Effettua il crossfade tra il segnale originale (dry) e quello processato (wet). Serve a dosare la presenza del riverbero: impostazioni moderate aggiungono profondità senza coprire l’inviluppo originale, valori alti immergono il suono nelle riflessioni.

---

## Arduino UNO Module

### Hardware e sensori

Descrizione dell’hardware e dei sensori utilizzati.

### Programmazione base e interazione

Nozioni base di programmazione Arduino e modalità di interazione con il sintetizzatore.
