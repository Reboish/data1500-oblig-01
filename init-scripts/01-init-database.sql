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

-- kunder (5)
INSERT INTO kunde (navn, epost) VALUES
('Ola Nordmann','ola@test.no'),
('Kari Nordmann','kari@test.no'),
('Per Hansen','per@test.no'),
('Anne Olsen','anne@test.no'),
('Jon Iversen','jon@test.no');

-- stasjoner (5)
INSERT INTO stasjon (navn, adresse) VALUES
('Sentrum','Storgata 1'),
('Vestsiden','Parkveien 12'),
('Østbyen','Ringveien 45'),
('Universitetet','Campus 3'),
('Togstasjonen','Jernbanetorget 1');

-- LÅSER (100 = 20 per stasjon)
INSERT INTO laas (staasjon_id)
  SELECT s.stasjon_id
  FROM stasjon s, generate_series(1,20);

-- SYKLER (100)

INSERT INTO sykkel (laas_id)
SELECT NULL FROM generate_series(1,20);

-- Koble 80 sykler til låser (20 er "utleid")
UPDATE sykkel
SET laas_id = l.laas_id
FROM (
    SELECT laas_id FROM laas ORDER BY laas_id LIMIT 80
) l
WHERE sykkel.sykkel_id IN (
    SELECT sykkel_id FROM sykkel ORDER BY sykkel_id LIMIT 80
);

-- UTLEIER (50)
INSERT INTO utleie (
    kunde_id,
    sykkel_id,
    utlevert_tid,
    innlevert_tid,
    leiebelop,
    fra_laas_id,
    til_laas_id
)
SELECT
    (random()*4 + 1)::bigint,
    (random()*99 + 1)::bigint,
    NOW() - (random()*interval '10 days'),
    CASE 
        WHEN random() > 0.3 THEN NOW() - (random()*interval '1 days')
        ELSE NULL
    END,
    ROUND((random()*200 + 50)::numeric, 2),
    (random()*99 + 1)::bigint,
    CASE 
        WHEN random() > 0.3 THEN (random()*99 + 1)::bigint
        ELSE NULL
    END
FROM generate_series(1,50);



-- DBA setninger (rolle: kunde, bruker: kunde_1)



-- Eventuelt: Opprett indekser for ytelse



-- Vis at initialisering er fullført (kan se i loggen fra "docker-compose log"
SELECT 'Database initialisert!' as status;
