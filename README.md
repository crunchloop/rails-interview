# rails-interview / TodoApi

[![Open in Coder](https://dev.crunchloop.io/open-in-coder.svg)](https://dev.crunchloop.io/templates/fly-containers/workspace?param.Git%20Repository=git@github.com:crunchloop/rails-interview.git)

This is a simple Todo List API built in Ruby on Rails 7. This project is currently being used for Ruby full-stack candidates.

## Build

To build the application:

`bin/setup`

## Run the API

To run the TodoApi in your local environment:

`bin/puma`

## Filtering and Pagination

Both index endpoints support filtering via [Ransack](https://github.com/activerecord-hackery/ransack) and pagination via [Kaminari](https://github.com/kaminari/kaminari).

### Query params

| Param | Example | Description |
|---|---|---|
| `q[field_predicate]` | `?q[name_cont]=shop` | Ransack filter |
| `page` | `?page=2` | Page number (default: 1) |
| `per_page` | `?per_page=5` | Items per page (default: 10) |

### Response format

```json
{
  "todo_lists": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 25,
    "per_page": 10
  }
}
```

### TodoLists filter examples

```
GET /api/todolists?q[name_cont]=shopping
GET /api/todolists?page=2&per_page=5
```

### TodoItems filter examples

```
GET /api/todolists/:id/items?q[title_cont]=buy
GET /api/todolists/:id/items?q[state_eq]=Done
GET /api/todolists/:id/items?q[start_date_gteq]=2026-01-01
GET /api/todolists/:id/items?q[end_date_lteq]=2026-12-31
GET /api/todolists/:id/items?page=1&per_page=5
```

## Test

To run tests:

`bin/rspec`

Check integration tests at: (https://github.com/crunchloop/interview-tests)

## Contact

- Santiago Doldán (sdoldan@crunchloop.io)

## About Crunchloop

![crunchloop](https://s3.amazonaws.com/crunchloop.io/logo-blue.png)

We strongly believe in giving back :rocket:. Let's work together [`Get in touch`](https://crunchloop.io/#contact).
