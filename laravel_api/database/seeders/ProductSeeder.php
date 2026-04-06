<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $products = [
            [
                'name' => 'Phone A1',
                'price' => 799,
                'description' => 'Smartphone nhe, pin tot, man hinh sac net.',
                'image_url' => 'https://images.unsplash.com/photo-1510557880182-3b5f8a5a6b6f?w=800',
                'category' => 'Điện thoại',
                'on_sale' => true,
            ],
            [
                'name' => 'Laptop Pro 14',
                'price' => 1499,
                'description' => 'Laptop hieu nang cao, phu hop lam viec va hoc tap.',
                'image_url' => 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
                'category' => 'Laptop',
                'on_sale' => false,
            ],
            [
                'name' => 'Wireless Headphones',
                'price' => 199,
                'description' => 'Tai nghe khong day chong on, nghe hay.',
                'image_url' => 'https://images.unsplash.com/photo-1518444020327-9c4c409e6d4f?w=800',
                'category' => 'Phụ kiện',
                'on_sale' => false,
            ],
            [
                'name' => 'Phone B2',
                'price' => 599,
                'description' => 'Dien thoai tam trung, camera tot.',
                'image_url' => 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=800',
                'category' => 'Điện thoại',
                'on_sale' => false,
            ],
            [
                'name' => 'Gaming Laptop X',
                'price' => 1899,
                'description' => 'May choi game, GPU manh me.',
                'image_url' => 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
                'category' => 'Laptop',
                'on_sale' => true,
            ],
        ];

        foreach ($products as $product) {
            Product::updateOrCreate(
                ['name' => $product['name']],
                $product
            );
        }
    }
}
