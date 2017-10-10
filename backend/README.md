# MEMZ Backend

## Setup

On your local machine, in memz/backend/ directory, run:

```
make install
docker-compose up
```

## Tests

To run the tests:

```
docker-compose -f docker-compose.test.yml up
docker-compose exec elixir bin/bash -c "MIX_ENV=test mix test"
```

## Debugging

To start the Elixir shell:

```
docker-compose exec elixir /bin/bash -c "iex -S mix"
```
    
To recompile without exiting, run the following inside the Elixir shell:
    
```
recompile()
```