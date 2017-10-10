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
    docker-compose exec elixir mix test
```

## Debugging

```
    docker-compose exec elixir /bin/bash -c "iex -S mix"
    recompile()
```