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

Kunde: kunde_id, mobilnummer, epost, fornavn, etternavn.
Stasjon: stasjon_id, navn, address.
Sykkel: sykkel_id, laas_id.
Utleie: utleie_id, kunde_id, sykkel_id, utlevert_tid, innlevert_tid, leiebelop.
lås: laas_id, stasjon_id.


---

### Oppgave 1.2: Datatyper og `CHECK`-constraints

**Valgte datatyper og begrunnelser:**

Kunde: kunde_id - BIGINT, mobilnummer - TEXT, epost - TEXT, fornavn - TEXT, etternavn - TEXT
Stasjon: stasjon_id - BIGINT, navn - TEXT, adresse - TEXT
Sykkel: sykkel_id - BIGINT, laas_id - BIGINT
Utleie: utleie_id - BIGINT, kunde_id - BIGINT, sykkel_id - BIGINT, utlevert_tid - TIMESTAMPTZ, innlevert_tid - TIMESTAMPTZ, leiebelop - NUMERIC(10,2), fra_laas_id - BIGINT, til_laas_id - BIGINT
Lås: laas_id - BIGINT, stasjon_id - BIGINT


**`CHECK`-constraints:**

For å sikre at dataene i databasen er korrekte, er det lagt inn flere CHECK-constraints. Mobilnummer må følge et gyldig format altså, åtte sifre, eventuelt med landskode. Slik at ugyldige numre ikke kan registreres. E-postadresser må også følge et enkelt epost mønster, slik at feltet ikke fylles med tilfeldig tekst. Fornavn, etternavn, stasjonsnavn og adresse kan ikke være tomme strenger. Dette hindrer at meningsløse verdier lagres, selv om feltene teknisk sett ikke er NULL. I utleietabellen er det lagt inn en CHECK constraint som sikrer at innleveringstidspunktet enten er NULL (ved aktiv utleie) eller senere enn utleveringstidspunktet. På den måten unngår man umulige tidsintervaller. Det er også sikret at leiebeløpet ikke kan være negativt, siden negative betalinger ikke gir mening i systemet.

**ER-diagram:**

""""Mermaid
erDiagram
    KUNDE {
        BIGINT kunde_id
        TEXT mobilnummer
        TEXT epost
        TEXT fornavn
        TEXT etternavn
    }

    STASJON {
        BIGINT stasjon_id 
        TEXT navn
        TEXT adresse
    }

    LAAS {
        BIGINT laas_id 
        BIGINT stasjon_id 
    }

    SYKKEL {
        BIGINT sykkel_id 
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

For entiteten Kunde er primærnøkkelen valgt som kunde_id (surrogatnøkkel). Selv om mobilnummer og e-post ofte er unike og kunne fungert som naturlige nøkler, kan de endres over tid og er derfor lite egnet som primærnøkkel. I stedet brukes en stabil ID, mens mobilnummer og e-post håndheves som UNIQUE. For Stasjon benyttes stasjon_id som primærnøkkel, siden stasjonsnavn verken er garantert unike eller stabile over tid, for eksempel ved omdøping. For Lås brukes laas_id som surrogatnøkkel, fordi hver lås må kunne identifiseres entydig uavhengig av stasjon og eventuell lokal nummerering. For Sykkel er sykkel_id primærnøkkel; dette er en naturlig nøkkel i caset, ettersom hver sykkel har en unik ID, og den fungerer samtidig som en stabil identifikator. For Utleie er primærnøkkelen utleie_id (surrogatnøkkel), da en naturlig nøkkel basert på for eksempel (kunde_id, sykkel_id, utlevert_tid) ville blitt unødvendig kompleks og mer sårbar for feil og duplikater, mens en enkel ID gjør referanser og oppdateringer enklere og mer robuste.

**Naturlige vs. surrogatnøkler:**

I datamodellen er det hovedsakelig brukt surrogatnøkler, altså kunstige ID-felt, som primærnøkler. For entitetene Kunde, Stasjon, Lås og Utleie er det valgt egne ID-attributter (kunde_id, stasjon_id, laas_id, utleie_id), fordi naturlige kandidater som mobilnummer, e-post eller stasjonsnavn enten kan endre seg over tid eller ikke er garantert unike. Surrogatnøkler gir stabile og enkle referanser mellom tabeller og gjør modellen mer robust ved endringer i forretningsdata. For Sykkel kan sykkel_id regnes som en naturlig nøkkel, siden caset sier at hver sykkel har en unik ID, men den fungerer samtidig som en stabil identifikator på linje med en surrogatnøkkel. Naturlige nøkler som mobilnummer og e-post er derfor ikke brukt som primærnøkler, men kan i stedet håndheves med UNIQUE-constraints.

**Oppdatert ER-diagram:**

""""mermaid
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

