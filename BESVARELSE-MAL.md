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

[Skriv ditt svar her - f.eks. skjermbilder eller output fra terminalen som viser at databasen ble opprettet uten feil]

**Spørring mot systemkatalogen:**

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Resultat:**

```
[Skriv resultatet av spørringen her - list opp alle tabellene som ble opprettet]
```

---

## Del 3: Tilgangskontroll

### Oppgave 3.1: Roller og brukere

**SQL for å opprette rolle:**

```sql
[Skriv din SQL-kode for å opprette rollen 'kunde' her]
```

**SQL for å opprette bruker:**

```sql
[Skriv din SQL-kode for å opprette brukeren 'kunde_1' her]
```

**SQL for å tildele rettigheter:**

```sql
[Skriv din SQL-kode for å tildele rettigheter til rollen her]
```

---

### Oppgave 3.2: Begrenset visning for kunder

**SQL for VIEW:**

```sql
[Skriv din SQL-kode for VIEW her]
```

**Ulempe med VIEW vs. POLICIES:**

[Skriv ditt svar her - diskuter minst én ulempe med å bruke VIEW for autorisasjon sammenlignet med POLICIES]

---

## Del 4: Analyse og Refleksjon

### Oppgave 4.1: Lagringskapasitet

**Gitte tall for utleierate:**

- Høysesong (mai-september): 20000 utleier/måned
- Mellomsesong (mars, april, oktober, november): 5000 utleier/måned
- Lavsesong (desember-februar): 500 utleier/måned

**Totalt antall utleier per år:**

[Skriv din utregning her]

**Estimat for lagringskapasitet:**

[Skriv din utregning her - vis hvordan du har beregnet lagringskapasiteten for hver tabell]

**Totalt for første år:**

[Skriv ditt estimat her]

---

### Oppgave 4.2: Flat fil vs. relasjonsdatabase

**Analyse av CSV-filen (`data/utleier.csv`):**

**Problem 1: Redundans**

[Skriv ditt svar her - gi konkrete eksempler fra CSV-filen som viser redundans]

**Problem 2: Inkonsistens**

[Skriv ditt svar her - forklar hvordan redundans kan føre til inkonsistens med eksempler]

**Problem 3: Oppdateringsanomalier**

[Skriv ditt svar her - diskuter slette-, innsettings- og oppdateringsanomalier]

**Fordeler med en indeks:**

[Skriv ditt svar her - forklar hvorfor en indeks ville gjort spørringen mer effektiv]

**Case 1: Indeks passer i RAM**

[Skriv ditt svar her - forklar hvordan indeksen fungerer når den passer i minnet]

**Case 2: Indeks passer ikke i RAM**

[Skriv ditt svar her - forklar hvordan flettesortering kan brukes]

**Datastrukturer i DBMS:**

[Skriv ditt svar her - diskuter B+-tre og hash-indekser]

---

### Oppgave 4.3: Datastrukturer for logging

**Foreslått datastruktur:**

[Skriv ditt svar her - f.eks. heap-fil, LSM-tree, eller annen egnet datastruktur]

**Begrunnelse:**

**Skrive-operasjoner:**

[Skriv ditt svar her - forklar hvorfor datastrukturen er egnet for mange skrive-operasjoner]

**Lese-operasjoner:**

[Skriv ditt svar her - forklar hvordan datastrukturen håndterer sjeldne lese-operasjoner]

---

### Oppgave 4.4: Validering i flerlags-systemer

**Hvor bør validering gjøres:**

[Skriv ditt svar her - argumenter for validering i ett eller flere lag]

**Validering i nettleseren:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Validering i applikasjonslaget:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Validering i databasen:**

[Skriv ditt svar her - diskuter fordeler og ulemper]

**Konklusjon:**

[Skriv ditt svar her - oppsummer hvor validering bør gjøres og hvorfor]

---

### Oppgave 4.5: Refleksjon over læringsutbytte

**Hva har du lært så langt i emnet:**

[Skriv din refleksjon her - diskuter sentrale konsepter du har lært]

**Hvordan har denne oppgaven bidratt til å oppnå læringsmålene:**

[Skriv din refleksjon her - koble oppgaven til læringsmålene i emnet]

Se oversikt over læringsmålene i en PDF-fil i Canvas https://oslomet.instructure.com/courses/33293/files/folder/Plan%20v%C3%A5ren%202026?preview=4370886

**Hva var mest utfordrende:**

[Skriv din refleksjon her - diskuter hvilke deler av oppgaven som var mest krevende]

**Hva har du lært om databasedesign:**

[Skriv din refleksjon her - reflekter over prosessen med å designe en database fra bunnen av]

---

## Del 5: SQL-spørringer og Automatisk Testing

**Plassering av SQL-spørringer:**

[Bekreft at du har lagt SQL-spørringene i `test-scripts/queries.sql`]


**Eventuelle feil og rettelser:**

[Skriv ditt svar her - hvis noen tester feilet, forklar hva som var feil og hvordan du rettet det]

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
