# Besvarelse - Refleksjon og Analyse

**Student:** [Rebin Hawar Aradeni]

**Studentnummer:** [Ditt studentnummer]

**Dato:** [Innleveringsdato]

---

## Del 1: Datamodellering

### Oppgave 1.1: Entiteter og attributter

**Identifiserte entiteter:**

Kunde, stasjon, sykkel, utleie, lås.

**Attributter for hver entitet:**

Kunde: kunde_id (PK), mobilnummer, epost, fornavn, etternavn.
Stasjon: stasjon_id (PK), navn, address.
Sykkel: sykkel_id (PK), laas_id (FK).
Utleie: utleie_id (PK), kunde_id (PK), sykkel_id (PK), utlevert_tid, innlevert_tid, leiebelop.
lås: laas_id (PK), stasjon_id (FK).


---

### Oppgave 1.2: Datatyper og `CHECK`-constraints

**Valgte datatyper og begrunnelser:**

Kunde: kunde_id - BIGINT, mobilnummer - TEXT, epost - TEXT, fornavn - TEXT, etternavn - TEXT
Stasjon: stasjon_id - BIGINT, navn - TEXT, adresse - TEXT
Sykkel: sykkel_id - BIGINT, laas_id - BIGINT
Utleie: utleie_id - BIGINT, kunde_id - BIGINT, sykkel_id - BIGINT, utlevert_tid - TIMESTAMPTZ, innlevert_tid - TIMESTAMPTZ, leiebelop - NUMERIC(10,2), fra_laas_id - BIGINT, til_laas_id - BIGINT
Lås: laas_id - BIGINT, stasjon_id - BIGINT


**`CHECK`-constraints:**

Det er lagt inn CHECK-constraints for å sikre dataintegritet i databasen. Mobilnummer er begrenset til et gyldig format (åtte sifre, eventuelt med landskode) for å hindre ugyldige verdier, og epost må følge et enkelt epost-mønster slik at feltet ikke kan fylles med tilfeldig tekst. Fornavn, etternavn, stasjonsnavn og adresse kan ikke være tomme strenger, slik at meningsløse verdier ikke lagres selv om feltet ikke er NULL. I utleie er det lagt en CHECK-constraint som sikrer at innleveringstidspunkt enten er NULL (aktiv utleie) eller senere enn utleveringstidspunkt, for å hindre umulige tidsintervaller. I tillegg er det sikret at leiebeløp ikke kan være negativt, siden negative betalinger ikke gir mening i systemet.


**ER-diagram:**