### Oppgave 1.4: Forhold og fremmednøkler

**Identifiserte forhold og kardinalitet:**

Identifiserte forhold og kardinalitet: En stasjon har mange låser, og hver lås tilhører én stasjon (1–til–mange: Stasjon (1) – Lås (N)), implementert med fremmednøkkelen laas.stasjon_id. En lås kan ha 0 eller 1 sykkel parkert, og en sykkel kan stå i 0 eller 1 lås (valgfri 1–til–1-relasjon på begge sider: Lås (0..1) – Sykkel (0..1)). Dette implementeres ved at sykkel.laas_id er en fremmednøkkel som kan være NULL, kombinert med en UNIQUE-regel som hindrer at flere sykler peker på samme lås. En kunde kan ha mange utleier, mens hver utleie tilhører én kunde (1–til–mange: Kunde (1) – Utleie (N)), implementert med utleie.kunde_id. En sykkel kan brukes i mange utleier over tid, men hver utleie gjelder én sykkel (1–til–mange: Sykkel (1) – Utleie (N)), implementert med utleie.sykkel_id. Forholdet mellom kunde og sykkel er dermed mange–til–mange over tid, siden en kunde kan leie flere sykler og en sykkel kan leies av flere kunder. Dette løses gjennom den assosiative entiteten Utleie (Kunde – Utleie – Sykkel). I tillegg registrerer Utleie hvor leieforholdet startet og sluttet: hver utleie har én startlås og 0 eller 1 sluttlås. Dette gir en 1–til–mange-relasjon fra Lås til Utleie, implementert via utleie.fra_laas_id og utleie.til_laas_id, der til_laas_id kan være NULL frem til innlevering.

**Fremmednøkler:**

Fremmednøkler brukes for å implementere relasjonene mellom entitetene og sikre referanseintegritet. laas.stasjon_id er en fremmednøkkel som peker til stasjon(stasjon_id) og implementerer forholdet Stasjon (1) → Lås (mange), siden flere låser kan tilhøre samme stasjon. sykkel.laas_id peker til laas(laas_id) og angir hvor en sykkel er parkert. Feltet kan være NULL når sykkelen er utleid, og sammen med en UNIQUE-regel på sykkel.laas_id sikrer dette at én lås ikke kan ha flere sykler samtidig (valgfri 1–til–1-relasjon). utleie.kunde_id peker til kunde(kunde_id) og implementerer forholdet Kunde (1) → Utleie (mange), ettersom hver utleie må være knyttet til én bestemt kunde. utleie.sykkel_id peker til sykkel(sykkel_id) og implementerer forholdet Sykkel (1) → Utleie (mange), siden en sykkel kan inngå i mange utleier over tid, mens hver utleie gjelder én sykkel. I tillegg peker utleie.fra_laas_id til laas(laas_id) og lagrer hvilken lås sykkelen ble hentet fra, mens utleie.til_laas_id peker til laas(laas_id) og lagrer hvilken lås sykkelen ble levert til (og kan være NULL frem til innlevering). Disse to fremmednøklene implementerer at hver utleie har én startlås og 0 eller 1 sluttlås, samtidig som en lås kan brukes som start- eller sluttlås i mange utleier over tid.

**Oppdatert ER-diagram:**

