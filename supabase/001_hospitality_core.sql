create extension if not exists pgcrypto;

-- =========================================================
-- FSLBS HOSPITALITY - NÚCLEO OPERACIONAL
-- Não altera as tabelas existentes da E-comanda.
-- =========================================================

create table if not exists public.fslbs_grupos (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  responsavel_nome text,
  responsavel_contato text,
  tipo text not null default 'grupo_hospedes',
  observacoes text,
  ativo boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_grupo_membros (
  id uuid primary key default gen_random_uuid(),
  grupo_id uuid not null references public.fslbs_grupos(id) on delete cascade,
  hospede_id uuid not null references public.hospedes(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(grupo_id, hospede_id)
);

create table if not exists public.fslbs_reservas (
  id uuid primary key default gen_random_uuid(),
  hospede_titular_id uuid references public.hospedes(id),
  grupo_id uuid references public.fslbs_grupos(id),
  data_entrada date not null,
  data_saida date not null,
  quantidade_hospedes integer not null default 1,
  origem text,
  canal text,
  status text not null default 'solicitada',
  observacoes text,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_experiencias (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  categoria text,
  descricao text,
  duracao_minutos integer,
  capacidade integer,
  preco numeric(12,2),
  exige_agendamento boolean not null default true,
  ativo boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_agendamentos_experiencias (
  id uuid primary key default gen_random_uuid(),
  experiencia_id uuid not null references public.fslbs_experiencias(id),
  hospedagem_id uuid references public.hospedagens(id),
  hospede_id uuid references public.hospedes(id),
  grupo_id uuid references public.fslbs_grupos(id),
  inicio timestamptz not null,
  quantidade_pessoas integer not null default 1,
  status text not null default 'solicitado',
  observacoes text,
  criado_por uuid references public.perfis(id),
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_notificacoes (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid references public.perfis(id),
  hospedagem_id uuid references public.hospedagens(id),
  tipo text not null,
  titulo text not null,
  mensagem text not null,
  referencia_tipo text,
  referencia_id uuid,
  lida_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_solicitacoes (
  id uuid primary key default gen_random_uuid(),
  hospedagem_id uuid references public.hospedagens(id),
  hospede_id uuid references public.hospedes(id),
  grupo_id uuid references public.fslbs_grupos(id),
  categoria text not null,
  assunto text not null,
  descricao text,
  prioridade text not null default 'normal',
  status text not null default 'aberta',
  responsavel_id uuid references public.perfis(id),
  resolvido_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_manutencoes (
  id uuid primary key default gen_random_uuid(),
  quarto_id uuid references public.quartos(id),
  hospedagem_id uuid references public.hospedagens(id),
  solicitacao_id uuid references public.fslbs_solicitacoes(id),
  local text,
  descricao text not null,
  prioridade text not null default 'normal',
  status text not null default 'aberta',
  responsavel_id uuid references public.perfis(id),
  inicio_at timestamptz,
  concluida_at timestamptz,
  observacoes text,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_portaria (
  id uuid primary key default gen_random_uuid(),
  hospedagem_id uuid references public.hospedagens(id),
  hospede_id uuid references public.hospedes(id),
  tipo text not null,
  autorizado boolean not null default false,
  autorizado_por uuid references public.perfis(id),
  observacoes text,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_empresas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cnpj text,
  contato_nome text,
  contato_email text,
  contato_telefone text,
  observacoes text,
  ativo boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_eventos_corporativos (
  id uuid primary key default gen_random_uuid(),
  empresa_id uuid not null references public.fslbs_empresas(id),
  responsavel_nome text,
  nome_evento text not null,
  data_inicio date not null,
  data_fim date not null,
  participantes integer not null default 1,
  status text not null default 'solicitado',
  observacoes text,
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_projetos_escolares (
  id uuid primary key default gen_random_uuid(),
  escola_nome text not null,
  tipo text not null default 'projeto_pedagogico',
  responsavel_nome text,
  contato text,
  data_inicio date,
  data_fim date,
  alunos integer not null default 0,
  professores integer not null default 0,
  motoristas integer not null default 0,
  enfermeiros integer not null default 0,
  observacoes text,
  status text not null default 'planejamento',
  created_at timestamptz not null default now()
);

create table if not exists public.fslbs_relatorios_solicitacoes (
  id uuid primary key default gen_random_uuid(),
  solicitado_por uuid references public.perfis(id),
  tipo_relatorio text not null,
  periodo_inicio date,
  periodo_fim date,
  filtros jsonb not null default '{}'::jsonb,
  status text not null default 'solicitado',
  autorizado_por uuid references public.perfis(id),
  autorizado_at timestamptz,
  observacoes text,
  created_at timestamptz not null default now()
);

-- =========================================================
-- ÍNDICES
-- =========================================================

create index if not exists idx_fslbs_grupo_membros_grupo
  on public.fslbs_grupo_membros(grupo_id);

create index if not exists idx_fslbs_grupo_membros_hospede
  on public.fslbs_grupo_membros(hospede_id);

create index if not exists idx_fslbs_reservas_datas
  on public.fslbs_reservas(data_entrada, data_saida);

create index if not exists idx_fslbs_agendamentos_inicio
  on public.fslbs_agendamentos_experiencias(inicio);

create index if not exists idx_fslbs_agendamentos_hospedagem
  on public.fslbs_agendamentos_experiencias(hospedagem_id);

create index if not exists idx_fslbs_notificacoes_perfil
  on public.fslbs_notificacoes(perfil_id, lida_at);

create index if not exists idx_fslbs_solicitacoes_status
  on public.fslbs_solicitacoes(status);

create index if not exists idx_fslbs_manutencoes_status
  on public.fslbs_manutencoes(status);

create index if not exists idx_fslbs_portaria_hospedagem
  on public.fslbs_portaria(hospedagem_id);

create index if not exists idx_fslbs_relatorios_status
  on public.fslbs_relatorios_solicitacoes(status);

-- =========================================================
-- EXPERIÊNCIAS INICIAIS
-- =========================================================

insert into public.fslbs_experiencias
  (nome, categoria, descricao, exige_agendamento)
select 'Cavalgada', 'Experiência', 'Passeio a cavalo acompanhado pela equipe.', true
where not exists (
  select 1 from public.fslbs_experiencias where lower(nome) = 'cavalgada'
);

insert into public.fslbs_experiencias
  (nome, categoria, descricao, exige_agendamento)
select 'Trilha Mata d''Água', 'Experiência', 'Trilha acompanhada por recreador.', true
where not exists (
  select 1 from public.fslbs_experiencias where lower(nome) = 'trilha mata d''água'
);

insert into public.fslbs_experiencias
  (nome, categoria, descricao, exige_agendamento)
select 'Massagem', 'Bem-estar', 'Experiência de relaxamento mediante agendamento.', true
where not exists (
  select 1 from public.fslbs_experiencias where lower(nome) = 'massagem'
);

-- =========================================================
-- SEGURANÇA: RLS
-- As novas tabelas ficam fechadas até as políticas de acesso
-- serem definidas para cada perfil do sistema.
-- =========================================================

alter table public.fslbs_grupos enable row level security;
alter table public.fslbs_grupo_membros enable row level security;
alter table public.fslbs_reservas enable row level security;
alter table public.fslbs_experiencias enable row level security;
alter table public.fslbs_agendamentos_experiencias enable row level security;
alter table public.fslbs_notificacoes enable row level security;
alter table public.fslbs_solicitacoes enable row level security;
alter table public.fslbs_manutencoes enable row level security;
alter table public.fslbs_portaria enable row level security;
alter table public.fslbs_empresas enable row level security;
alter table public.fslbs_eventos_corporativos enable row level security;
alter table public.fslbs_projetos_escolares enable row level security;
alter table public.fslbs_relatorios_solicitacoes enable row level security;

-- FIM
