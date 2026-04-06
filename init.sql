CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS domains (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prov_source (
  id BIGSERIAL PRIMARY KEY,
  domain_id BIGINT REFERENCES domains(id) ON DELETE SET NULL,
  source_url TEXT,
  title TEXT,
  source_type TEXT,
  checksum TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prov_chunk (
  id BIGSERIAL PRIMARY KEY,
  source_id BIGINT NOT NULL REFERENCES prov_source(id) ON DELETE CASCADE,
  chunk_index INT NOT NULL,
  content TEXT NOT NULL,
  embedding VECTOR(768),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prov_entity (
  id BIGSERIAL PRIMARY KEY,
  chunk_id BIGINT REFERENCES prov_chunk(id) ON DELETE CASCADE,
  entity_name TEXT NOT NULL,
  entity_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prov_answer (
  id BIGSERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  verifier_score DOUBLE PRECISION,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS job_checkpoint (
  id BIGSERIAL PRIMARY KEY,
  job_name TEXT NOT NULL,
  checkpoint_key TEXT NOT NULL,
  checkpoint_value JSONB,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(job_name, checkpoint_key)
);

CREATE INDEX IF NOT EXISTS idx_prov_source_domain_id ON prov_source(domain_id);
CREATE INDEX IF NOT EXISTS idx_prov_chunk_source_id ON prov_chunk(source_id);
CREATE INDEX IF NOT EXISTS idx_prov_entity_chunk_id ON prov_entity(chunk_id);
CREATE INDEX IF NOT EXISTS idx_job_checkpoint_job_name ON job_checkpoint(job_name);