""""mermaid
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

### Oppgave 1.5: Normalisering

**Vurdering av 1. normalform (1NF):**

Datamodellen tilfredsstiller 1NF fordi alle tabeller har tydelig definerte rader med primærnøkkel, og alle attributter inneholder atomiske verdier, det vil si én verdi per felt. Det finnes ingen lister eller gjentatte grupper i samme kolonne. For eksempel lagres kontaktinformasjon som mobilnummer og e-post i egne felter, ikke som sammensatte eller flerverdige attributter. Relasjoner som «kunde leier sykkel» håndteres gjennom egne rader i tabellen Utleie, i stedet for å lagre flere verdier i ett og samme felt.

**Vurdering av 2. normalform (2NF):**

Modellen tilfredsstiller 2NF fordi alle tabeller enten har en enkel (ikke-sammensatt) primærnøkkel, eller fordi alle ikke-nøkkelattributter er fullstendig funksjonelt avhengige av hele primærnøkkelen. Siden det brukes surrogatnøkler (*_id) som primærnøkler i tabellene, oppstår ikke problemet med delvis avhengighet, som typisk kan forekomme ved sammensatte primærnøkler. For eksempel er alle attributtene i Utleie funksjonelt avhengige av utleie_id, og kundeattributter er plassert i Kunde-tabellen, ikke i Utleie.

**Vurdering av 3. normalform (3NF):**

Modellen tilfredsstiller 3NF fordi ingen ikke-nøkkelattributter er transitivt avhengige av primærnøkkelen. Hver tabell inneholder kun attributter som beskriver den entiteten tabellen representerer, og informasjon er ikke duplisert på en måte som skaper avhengigheter via andre ikke-nøkkelattributter. For eksempel lagres stasjonsinformasjon i Stasjon-tabellen, mens Lås kun lagrer en referanse til stasjon via stasjon_id, og Sykkel lagrer kun en referanse til lås via laas_id. Utleie inneholder bare data som knytter seg til selve utleiehendelsen, som tidspunkter, beløp og referanser til kunde, sykkel og låser, og ikke kundedata eller stasjonsdata. Dermed unngås redundans og oppdateringsanomalier, og modellen kan anses å være i 3NF.

**Eventuelle justeringer:**


---

## Del 2: Database-implementering

### Oppgave 2.1: SQL-skript for database-initialisering

**Plassering av SQL-skript:**

check

**Antall testdata:**

- Kunder: [5]
- Sykler: [100]
- Sykkelstasjoner: [5]
- Låser: [100]
- Utleier: [50]

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

En ulempe med å bruke VIEW er at den enkelt kan omgås dersom brukeren får direkte tilgang til den underliggende tabellen. Med POLICY er sikkerheten derimot implementert på selve tabellnivået, slik at filtreringen alltid håndheves, uavhengig av hvilken spørring eller visning som benyttes.
---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**

Vi deler året inn i tre sesonger:
Høysesong (mai–september, 5 måneder): 20,000 * 5 = 100,000 utleier
Mellomsesong (mars, april, oktober, november, 4 måneder): 5,000 * 4 = 20,000 utleier
Lavsesong (desember–februar, 3 måneder): 500 \times 3 * utleier
Totalt antall utleier per år blir dermed 121,500.

**Estimat for lagringskapasitet:**

[For å beregne lagringskapasiteten ser vi på tabellen som vokser mest, nemlig Utleie. De andre tabellene, Stasjon, Kunde og Sykkel, er små og relativt statiske, og vil til sammen utgjøre mindre enn 1 MB.]

Beregning per rad i utleie-tabellen:Hver rad består av følgende datatyper (standard PostgreSQL-størrelser):utleie_id (BIGINT): 8 byteskunde_id (BIGINT): 8 bytessykkel_id (BIGINT): 8 bytesutlevert_tid (TIMESTAMPTZ): 8 bytesinnlevert_tid (TIMESTAMPTZ): 8 bytesleiebelop (NUMERIC): ca. 10 bytesfra_laas_id (BIGINT): 8 bytestil_laas_id (BIGINT): 8 bytesRådata totalt per rad: 66 bytesI tillegg kommer:PostgreSQL overhead: Ca. 24 bytes per rad (row header).Indekser: Vi har opprettet 4 indekser på denne tabellen. Vi beregner ca. 25% ekstra plass for disse.Total størrelse per rad: $(66 + 24) \times 1,25 \approx \mathbf{113 \text{ bytes per rad}}$.

**Totalt for første år:**

[For å beregne total lagringskapasitet multipliserer vi antall utleier med estimert størrelse per rad:

121500 utleier × 113bytes ≈ 13 729 500 bytes
Dette tilsvarer omtrent 13,7 MB.
Når vi inkluderer faste data for stasjoner, sykler og kunder, samt legger inn litt buffer for loggfiler og systemtabeller, estimeres den nødvendige lagringskapasiteten for det første driftsåret til å være rundt 15–20 MB.]

---

### Oppgave 4.2: Flat fil vs. relasjonsdatabase

**Analyse av CSV-filen (`data/utleier.csv`):**



**Problem 1: Redundans**

[Redundans innebærer at de samme dataene lagres flere ganger, noe som kaster bort lagringsplass og kan føre til inkonsistens. Feks lagres informasjon om Ole Hansen, fornavn, etternavn, mobilnummer og e-post, på rad 2, 3 og 8. På samme måte gjentas navn og adresse til Sentrum Stasjon hver gang noen starter eller avslutter en utleie der, for eksempel på rad 2, 7 og 11.




**Problem 2: Inkonsistens**

[Inkonsistens oppstår når de samme dataene lagres flere steder, men ikke lenger er like. Feks, hvis Kari Olsen (rad 4, 5 og 10) bytter telefonnummer, må oppdateringen gjøres på alle rader; hvis vi glemmer rad 10, vil databasen gi ulike svar på hva nummeret hennes er. På samme måte kan en skrivefeil i adressen Karl Johans gate 1 Oslo på bare én rad føre til at spørringer etter stasjonen feiler for den spesifikke utleien.



**Problem 3: Oppdateringsanomalier**

[Datamodellen kan føre til ulike typer anomalier ved endringer i data. En sletteanomali oppstår dersom vi sletter den eneste utleien til Erik Larsen, fordi all informasjon om ham som kunde da også fjernes. En innsettingsanomali kan oppstå når vi ikke kan registrere en ny stasjon før noen faktisk har leid en sykkel derfra, ettersom stasjonsinformasjon er bundet til utleie rader Til slutt kan en oppdateringsanomali oppstå når én endring krever oppdatering av mange rader samtidig, noe som øker risikoen for feil og inkonsistens i databasen.





**Fordeler med en indeks:**

Hvis man ikke hadde en indeks måtte databasen utføre en Sequential Scan. Det betyr at den må lese hver eneste rad fra start til slutt for å finne feks. alle utleier for City Bike Pro. Med en indeks lager vi en snarvei som peker direkte til radene.

**Case 1: Indeks passer i RAM**

Når indeksen får plass i arbeidsminnet (RAM), kan databasen finne riktig peker lynraskt uten å røre den trege harddisken. Den slår opp i en søkestruktur altså som et tre, finner adressen til raden på disken, og går direkte dit for å hente resten av dataene.

**Case 2: Indeks passer ikke i RAM**

Hvis datasettet er enormt, at den ermange millioner rader, må indeksen lagres på disk. For å sortere eller søke i disse dataene effektivt brukes ofte flettesortering (external merge sort). Man sorterer små biter i RAM, skriver dem til disk, og fletter dem sammen til en ferdig sortert struktur som minimerer antall ganger vi må lese fra disken.

**Datastrukturer i DBMS:**

En B+-tre-indeks er den vanligste strukturen og er svært effektiv fordi den er balansert, noe som gir lik søketid for alle verdier, samtidig som den støtter områdesøk, for eksempel «finn alle utleier mellom juni og august». Dataene lagres i løvnodene nederst, noe som gjør sekvensiell lesing veldig effektiv. En hash-indeks gir derimot ekstremt raske eksakte oppslag, for eksempel «finn kunde med epost X», men den kan ikke brukes til sortering eller områdesøk, siden den ikke har informasjon om rekkefølgen på verdiene.

---




### Oppgave 4.3: Datastrukturer for logging

**Foreslått datastruktur:**

LSM-tree eller en enkel Heap-fil.

**Begrunnelse:**
logging er en LSM-tree eller en enkel heap-fil godt egnet datastrukturvalg, siden logging er typisk en "append-only"-operasjon der nye hendelser legges til, og gamle logginnslag sjelden endres eller slettes. Tradisjonelle B-trær, som PostgreSQL bruker for vanlige indekser, er mindre effektive for denne typen arbeidsmengde, fordi de krever mye vedlikehold og balansering ved hver innsetting.

**Skrive-operasjoner:**
Skriveoperasjoner i både heap-filer og LSM-trær er svært raske, ettersom de utnytter sekvensiell I/O. I en heap-fil skrives data rett til slutten av fila ($O(1)$), mens et LSM-tre samler skriver i en buffer i minnet og skriver store sorterte blokker til disk. Dette er mye mer effektivt enn tilfeldig I/O, hvor skrivehodet må hoppe rundt på en tradisjonell harddisk, eller hvor SSD-kontrolleren må håndtere mange små operasjoner. På denne måten sikres det at loggingen ikke blir en flaskehals for resten av databasen.


**Lese-operasjoner:**
Leseoperasjoner er derimot sjeldne i et loggsystem, vanligvis kun ved feilsøking eller sikkerhetsrevisjon. I en heap-fil kan lesing være tregt, fordi man må skanne hele fila ($O(N)$) for å finne det man leter etter. Et LSM-tre holder data delvis sortert, noe som gjør tidsbaserte søk, for eksempel «hva skjedde mellom kl. 12:00 og 13:00?», mer effektive. Siden leseoperasjoner forekommer sjelden, er det ofte en god strategi å ofre noe lesehastighet for å oppnå maksimal skrivehastighet.




---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**

Validering bør gjøres i alle lagene (nettleser, applikasjonslag og database). Dette kalles en lagdelt sikkerhetsstrategi. Hvert lag har sitt eget formål: nettleseren for brukervennlighet, applikasjonslaget for sikkerhet og forretningslogikk, og databasen som den ultimate garantisten for dataintegritet.

**Validering i nettleseren:**

Fordelen med klient-side validering er at den gir umiddelbar tilbakemelding til brukeren, for eksempel ved å markere et felt med rød ramme før skjemaet sendes. Dette forbedrer brukeropplevelsen (UX) betydelig, fordi man slipper å vente på svar fra serveren for enkle feil, som en manglende @ i en e-postadresse. 
Ulempen er at det ikke gir sikkerhet; en teknisk kyndig person kan enkelt deaktivere JavaScript i nettleseren eller sende data direkte til serveren med verktøy som Postman eller curl, og dermed omgå all validering på klienten.

**Validering i applikasjonslaget:**

Fordelen med applikasjonslaget er at det fungerer som "hjernen" i systemet, der kompleks forretningslogikk kan utføres, for eksempel å sjekke om en bruker er gammel nok via et eksternt API. Det er også her vi kan stoppe ondsinnede angrep, som SQL-injection, før de når databasen. Ulempen er at hvis noen ved en feil skriver et script som går direkte mot databasen og omgår applikasjonslaget, kan de fortsatt sette inn ugyldige eller skadelige data dersom databasen ikke selv håndhever restriksjoner.

**Validering i databasen:**

Fordelen med å bruke databasen som siste sikkerhetssperre er at den garanterer konsistente data gjennom constraints som NOT NULL, UNIQUE, CHECK og FOREIGN KEY, slik som vist i Oppgave 2.2. Selv om en bug i applikasjonen skulle slippe gjennom for eksempel en negativ pris, vil databasen nekte å lagre den. Ulempen er at feilmeldingene fra databasen ofte er tekniske og lite brukervennlige for vanlige brukere, og det kan være mer ressurskrevende å oppdage en feil her, siden dataene allerede har reist gjennom hele nettverket.




**Konklusjon:**

Vi validerer i alle lag for å kombinere det beste fra alle verdener:

Nettleser: For hastighet og brukervennlighet.
Applikasjonslag: For sikkerhet og kompleks logikk.
Database: For absolutt integritet og varig datakvalitet.
Uten validering i alle ledd risikerer man enten et system som er frustrerende å bruke, eller et system med "skitne" data som før eller siden vil krasje applikasjonen.

---

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

Gjennom de første ukene har jeg fått en dypere forståelse for forskjellen på ustrukturerte data (flate filer) og relasjonelle databaser. Jeg har lært hvordan man modellerer virkeligheten ved hjelp av entiteter og relasjoner, og hvordan normalisering bidrar til å fjerne dataredundans. Sentrale konsepter som primærnøkler, fremmednøkler og dataintegritet har gått fra å være teoretiske begreper til praktiske verktøy jeg bruker for å sikre at data henger logisk sammen.

**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

Denne oppgaven har vært avgjørende for å koble teori til praksis i tråd med emnets læringsmål:

Installasjon og oppsett: Ved å bruke Docker og docker-compose har jeg lært å sette opp et profesjonelt utviklingsmiljø for PostgreSQL.
SQL-ferdigheter: Jeg har praktisert DDL (Data Definition Language) for å bygge tabellstruktur og DML (Data Manipulation Language) for å manipulere testdata.
Sikkerhet og tilgang: Oppgaven med roller og rettigheter har gitt innsikt i hvordan man sikrer data mot uautorisert tilgang, som er et kritisk læringsmål innen databaseadministrasjon.
Analyse: Gjennom beregning av lagringskapasitet og diskusjon om indeksering har jeg lært å vurdere databasens ytelse og ressursbruk.

--

Se oversikt over læringsmålene i en PDF-fil i Canvas https://oslomet.instructure.com/courses/33293/files/folder/Plan%20v%C3%A5ren%202026?preview=4370886

**Hva var mest utfordrende:**

Det mest utfordrende var feilsøking i initialiseringsskriptet. Å forstå hvorfor en Foreign Key Constraint-feil oppstod under datainnsetting krevde en nøye gjennomgang av rekkefølgen tabellene ble opprettet og populert på. Det var også krevende, men lærerikt, å sette opp Docker-miljøet slik at SQL-skriptet ble kjørt automatisk ved oppstart av containeren, spesielt når små syntaksfeil i SQL-koden førte til at hele containeren stoppet.

**Hva har du lært om databasedesign:**

Jeg har lært at et godt databasedesign starter lenge før man skriver den første linjen med SQL. Prosessen med å dele opp informasjon i logiske tabeller som kunde, stasjon og sykkel viser hvor viktig det er med en ryddig struktur for å unngå oppdateringsanomalier. Jeg har også sett at designvalg, som valg av datatyper (f.eks. BIGSERIAL vs TEXT), har direkte innvirkning på både lagringsplass og ytelse når systemet skal skaleres opp til tusenvis av utleier.

---





## Del 5: SQL-spørringer og Automatisk Testing

**Plassering av SQL-spørringer:**

check 


**Eventuelle feil og rettelser:**

[Feil 1: Brudd på fremmednøkkel-begrensninger (Foreign Key Violation)

Under innsetting av testdata i Utleie-tabellen forsøkte skriptet å referere til en sykkel_id (for eksempel id 39) som ikke eksisterte i Sykkel-tabellen, fordi det opprinnelig kun ble generert 20 sykler, mens utleie-generatoren tilfeldig valgte tall opptil 100. Problemet ble løst ved å øke antall rader som ble satt inn i Sykkel-tabellen til 100, slik at alle referanser i Utleie fikk en gyldig motpart.


Feil 2: Syntaksfeil i SQL-skriptet

En UPDATE-setning i initialiseringsskriptet var feilaktig formatert og startet direkte med et FROM-uttrykk uten den nødvendige kommandoen foran, noe som gjorde at PostgreSQL avbrøt kjøringen av hele skriptet. Problemet ble løst ved å forenkle logikken: den komplekse UPDATE-setningen ble fjernet og erstattet med direkte INSERT-setninger som koblet sykler til låser på en mer stabil og sikker måte.

Feil 3: Skrivefeil i kolonnenavn (Typo)

I en INSERT INTO-setning ble kolonnenavnet skrevet som staasjon_id med to a-er, mens tabellen var definert med stasjon_id. Problemet ble løst ved å rette skrivefeilen i SQL-filen, slik at kolonnenavnet nå samsvarer med tabell-definisjonen.


Feil 4: Problemer med gjenbruk av containere i Docker

Etter å ha rettet feil i SQL-filen ble ikke endringene synlige i databasen, fordi Docker gjenbrukte det gamle volumet fra forrige oppstart. Problemet ble løst ved å bruke kommandoen docker-compose down -v for å slette de gamle volumene helt, før jeg startet opp på nytt med docker-compose up -d.

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
