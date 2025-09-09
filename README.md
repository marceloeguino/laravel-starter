# Laravel Hello World API

A simple Laravel application that provides a REST API endpoint to return a "Hello World" JSON response.

## Features

- Simple REST API endpoint
- JSON response format
- Laravel 11 framework
- Ready-to-use development server

## Requirements

- PHP >= 8.2
- Composer
- Laravel 11

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd laravel-starter
```

2. Install dependencies:
```bash
composer install
```

3. Copy environment file:
```bash
cp .env.example .env
```

4. Generate application key:
```bash
php artisan key:generate
```

## Usage

### Start the Development Server

```bash
php artisan serve
```

The application will be available at `http://127.0.0.1:8000`

### API Endpoint

**GET** `/api/hello`

Returns a JSON response with a hello world message.

#### Example Request

```bash
curl -X GET http://127.0.0.1:8000/api/hello
```

#### Example Response

```json
{
  "message": "Hello World!",
  "status": "success",
  "timestamp": "2025-01-09T11:48:07.215051Z"
}
```

### Testing with Different Tools

#### Using curl
```bash
curl -X GET http://127.0.0.1:8000/api/hello
```

#### Using wget
```bash
wget -qO- http://127.0.0.1:8000/api/hello
```

#### Using HTTPie
```bash
http GET http://127.0.0.1:8000/api/hello
```

## Project Structure

- `app/Http/Controllers/HelloController.php` - Controller handling the hello endpoint
- `routes/api.php` - API routes definition
- `bootstrap/app.php` - Application bootstrap configuration

## License

This project is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
