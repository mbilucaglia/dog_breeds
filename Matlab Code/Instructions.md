# ENCI Breed Scraper (MATLAB)

Questo progetto implementa uno scraper strutturato in **MATLAB** per l’estrazione automatica delle informazioni sulle razze canine dal sito ufficiale ENCI (Ente Nazionale Cinofilia Italiana) restituendo un dataset normalizzato contenente informazioni a livello di razza e di varietà.

---

## 🎯 Funzionalità

Lo scraper estrae automaticamente:

- Nome della razza  
- Codice FCI (preservando eventuali zeri iniziali)  
- Gruppo FCI (ID numerico e denominazione completa)  
- Sezione FCI (ID numerico e denominazione completa)  
- Codice varietà (se presente)  
- Nome varietà (se presente)  
- URL dell’immagine associata (macro-gallery)  
- URL della pagina della razza  

Per le razze con più varietà, il dataset viene espanso in modo che **ogni varietà sia rappresentata da una riga distinta**.

Per le razze senza varietà, viene creata una singola riga con campi varietà valorizzati come `missing`.

---

## 📊 Modello dei dati

Ogni riga del dataset rappresenta:

- Una combinazione **Razza–Varietà** (se presenti varietà), oppure  
- Una singola **Razza** (se non esistono varietà)

### Struttura delle colonne

| Colonna | Descrizione |
|----------|-------------|
| Breed | Nome ufficiale della razza ENCI |
| FCI | Codice numerico FCI (formato stringa) |
| GroupId | Numero del gruppo FCI |
| GroupName | Denominazione completa del gruppo FCI |
| SectionId | Numero della sezione FCI |
| SectionName | Denominazione completa della sezione FCI |
| VarietyCode | Codice varietà (es. A, B, C) |
| VarietyName | Nome della varietà (es. GROENENDAEL) |
| URL | URL della pagina ufficiale della razza |

---

## ⚙️ Architettura

Il processo di estrazione si articola in due fasi principali:

### 1️⃣ Estrazione elenco razze

- Lettura delle pagine filtrate per lettera (`?startWith=A`, ecc.)
- Parsing della struttura HTML:
  - `h3.razza-sezione` → Gruppo
  - `h4.razza-sezione` → Sezione
  - `a.hover-plus` → URL razza
  - `h3.razza-desc` → Nome razza

### 2️⃣ Parsing pagina singola razza

- Lettura della tabella `razza-spec-table`
- Estrazione strutturata di:
  - Codice FCI
  - Gruppo
  - Sezione
  - Varietà (se presenti)
  - URL dello standard
- Espansione dei dati in formato normalizzato (una riga per varietà)

---

## 🧩 Tecnologie utilizzate

- MATLAB
- `webread`
- `htmlTree`
- Parsing DOM strutturato (senza uso di regex)

Nessuna dipendenza esterna.

---

## 📤 Output

Il dataset finale può essere esportato in:

- CSV
- JSON
- Tabelle MATLAB
- Database relazionali

---

## 📌 Note tecniche

- Preserva i codici FCI nel formato originale (es. `015`)
- Gestisce razze con e senza varietà
- Struttura dati pronta per analisi statistiche o integrazione in sistemi informativi

---

## 🚀 Possibili estensioni

- Parallelizzazione del crawling
- Aggiornamento incrementale
- Validazione automatica della consistenza FCI
- Esportazione diretta verso database SQL
- Costruzione API locale su dataset generato

---

Progetto a scopo di studio e analisi dati.  
Tutti i contenuti appartengono a ENCI.
