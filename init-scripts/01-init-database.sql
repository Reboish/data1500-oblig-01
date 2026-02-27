-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- Opprett grunnleggende tabeller

CREATE TABLE stasjon (
  stasjon_id BIGSERIAL PRIMARY KEY,
  navn TEXT NOT NULL,
  adresse TEXT NOT NULL
);

CREATE TABLE laas(
  laas_id BIGSERIAL PRIMARY KEY,
  stasjon_id BIGINT NOT NULL REFERENCES stasjon(staasjon_id)
);

CREATE TABLE sykkel(
  sykkel_id BIGSERIAL PRIMARY KEY,
  laas_id BIGINT REFERENCES laas(laas_id) -- NULL = utleid
);

CREATE TABLE kunde(
  kunde_id BIGSERIAL PRIMARY KEY,
  navn TEXT NOT NULL,
  epost TEXT UNIQUE NOT NULL
);

CREATE TABLE utleie (
  utleie_id BIGSERIAL PRIMARY KEY,
    kunde_id BIGINT NOT NULL REFERENCES kunde(kunde_id),
    sykkel_id BIGINT NOT NULL REFERENCES sykkel(sykkel_id),
    utlevert_tid TIMESTAMPTZ NOT NULL,
    innlevert_tid TIMESTAMPTZ, -- NULL = aktiv
    leiebelop NUMERIC(10,2) NOT NULL,
    fra_laas_id BIGINT NOT NULL REFERENCES laas(laas_id),
    til_laas_id BIGINT REFERENCES laas(laas_id) -- NULL til innlevering
);
  





-- Sett inn testdata



-- DBA setninger (rolle: kunde, bruker: kunde_1)



-- Eventuelt: Opprett indekser for ytelse



-- Vis at initialisering er fullført (kan se i loggen fra "docker-compose log"
SELECT 'Database initialisert!' as status;
