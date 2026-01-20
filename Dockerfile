# syntax=docker/dockerfile:1

# ---- Base image ----
ARG RUBY_VERSION=3.3.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Pacotes básicos + PostgreSQL client
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libjemalloc2 \
      libvips \
      postgresql-client \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# ---- Build stage ----
FROM base AS build

COPY Gemfile Gemfile.lock ./
COPY vendor/* ./vendor/

RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

# Copia o código da aplicação
COPY . .

# Garante que todos os binários Rails são executáveis
RUN chmod +x bin/*

# Pré-compila assets (dummy secret key para não precisar de RAILS_MASTER_KEY na build)
RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

# ---- Final stage ----
FROM base

# Cria usuário não-root para rodar a aplicação
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails
USER 1000:1000

# Copia gems e app do build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Garante permissão de execução para os binários
RUN chmod +x bin/*

# Expõe porta padrão Rails
EXPOSE 3000

# Comando de start: prepara DB e roda server
CMD ["sh", "-c", "bin/rails db:prepare && bin/rails server -b 0.0.0.0 -p 3000"]
