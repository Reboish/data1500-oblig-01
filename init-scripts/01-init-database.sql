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
  stasjon_id BIGINT NOT NULL REFERENCES stasjon(stasjon_id)
);

CREATE TABLE sykkel(
  sykkel_id BIGSERIAL PRIMARY KEY,
  laas_id BIGINT REFERENCES laas(laas_id)
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
  innlevert_tid TIMESTAMPTZ,
  leiebelop NUMERIC(10,2) NOT NULL,
  fra_laas_id BIGINT NOT NULL REFERENCES laas(laas_id),
  til_laas_id BIGINT REFERENCES laas(laas_id)
);

-- Sett inn testdata
INSERT INTO kunde (navn, epost) VALUES
('Ola Nordmann','ola@test.no'), ('Kari Nordmann','kari@test.no'),
('Per Hansen','per@test.no'), ('Anne Olsen','anne@test.no'), ('Jon Iversen','jon@test.no');

INSERT INTO stasjon (navn, adresse) VALUES
('Sentrum','Storgata 1'), ('Vestsiden','Parkveien 12'), ('Østbyen','Ringveien 45'),
('Universitetet','Campus 3'), ('Togstasjonen','Jernbanetorget 1');

INSERT INTO laas (stasjon_id)
SELECT s.stasjon_id FROM stasjon s, generate_series(1,20);

INSERT INTO sykkel (laas_id)
SELECT laas_id FROM laas LIMIT 80; -- 80 sykler i lås
INSERT INTO sykkel (laas_id)
SELECT NULL FROM generate_series(1,20); -- 20 sykler utleid (NULL)

INSERT INTO utleie (kunde_id, sykkel_id, utlevert_tid, innlevert_tid, leiebelop, fra_laas_id, til_laas_id)
SELECT
    (random()*4 + 1)::bigint,
    (random()*99 + 1)::bigint,
    NOW() - (random()*interval '10 days'),
    CASE WHEN random() > 0.3 THEN NOW() - (random()*interval '1 days') ELSE NULL END,
    ROUND((random()*200 + 50)::numeric, 2),
    (random()*99 + 1)::bigint,
    CASE WHEN random() > 0.3 THEN (random()*99 + 1)::bigint ELSE NULL END
FROM generate_series(1,50);

-- Roller og tilgang
CREATE ROLE kunde;
CREATE USER kunde_1 WITH PASSWORD 'kunde123';
GRANT kunde TO kunde_1;
GRANT USAGE ON SCHEMA public TO kunde;
GRANT SELECT, INSERT ON kunde, utleie TO kunde;
GRANT SELECT ON stasjon, laas, sykkel TO kunde;

SELECT 'Database ferdig initialisert!' as status;