erDiagram
    KUNDE {
        BIGINT kunde_id PK
        TEXT mobilnummer
        TEXT epost
        TEXT fornavn
        TEXT etternavn
    }

    STASJON {
        BIGINT stasjon_id PK
        TEXT navn
        TEXT adresse
    }

    LAAS {
        BIGINT laas_id PK
        BIGINT stasjon_id FK
    }

    SYKKEL {
        BIGINT sykkel_id PK
        BIGINT laas_id FK "NULL = utleid"
    }

    UTLEIE {
        BIGINT utleie_id PK
        BIGINT kunde_id FK
        BIGINT sykkel_id FK
        TIMESTAMPTZ utlevert_tid
        TIMESTAMPTZ innlevert_tid "NULL = aktiv"
        NUMERIC leiebelop
        BIGINT fra_laas_id FK
        BIGINT til_laas_id FK "NULL til innlevering"
    }

    STASJON ||--o{ LAAS : har
    LAAS ||--o{ SYKKEL : kan_ha
    KUNDE ||--o{ UTLEIE : gjor
    SYKKEL ||--o{ UTLEIE : brukes_i
    LAAS ||--o{ UTLEIE : fra
    LAAS ||--o{ UTLEIE : til


---

### Oppgave 1.3: Primærnøkler

**Valgte primærnøkler og begrunnelser:**

Kunde: Primærnøkkel er valgt som kunde_id (surrogatnøkkel). Selv om mobilnummer og epost kan fungere som naturlige nøkler fordi de ofte er unike, kan de endre seg (nytt nummer/epost), og de er derfor dårlig egnet som primærnøkkel. I stedet brukes en stabil ID som PK, mens mobilnummer og epost kan håndheves som UNIQUE. Stasjon: Primærnøkkel er stasjon_id (surrogatnøkkel). Et navn kan være en naturlig nøkkel, men er ikke garantert unikt og kan endres (omdøping), derfor brukes en ID. Lås: Primærnøkkel er laas_id (surrogatnøkkel), siden låser må kunne identifiseres unikt uavhengig av stasjon og eventuelle lokale “nummer” på stasjonen. Sykkel: Primærnøkkel er sykkel_id. Dette er en naturlig nøkkel i caset (“hver sykkel har en unik ID”), og fungerer samtidig som en stabil identifikator. Utleie: Primærnøkkel er utleie_id (surrogatnøkkel), fordi en “naturlig” nøkkel basert på f.eks. (kunde_id, sykkel_id, utlevert_tid) blir unødvendig komplisert og sårbar for feil/duplikater, mens en enkel ID gjør referanser og oppdateringer enklere.

**Naturlige vs. surrogatnøkler:**

I datamodellen er det hovedsakelig brukt **surrogatnøkler**, altså kunstige ID-felt, som primærnøkler. For entitetene Kunde, Stasjon, Lås og Utleie er det valgt egne ID-attributter (`kunde_id`, `stasjon_id`, `laas_id`, `utleie_id`) fordi naturlige kandidater som mobilnummer, epost eller stasjonsnavn kan endre seg over tid eller ikke er garantert unike. Surrogatnøkler gir stabile og enkle referanser mellom tabeller og gjør modellen mer robust mot endringer i forretningsdata. For Sykkel kan `sykkel_id` regnes som en naturlig nøkkel siden caset sier at hver sykkel har en unik ID, men den fungerer også som en stabil identifikator på samme måte som en surrogatnøkkel. Naturlige nøkler som mobilnummer og epost er derfor ikke brukt som primærnøkler, men kan i stedet håndheves med UNIQUE-constraints.


**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.4: Forhold og fremmednøkler

**Identifiserte forhold og kardinalitet:**

**Identifiserte forhold og kardinalitet:** En **stasjon** har **mange låser**, og hver **lås** tilhører **én stasjon** (1–til–mange: `Stasjon (1) → Lås (N)`, implementeres med fremmednøkkelen `laas.stasjon_id`). En **lås** kan ha **0 eller 1 sykkel** parkert, og en **sykkel** kan stå i **0 eller 1 lås** (1–til–1 “valgfri” på begge sider: `Lås (0..1) ↔ Sykkel (0..1)`, implementeres ved at `sykkel.laas_id` er en FK som kan være NULL, og med en UNIQUE-regel på `sykkel.laas_id` for å hindre at flere sykler peker på samme lås). En **kunde** kan ha **mange utleier**, men hver **utleie** tilhører **én kunde** (1–til–mange: `Kunde (1) → Utleie (N)`, implementeres med `utleie.kunde_id`). En **sykkel** kan være brukt i **mange utleier** over tid, men hver **utleie** gjelder **én sykkel** (1–til–mange: `Sykkel (1) → Utleie (N)`, implementeres med `utleie.sykkel_id`). Forholdet mellom **kunde** og **sykkel** er dermed **mange–til–mange** over tid (en kunde kan leie mange sykler, og en sykkel kan leies av mange kunder), og dette er “løst opp” av koblingstabellen/assosiative entiteten **Utleie** (Kunde ↔ Utleie ↔ Sykkel). I tillegg knytter **Utleie** til hvor utleien startet og sluttet: hver **utleie** har **én startlås** og **0 eller 1 sluttlås** (1–til–mange fra Lås til Utleie: `Lås (1) → Utleie (N)` via `utleie.fra_laas_id` og `utleie.til_laas_id`, der `til_laas_id` kan være NULL til innlevering).

**Fremmednøkler:**

Fremmednøkler brukes for å implementere relasjonene mellom entitetene og sikre referanseintegritet. `laas.stasjon_id` er en fremmednøkkel som peker til `stasjon(stasjon_id)` og implementerer forholdet **Stasjon (1) → Lås (mange)**, siden mange låser kan tilhøre samme stasjon. `sykkel.laas_id` peker til `laas(laas_id)` og viser hvor en sykkel står parkert; feltet kan være NULL når sykkelen er utleid, og sammen med en UNIQUE-regel på `sykkel.laas_id` kan dette sikre at én lås ikke kan ha flere sykler samtidig (valgfritt 1–1). `utleie.kunde_id` peker til `kunde(kunde_id)` og implementerer forholdet **Kunde (1) → Utleie (mange)**, fordi hver utleie må tilhøre én bestemt kunde. `utleie.sykkel_id` peker til `sykkel(sykkel_id)` og implementerer forholdet **Sykkel (1) → Utleie (mange)**, siden en sykkel kan inngå i mange utleier over tid, men hver utleie gjelder én sykkel. I tillegg peker `utleie.fra_laas_id` til `laas(laas_id)` og lagrer hvilken lås sykkelen ble hentet fra, mens `utleie.til_laas_id` peker til `laas(laas_id)` og lagrer hvilken lås sykkelen ble levert til (kan være NULL til innlevering); disse to fremmednøklene implementerer at hver utleie har **én startlås** og **0 eller 1 sluttlås**, og at en lås kan være brukt som start/slutt i mange utleier over tid.

**Oppdatert ER-diagram:**

[Legg inn mermaid-kode eller eventuelt en bildefil fra `mermaid.live` her]

---

### Oppgave 1.5: Normalisering

**Vurdering av 1. normalform (1NF):**

Datamodellen tilfredsstiller 1NF fordi alle tabeller har klart definerte rader med primærnøkkel, og alle attributter inneholder atomiske verdier (én verdi per felt). Det finnes ingen lister eller gjentatte grupper i samme kolonne, for eksempel lagres kontaktinformasjon (mobilnummer, epost) som egne felter og ikke som samlinger. Relasjoner som “kunde leier sykkel” håndteres gjennom egne rader i Utleie-tabellen i stedet for flere verdier i ett felt.

**Vurdering av 2. normalform (2NF):**

Modellen tilfredsstiller 2NF fordi alle tabeller enten har en enkel (ikke-sammensatt) primærnøkkel, eller så er alle ikke-nøkkelattributter fullstendig funksjonelt avhengige av hele primærnøkkelen. Siden vi bruker surrogatnøkler (*_id) som primærnøkler i tabellene, oppstår ikke problemet med delvis avhengighet (som typisk skjer når man har sammensatte primærnøkler). For eksempel er alle attributtene i Utleie avhengige av utleie_id, og kundeattributter ligger i Kunde-tabellen, ikke i Utleie.

**Vurdering av 3. normalform (3NF):**

Modellen tilfredsstiller 3NF fordi ingen ikke-nøkkelattributter er transitivt avhengige av primærnøkkelen. Hver tabell inneholder kun attributter som beskriver akkurat den entiteten tabellen representerer, og informasjon er ikke duplisert på en måte som skaper avhengigheter via andre ikke-nøkler. For eksempel lagres stasjonsinformasjon i Stasjon-tabellen, mens Lås bare lagrer referanse til stasjon via stasjon_id, og Sykkel lagrer kun referanse til lås via laas_id. Utleie lagrer kun data som hører til selve utleiehendelsen (tidspunkter, beløp og referanser til kunde/sykkel/låser) og ikke kundedata eller stasjonsdata. Dermed unngås redundans og oppdateringsanomalier, og modellen anses å være på 3NF.

**Eventuelle justeringer:**

[Skriv ditt svar her - hvis modellen ikke var på 3NF, forklar hvilke justeringer du har gjort]

---

## Del 2: Database-implementering

### Oppgave 2.1: SQL-skript for database-initialisering

**Plassering av SQL-skript:**

[Bekreft at du har lagt SQL-skriptet i `init-scripts/01-init-database.sql`]

**Antall testdata:**

- Kunder: [antall]
- Sykler: [antall]
- Sykkelstasjoner: [antall]
- Låser: [antall]
- Utleier: [antall]

---

### Oppgave 2.2: Kjøre initialiseringsskriptet

**Dokumentasjon av vellykket kjøring:**

<img width="515" height="191" alt="image" src="https://github.com/user-attachments/assets/d670b74d-6e52-4469-99b6-f77d7c343825" />
<img width="515" height="191" alt="image" src="https://github.com/user-attachments/assets/d670b74d-6e52-4469-99b6-f77d7c343825" />


**Spørring mot systemkatalogen:**

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Resultat:**

table_name 
------------
 kunde
 laas
 stasjon
 sykkel
 utleie
(5 rows)```
```

---

## Del 3: Tilgangskontroll

### Oppgave 3.1: Roller og brukere

**SQL for å opprette rolle:**

[CREATE ROLE kunde;]

**SQL for å opprette bruker:**

```sql
[CREATE USER kunde_1 WITH PASSWORD 'kunde123';
GRANT kunde TO kunde_1;]
```

**SQL for å tildele rettigheter:**

```sql
[-- Gir rollen tilgang til å koble seg til databasen og bruke public-skjemaet
GRANT CONNECT ON DATABASE oblig01 TO kunde;
GRANT USAGE ON SCHEMA public TO kunde;

-- Gir lesetilgang (SELECT) til stasjonsdata
GRANT SELECT ON stasjon, laas, sykkel TO kunde;

-- Gir både lese- og skrivetilgang (SELECT, INSERT) til kunde- og utleiedata
-- Dette lar kunden registrere seg og starte en leieperiode
GRANT SELECT, INSERT ON kunde, utleie TO kunde;]
```

---

### Oppgave 3.2: Begrenset visning for kunder

**SQL for VIEW:**

```sql
[CREATE VIEW kunde_egne_utleier AS
SELECT u.*
FROM utleie u
JOIN kunde k ON u.kunde_id = k.kunde_id
WHERE k.epost = CURRENT_USER; -- Antar at brukernavnet i DB matcher e-posten]
```

**Ulempe med VIEW vs. POLICIES:**

"En ulempe med VIEW er at det er lett å omgå hvis brukeren får direkte tilgang til den underliggende tabellen. Med POLICY er sikkerheten innebygd i selve tabellen, slik at filteret alltid gjelder uansett hvilken spørring eller visning som brukes.

---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**

[Vi deler året inn i de tre gitte sesongene:Høysesong (5 mnd: mai–sept): $20\,000 \times 5 = 100\,000$ utleierMellomsesong (4 mnd: mars, april, okt, nov): $5\,000 \times 4 = 20\,000$ utleierLavsesong (3 mnd: des–feb): $500 \times 3 = 1\,500$ utleierTotalt antall utleier per år: $121\,500$ utleier]

**Estimat for lagringskapasitet:**

[For å beregne lagringskapasiteten ser vi på tabellen som vokser mest, nemlig utleie. De andre tabellene (stasjon, kunde, sykkel) er små og relativt statiske, så de vil utgjøre under 1 MB totalt.]

Beregning per rad i utleie-tabellen:Hver rad består av følgende datatyper (standard PostgreSQL-størrelser):utleie_id (BIGINT): 8 byteskunde_id (BIGINT): 8 bytessykkel_id (BIGINT): 8 bytesutlevert_tid (TIMESTAMPTZ): 8 bytesinnlevert_tid (TIMESTAMPTZ): 8 bytesleiebelop (NUMERIC): ca. 10 bytesfra_laas_id (BIGINT): 8 bytestil_laas_id (BIGINT): 8 bytesRådata totalt per rad: 66 bytesI tillegg kommer:PostgreSQL overhead: Ca. 24 bytes per rad (row header).Indekser: Vi har opprettet 4 indekser på denne tabellen. Vi beregner ca. 25% ekstra plass for disse.Total størrelse per rad: $(66 + 24) \times 1,25 \approx \mathbf{113 \text{ bytes per rad}}$.

**Totalt for første år:**

[Vi multipliserer antall utleier med estimert størrelse per rad:$121\,500 \text{ utleier} \times 113 \text{ bytes} \approx 13\,729\,500 \text{ bytes}$Dette tilsvarer ca. $13,7 \text{ MB}$.Estimat:Inkludert faste data for stasjoner, sykler og kunder, samt litt buffer for loggfiler og systemtabeller, estimeres den nødvendige lagringskapasiteten for det første driftsåret til å være ca. 15–20 MB.]

---

### Oppgave 4.2: Flat fil vs. relasjonsdatabase

**Analyse av CSV-filen (`data/utleier.csv`):**

**Problem 1: Redundans**

[Redundans betyr at de samme dataene lagres flere ganger, noe som kaster bort plass.

Eksempel: Informasjonen om "Ole Hansen" (fornavn, etternavn, mobilnr, epost) lagres i sin helhet på rad 2, 3 og 8.

Eksempel: Navn og adresse til "Sentrum Stasjon" gjentas hver eneste gang noen starter eller slutter der, for eksempel på rad 2, 7 og 11.]

**Problem 2: Inkonsistens**

[Inkonsistens oppstår når de samme dataene lagres flere steder, men ikke lenger er like.

Eksempel: Hvis Kari Olsen (rad 4, 5 og 10) bytter telefonnummer, må vi huske å oppdatere det på alle rader. Hvis vi glemmer rad 10, vil databasen gi to ulike svar på hva nummeret hennes er.

Eksempel: En skrivefeil i adressen "Karl Johans gate 1 Oslo" på bare én av radene vil føre til at spørringer etter stasjonen feiler for den spesifikke utleien.]

**Problem 3: Oppdateringsanomalier**

[Dette handler om problemer når vi skal endre data:

Sletteanomali: Hvis vi sletter den eneste utleien til Erik Larsen (rad 9), sletter vi samtidig all informasjon om at Erik Larsen i det hele tatt eksisterer som kunde.

Innsettingsanomali: Vi kan ikke registrere en ny stasjon i systemet før noen faktisk har leid en sykkel derfra, fordi stasjonsinfoen er låst til en utleie-rad.

Oppdateringsanomali: Som nevnt under inkonsistens; én endring krever oppdatering av mange rader, noe som øker risikoen for feil.]

**Fordeler med en indeks:**

[Uten indeks må databasen utføre en Sequential Scan ($O(N)$). Det betyr at den må lese hver eneste rad fra start til slutt for å finne f.eks. alle utleier for "City Bike Pro". Med en indeks lager vi en "snarvei" (typisk $O(\log N)$) som peker direkte til radene.]

**Case 1: Indeks passer i RAM**

[Når indeksen får plass i arbeidsminnet (RAM), kan databasen finne riktig peker lynraskt uten å røre den trege harddisken. Den slår opp i en søkestruktur (som et tre), finner adressen til raden på disken, og går direkte dit for å hente resten av dataene.]

**Case 2: Indeks passer ikke i RAM**

[Hvis datasettet er enormt (mange millioner rader), må indeksen lagres på disk. For å sortere eller søke i disse dataene effektivt brukes ofte flettesortering (external merge sort). Man sorterer små biter i RAM, skriver dem til disk, og "fletter" dem sammen til en ferdig sortert struktur som minimerer antall ganger vi må lese fra disken.]

**Datastrukturer i DBMS:**

[B+-tre: Den vanligste strukturen. Den er suveren fordi den er balansert (lik søketid for alle verdier) og støtter områdesøk (f.eks. "finn alle utleier mellom juni og august"). Dataene ligger i "løvnodene" nederst, noe som gjør sekvensiell lesing veldig effektiv.Hash-indeks: Ekstremt rask for eksakte oppslag ($O(1)$), som "finn kunde med epost X". Ulempen er at den er ubrukelig til sortering eller områdesøk (den forstår ikke at "A" kommer før "B").]

---

### Oppgave 4.3: Datastrukturer for logging

**Foreslått datastruktur:**

[LSM-tree (Log-Structured Merge-tree) eller en enkel Heap-fil.]

**Begrunnelse:**Logging er en typisk "append-only"-operasjon. Det betyr at vi bare legger til nye hendelser i slutten av en fil eller struktur, og vi endrer eller sletter nesten aldri gamle logginnslag. For en slik arbeidsmengde er strukturer som B-trær (som PostgreSQL bruker for vanlige indekser) dårlig egnet, fordi de krever mye "vedlikehold" og flytting av data for å holde treet balansert hver gang noe settes inn.

**Skrive-operasjoner:**

[LSM-trær og heap-filer er ekstremt effektive for skriving fordi de benytter seg av sekvensiell I/O.I en heap-fil skriver man bare dataene rett i slutten av fila ($O(1)$ tidskompleksitet).I et LSM-tre samles skriveoperasjoner opp i en buffer i minnet (RAM) og skrives ned til disk i store blokker som sorterte filer.Dette er mye raskere enn "random I/O", hvor skrivehodet på en tradisjonell harddisk må hoppe rundt for å finne riktig plass, eller hvor SSD-kontrolleren må utføre mange små skriveoperasjoner. Dette sikrer at loggingen ikke blir en flaskehals for resten av databasen.]

**Lese-operasjoner:**

[I et loggsystem er leseoperasjoner sjeldne. Vi leser vanligvis bare logger når noe har gått galt (feilsøking) eller ved en sikkerhetsrevisjon.I en enkel heap-fil er lesing tregt fordi man må skanne hele fila ($O(N)$) for å finne det man leter etter.Et LSM-tre er bedre her, da det holder dataene delvis sortert, noe som gjør tidsbaserte søk (f.eks. "hva skjedde mellom kl. 12:00 og 13:00?") mer effektive.Siden vi leser så sjelden, er det et fornuftig bytte å ofre lesehastighet for å få maksimal skrivehastighet.]

---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**

[Validering bør gjøres i alle lagene (nettleser, applikasjonslag og database). Dette kalles en lagdelt sikkerhetsstrategi. Hvert lag har sitt eget formål: nettleseren for brukervennlighet, applikasjonslaget for sikkerhet og forretningslogikk, og databasen som den ultimate garantisten for dataintegritet.]

**Validering i nettleseren:**

[Fordeler: Gir umiddelbar tilbakemelding til brukeren (f.eks. en rød ramme rundt et felt før man trykker "send"). Dette gir en mye bedre brukeropplevelse (UX) fordi man slipper å vente på et svar fra serveren for enkle feil som manglende @ i en e-post.

Ulemper: Det er totalt usikkert. En teknisk kyndig person kan enkelt skru av JavaScript i nettleseren eller sende data rett til serveren via verktøy som Postman eller curl, og dermed hoppe over hele valideringen.]

**Validering i applikasjonslaget:**

[Fordeler: Dette er "hjernen" i systemet. Her kan vi utføre kompleks forretningslogikk som databasen kanskje ikke vet om (f.eks. sjekke om en bruker er gammel nok via et eksternt API). Det er her vi stopper ondsinnede angrep (som SQL Injection) før de når databasen.

Ulemper: Hvis noen ved en feil skriver et nytt script som snakker direkte med databasen (forbi applikasjonslaget), kan de fortsatt putte "søppel" inn i systemet hvis ikke databasen selv sier stopp.]

**Validering i databasen:**

[Fordeler: Dette er den siste skansen. Ved å bruke constraints som NOT NULL, UNIQUE, CHECK og FOREIGN KEY (slik du gjorde i Oppgave 2.2), garanterer du at dataene er konsistente uansett hvordan de kom inn. Selv om en bug i Java-koden slipper gjennom en negativ pris, vil databasen nekte å lagre den.

Ulemper: Feilmeldinger fra databasen er ofte tekniske og lite brukervennlige for en vanlig person. Det er også mer "dyrt" i form av ressurser å oppdage en feil her, siden dataene allerede har reist gjennom hele nettverket.]

**Konklusjon:**

[Vi validerer i alle lag for å kombinere det beste fra alle verdener:

Nettleser: For hastighet og brukervennlighet.

Applikasjonslag: For sikkerhet og kompleks logikk.

Database: For absolutt integritet og varig datakvalitet.
Uten validering i alle ledd risikerer man enten et system som er frustrerende å bruke, eller et system med "skitne" data som før eller siden vil krasje applikasjonen.]

---

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

[Gjennom de første ukene har jeg fått en dypere forståelse for forskjellen på ustrukturerte data (flate filer) og relasjonelle databaser. Jeg har lært hvordan man modellerer virkeligheten ved hjelp av entiteter og relasjoner, og hvordan normalisering bidrar til å fjerne dataredundans. Sentrale konsepter som primærnøkler, fremmednøkler og dataintegritet har gått fra å være teoretiske begreper til praktiske verktøy jeg bruker for å sikre at data henger logisk sammen.]

**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

[Denne oppgaven har vært avgjørende for å koble teori til praksis i tråd med emnets læringsmål:

Installasjon og oppsett: Ved å bruke Docker og docker-compose har jeg lært å sette opp et profesjonelt utviklingsmiljø for PostgreSQL.

SQL-ferdigheter: Jeg har praktisert DDL (Data Definition Language) for å bygge tabellstruktur og DML (Data Manipulation Language) for å manipulere testdata.

Sikkerhet og tilgang: Oppgaven med roller og rettigheter har gitt innsikt i hvordan man sikrer data mot uautorisert tilgang, som er et kritisk læringsmål innen databaseadministrasjon.

Analyse: Gjennom beregning av lagringskapasitet og diskusjon om indeksering har jeg lært å vurdere databasens ytelse og ressursbruk.]

Se oversikt over læringsmålene i en PDF-fil i Canvas https://oslomet.instructure.com/courses/33293/files/folder/Plan%20v%C3%A5ren%202026?preview=4370886

**Hva var mest utfordrende:**

[Det mest utfordrende var feilsøking i initialiseringsskriptet. Å forstå hvorfor en Foreign Key Constraint-feil oppstod under datainnsetting krevde en nøye gjennomgang av rekkefølgen tabellene ble opprettet og populert på. Det var også krevende, men lærerikt, å sette opp Docker-miljøet slik at SQL-skriptet ble kjørt automatisk ved oppstart av containeren, spesielt når små syntaksfeil i SQL-koden førte til at hele containeren stoppet.]

**Hva har du lært om databasedesign:**

[Jeg har lært at et godt databasedesign starter lenge før man skriver den første linjen med SQL. Prosessen med å dele opp informasjon i logiske tabeller som kunde, stasjon og sykkel viser hvor viktig det er med en ryddig struktur for å unngå oppdateringsanomalier. Jeg har også sett at designvalg, som valg av datatyper (f.eks. BIGSERIAL vs TEXT), har direkte innvirkning på både lagringsplass og ytelse når systemet skal skaleres opp til tusenvis av utleier.]

---

## Del 5: SQL-spørringer og Automatisk Testing

**Plassering av SQL-spørringer:**

[Bekreft at du har lagt SQL-spørringene i `test-scripts/queries.sql`] 


**Eventuelle feil og rettelser:**

[Feil 1: Brudd på fremmednøkkel-begrensninger (Foreign Key Violation)

Beskrivelse: Under innsetting av testdata i utleie-tabellen, forsøkte skriptet å referere til en sykkel_id (f.eks. id 39) som ennå ikke eksisterte i sykkel-tabellen. Dette skjedde fordi det kun ble generert 20 sykler, mens utleie-generatoren prøvde å velge tilfeldige tall opp til 100.

Rettelse: Jeg oppjusterte antallet rader som ble satt inn i sykkel-tabellen til 100, slik at alle referanser i utleie fant en gyldig motpart.

Feil 2: Syntaksfeil i SQL-skriptet

Beskrivelse: En UPDATE-setning ble feilaktig formatert slik at den startet direkte med et FROM-uttrykk uten den nødvendige kommandoen foran. Dette førte til at PostgreSQL avbrøt kjøringen av hele initialiseringsskriptet.

Rettelse: Jeg forenklet logikken ved å fjerne den komplekse UPDATE-setningen og erstattet den med direkte INSERT-setninger som koblet sykler til låser på en mer stabil måte.

Feil 3: Skrivefeil i kolonnenavn (Typo)

Beskrivelse: I en INSERT INTO-setning ble kolonnenavnet skrevet som staasjon_id med to a-er, mens tabellen var definert med stasjon_id.

Rettelse: Rettet skrivefeilen i SQL-filen slik at den samsvarte med tabell-definisjonen.

Feil 4: Problemer med gjenbruk av containere i Docker

Beskrivelse: Etter å ha rettet feil i SQL-filen, ble ikke endringene synlige i databasen fordi Docker gjenbrukte det gamle "volumet" (lagringen) fra forrige forsøk.

Rettelse: Jeg lærte at jeg måtte bruke kommandoen docker-compose down -v for å slette de gamle volumene helt før jeg startet opp på nytt med up -d.]

---

## Del 6: Bonusoppgaver (Valgfri)

### Oppgave 6.1: Trigger for lagerbeholdning

**SQL for trigger:**

```sql
[Skriv din SQL-kode for trigger her, hvis du har løst denne oppgaven]
```

**Forklaring:**

[Skriv ditt svar her - forklar hvordan triggeren fungerer]

**Testing:**

[Skriv ditt svar her - vis hvordan du har testet at triggeren fungerer som forventet]

---

### Oppgave 6.2: Presentasjon

**Lenke til presentasjon:**

[Legg inn lenke til video eller presentasjonsfiler her, hvis du har løst denne oppgaven]

**Hovedpunkter i presentasjonen:**

[Skriv ditt svar her - oppsummer de viktigste punktene du dekket i presentasjonen]

---

**Slutt på besvarelse**
