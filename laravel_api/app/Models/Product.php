<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'price',
        'description',
        'image_url',
        'category',
        'on_sale',
    ];

    protected $casts = [
        'price' => 'float',
        'on_sale' => 'boolean',
    ];
}
