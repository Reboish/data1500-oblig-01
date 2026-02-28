-- ============================================================================
-- TEST-SKRIPT FOR OBLIG 1
-- ===========================================================================

-- Oppgave 5.1: Vis alle sykler
SELECT * FROM sykkel;

-- Oppgave 5.2: Vis etternavn, fornavn og mobilnummer (sortert på etternavn)
-- Merk: Siden tabellen har 'navn', splitter vi på mellomrom. 
-- Antar siste ord er etternavn. Mobilnummer er ikke i din tabell, 
-- så jeg inkluderer epost som alternativ eller placeholder.
SELECT 
    split_part(navn, ' ', 2) AS etternavn, 
    split_part(navn, ' ', 1) AS fornavn,
    epost -- Erstattes med mobilnr hvis du la til den kolonnen
FROM kunde
ORDER BY etternavn ASC;

-- Oppgave 5.3: Sykler tatt i bruk etter 1. april 2023
-- Vi sjekker første gang sykkelen dukket opp i 'utleie' tabellen
SELECT DISTINCT sykkel_id 
FROM utleie 
WHERE utlevert_tid > '2023-04-01';

-- Oppgave 5.4: Antall kunder i ordningen
SELECT COUNT(*) AS totalt_antall_kunder FROM kunde;

-- Oppgave 5.5: Alle kunder og antall utleieforhold (inkludert de med 0)
SELECT k.navn, COUNT(u.utleie_id) AS antall_utleier
FROM kunde k
LEFT JOIN utleie u ON k.kunde_id = u.kunde_id
GROUP BY k.kunde_id, k.navn;

-- Oppgave 5.6: Kunder som aldri har leid sykkel
SELECT navn, epost 
FROM kunde 
WHERE kunde_id NOT IN (SELECT DISTINCT kunde_id FROM utleie);

-- Oppgave 5.7: Sykler som aldri har vært utleid
SELECT sykkel_id 
FROM sykkel 
WHERE sykkel_id NOT IN (SELECT DISTINCT sykkel_id FROM utleie);

-- Oppgave 5.8: Sykler ikke levert tilbake etter ett døgn (med kundeinfo)
-- Bruker 'NOW()' for aktive leieforhold eller sjekker differansen mellom ut/inn
SELECT 
    u.sykkel_id, 
    k.navn AS kunde_navn, 
    u.utlevert_tid,
    COALESCE(u.innlevert_tid, NOW()) - u.utlevert_tid AS leievarighet
FROM utleie u
JOIN kunde k ON u.kunde_id = k.kunde_id
WHERE (u.innlevert_tid IS NULL AND u.utlevert_tid < NOW() - INTERVAL '1 day')
   OR (u.innlevert_tid - u.utlevert_tid > INTERVAL '1 day');

-- En test med en SQL-spørring mot metadata i PostgreSQL (kan slettes fra din script)
select nspname as schema_name from pg_catalog.pg_namespace;
