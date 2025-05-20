<h1 align="center">POLIcalling</h1>

## Introduzione

L’obiettivo del progetto POLIcalling è la realizzazione di un sintetizzatore a sintesi additiva con tre oscillatori progettato per lavorare in stretta unione con qualsiasi DAW.

Il risultato ottenuto è uno strumento stand-alone che riceve come input la tastiera MIDI della DAW (nel nostro caso il programma Ableton) e rinvia il segnale processato direttamente a una traccia audio dello stesso programma, garantendo una perfetta integrazione tra le due parti.

Questo sintetizzatore non si limita a offrire un controllo sui parametri essenziali, come ad esempio l’inviluppo ADSR del volume, ma si avvale anche della tecnologia di JUCE per creare e modulare effetti sonori quali il chorus e il riverbero.

Infine, grazie all’uso del dispositivo Arduino UNO il progetto offre all’utente un’esperienza dinamica e coinvolgente. Sensori e comandi fisici permettono di plasmare il suono in tempo reale, rendendo ogni performance unica e viva.

---

## Index

1. [Synth Module](#synth-module)  
2. [Music Effects Module](#music-effects-module)  
   a. [Chorus](#chorus)  
   b. [Riverbero](#riverbero)  
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

Gli effetti principali sviluppati per POLIcalling sono il Chorus e il Riverbero, realizzati interamente con la tecnologia JUCE, che permettono di arricchire il timbro con profondità, movimento e spazialità, ampliando notevolmente le possibilità creative.

### a. Chorus

Il modulo Chorus consente di modulare la ricchezza e la complessità del suono tramite parametri come la profondità, la velocità di modulazione e il mix tra segnale originale e effetto, permettendo di ottenere da lievi variazioni a texture sonore molto corpose.

### b. Riverbero

Il Riverbero offre un controllo preciso su parametri fondamentali quali il tempo di decadimento, la dimensione della stanza simulata e la quantità di segnale riverberato, regalando un senso di spazio naturale o evocativo a seconda delle esigenze artistiche.

---

## Arduino UNO Module

### Hardware e sensori

Descrizione dell’hardware e dei sensori utilizzati.

### Programmazione base e interazione

Nozioni base di programmazione Arduino e modalità di interazione con il sintetizzatore.
