# Laravel API

API backend example for the Flutter app.

## Setup

1. Create a Laravel project inside this folder or copy these files into your Laravel project.
2. Set MySQL credentials in `.env`.
3. Run:

```bash
php artisan migrate
php artisan db:seed
php artisan serve
```

If you want to import sample products with raw SQL, run:

```bash
mysql -u root -p my_app_db < seed_products.sql
```

## API

- `GET /api/products`
- `POST /api/products`
- `PUT /api/products/{product}`
- `DELETE /api/products/{product}`

## Flutter base URL

Use `http://127.0.0.1:8000/api` for web/desktop.
Use `http://10.0.2.2:8000/api` for Android emulator.
