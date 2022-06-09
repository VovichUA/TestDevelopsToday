#-----------------------------------------------------------
# Docker
#-----------------------------------------------------------

# Only first start application!!!
bootstrap:
	# run api
	cp ./app/.env.example ./app/.env
	cp docker-compose.override.example.yml docker-compose.override.yml
	make build
	make composer-install

	make chmod-permissions
	make artisan cmd="config:clear"
	make artisan cmd="key:generate"
	make artisan cmd="migrate"
	make artisan cmd="migrate:refresh --seed"
	make artisan cmd="passport:install"

# Build and up docker containers
build:
	docker-compose up -d --build

# Build and up docker containers
rebuild:
	make stop
	make build

# Wake up docker containers
start:
	docker-compose up -d
	make composer-install
	make migrate
	make npm cmd="install --no-save"
	make npm cmd="run build"
#	make npm cmd="run dev"

# Shut down docker containers
stop:
	docker-compose down

# Show a status of each container
status:
	docker-compose ps

# Show logs of each container
logs:
	docker-compose logs

# Restart all containers
restart:
	make stop
	make start

# Restart the client container
restart-client:
	docker-compose restart client

# Show the client logs
logs-client:
	docker-compose logs client

# Build containers with no cache option
build-no-cache:
	docker-compose build --no-cache

# Run terminal of the php container
exec-php:
	docker-compose exec -T app /bin/sh

# Run terminal of the client container
exec-client:
	docker-compose exec -T client /bin/sh

chmod-permissions:
	docker-compose exec -T app chmod 777 -R storage/
	docker-compose exec -T app chmod 777 -R bootstrap/cache

composer:
    ifneq ($(cmd),)
	    docker-compose exec -T app /bin/sh -c "composer $(cmd)"
    else
	    docker-compose exec -T app /bin/sh -c "composer"
    endif

artisan:
    ifneq ($(cmd),)
		docker-compose exec -T app php artisan $(cmd)
    else
		docker-compose exec -T app php artisan
    endif

npm:
    ifneq ($(cmd),)
		docker-compose exec client sh -c "npm $(cmd)"
    else
		docker-compose exec client sh -c "npm"
    endif

code-style-fix:
	make artisan cmd="fixer:fix --diff"

code-style-check:
	make artisan cmd="fixer:fix  --verbose --show-progress=dots --dry-run"

#-----------------------------------------------------------
# Logs
#-----------------------------------------------------------

# Clear file-based logs
logs-clear:
	sudo rm docker/nginx/logs/*.log
	sudo rm develops_today/storage/logs/*.log


#-----------------------------------------------------------
# Database
#-----------------------------------------------------------

# Run database migrations
migrate:
	docker-compose exec app php artisan migrate

# Run migrations rollback
db-rollback:
	docker-compose exec app php artisan migrate:rollback

# Rollback alias
rollback: db-rollback

# Run seeders
db-seed:
	docker-compose exec app php artisan db:seed

# Fresh all migrations
db-fresh:
	docker-compose exec app php artisan migrate:fresh

# Dump database into file
db-dump:
	docker-compose exec postgres pg_dump -U app -d app > docker/postgres/dumps/dump.sql


#-----------------------------------------------------------
# Redis
#-----------------------------------------------------------

redis:
	docker-compose exec redis redis-cli

redis-flush:
	docker-compose exec redis redis-cli FLUSHALL

redis-install:
	docker-compose exec app composer require predis/predis


#-----------------------------------------------------------
# Queue
#-----------------------------------------------------------

# Restart queue process
queue-restart:
	docker-compose exec app php artisan queue:restart


#-----------------------------------------------------------
# Testing
#-----------------------------------------------------------

# Run phpunit tests
test:
	docker-compose exec app vendor/bin/phpunit --order-by=defects --stop-on-defect

# Run all tests ignoring failures.
test-all:
	docker-compose exec app vendor/bin/phpunit --order-by=defects

# Run phpunit tests with coverage
coverage:
	docker-compose exec app vendor/bin/phpunit --coverage-html tests/report

# Run phpunit tests
dusk:
	docker-compose exec app php artisan dusk

# Generate metrics
metrics:
	docker-compose exec app vendor/bin/phpmetrics --report-html=app/tests/metrics app/app


#-----------------------------------------------------------
# Dependencies
#-----------------------------------------------------------

# Install composer dependencies
composer-install:
	docker-compose exec app composer install

# Update composer dependencies
composer-update:
	docker-compose exec app composer update

# Update yarn dependencies
npm-update:
	docker-compose exec client npm update

npm-install:
	docker-compose exec client npm install --no-save

npm-dev:
	docker-compose exec client npm run dev

npm-watch:
	docker-compose exec client npm run watch

npm-prod:
	docker-compose exec client npm run production

# Update all dependencies
dependencies-update: composer-update npm-update

# Show composer outdated dependencies
composer-outdated:
	docker-compose exec app outdated

# Show npm outdated dependencies
npm-outdated:
	docker-compose exec client outdated

# Show all outdated dependencies
outdated: npm-update composer-outdated

