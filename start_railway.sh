#!/bin/bash

# Define ambiente de produção
export RAILS_ENV=production

# Roda migrations e prepara banco
bin/rails db:prepare

# Inicia servidor
bin/rails server -b 0.0.0.0 -p $PORT
