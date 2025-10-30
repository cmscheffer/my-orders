# Puma configuration file for Rails 7.1
# https://github.com/puma/puma

# Configuração de threads
# O número de threads determina quantas requisições simultâneas cada worker pode processar
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Configuração de workers (processos)
# Em produção (Heroku), múltiplos workers melhoram a performance
# Em desenvolvimento, 1 worker é suficiente
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Porta onde o servidor vai escutar
port ENV.fetch("PORT") { 3000 }

# Ambiente (development, production, etc)
environment ENV.fetch("RAILS_ENV") { "development" }

# Configuração específica para produção
if ENV.fetch("RAILS_ENV", "development") == "production"
  # Número de workers baseado na variável WEB_CONCURRENCY do Heroku
  # Heroku recomenda: (RAM disponível - 512MB) / RAM por worker
  # Para dyno standard-1x (512MB): 2 workers
  # Para dyno standard-2x (1GB): 4 workers
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }

  # Pré-carregar a aplicação antes de criar os workers
  # Isso economiza memória através de Copy-on-Write (CoW)
  preload_app!

  # Configuração para reabrir conexões após fazer fork
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end

  # Permitir que os workers sejam reiniciados se usarem muita memória
  before_fork do
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  end
end

# Permite que o Puma seja reiniciado via comando `bin/rails restart`
plugin :tmp_restart

# Log para stdout (necessário para Heroku)
# Os logs serão capturados pelo Heroku Logplex
stdout_redirect('log/puma.stdout.log', 'log/puma.stderr.log', true) if ENV.fetch("RAILS_ENV", "development") == "production"
