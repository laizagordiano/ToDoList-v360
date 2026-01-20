# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Instala dependências básicas
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
    BUNDLE_WITHOUT="development" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# ----------------------
# Camada de Build
# ----------------------
FROM base AS build

# Instala gems necessárias
COPY Gemfile Gemfile.lock ./
COPY vendor/* ./vendor/
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile -j 1 --gemfile

# Copia código e pré-compila bootsnap + assets
COPY . .
RUN bundle exec bootsnap precompile -j 1 app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

# ----------------------
# Camada final (runtime)
# ----------------------
FROM base

# Cria usuário rails e seta home
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails

# Copia gems e app do build, já atribuindo ao usuário rails
COPY --chown=rails:rails --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=rails:rails --from=build /rails /rails

# Garante permissões de execução dos scripts
RUN chmod +x /rails/bin/docker-entrypoint /rails/bin/thrust /rails/bin/rails

# Define usuário não-root
USER rails:rails
WORKDIR /rails

# Entrypoint e comando padrão
ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["./bin/thrust", "./bin/rails", "server"]

EXPOSE 80
