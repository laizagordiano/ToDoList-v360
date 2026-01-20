web: bin/rails db:migrate && bin/rails runner 'load Rails.root.join("db/queue_schema.rb")' && bin/rails server -b 0.0.0.0 -p $PORT
queue: bin/rails solid_queue:start
tailwind: bin/rails tailwindcss:watch
