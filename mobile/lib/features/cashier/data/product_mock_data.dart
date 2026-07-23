// lib/features/cashier/data/product_mock_data.dart
// PESAPOP AI — Mock product catalog for development
// Replace with API calls in production

import '../domain/cashier_models.dart';

final kMockProducts = <PPProduct>[
  // ── Beverages ──────────────────────────────────────────────
  const PPProduct(id: 'p001', name: 'Tusker Lager 500ml', price: 180, category: 'Beverages', stockQty: 48, barcode: '6001234000001', unit: 'bottle'),
  const PPProduct(id: 'p002', name: 'Coca-Cola 500ml', price: 80, category: 'Beverages', stockQty: 120, barcode: '6001234000002', unit: 'bottle'),
  const PPProduct(id: 'p003', name: 'Mineral Water 1L', price: 60, category: 'Beverages', stockQty: 200, barcode: '6001234000003', unit: 'bottle'),
  const PPProduct(id: 'p004', name: 'Dairyland Milk 500ml', price: 70, category: 'Beverages', stockQty: 35, barcode: '6001234000004', unit: 'packet'),
  const PPProduct(id: 'p005', name: 'Chai Bora Tea 100g', price: 120, category: 'Beverages', stockQty: 22, barcode: '6001234000005'),
  const PPProduct(id: 'p006', name: 'Nescafe 3-in-1 x10', price: 150, category: 'Beverages', stockQty: 40),

  // ── Groceries ──────────────────────────────────────────────
  const PPProduct(id: 'p007', name: 'Unga Pembe 2kg', price: 240, category: 'Groceries', stockQty: 30, barcode: '6001234000007', unit: 'bag'),
  const PPProduct(id: 'p008', name: 'Sugar 1kg', price: 160, category: 'Groceries', stockQty: 55, unit: 'kg'),
  const PPProduct(id: 'p009', name: 'Cooking Oil 1L', price: 350, category: 'Groceries', stockQty: 18, unit: 'bottle'),
  const PPProduct(id: 'p010', name: 'Rice 1kg', price: 180, category: 'Groceries', stockQty: 42, unit: 'kg'),
  const PPProduct(id: 'p011', name: 'Pasta 500g', price: 90, category: 'Groceries', stockQty: 65),
  const PPProduct(id: 'p012', name: 'Bread (Large)', price: 75, category: 'Groceries', stockQty: 8, unit: 'loaf'),

  // ── Cleaning ───────────────────────────────────────────────
  const PPProduct(id: 'p013', name: 'Omo Detergent 1kg', price: 320, category: 'Cleaning', stockQty: 12, isVatExempt: false),
  const PPProduct(id: 'p014', name: 'Sunlight Bar Soap', price: 55, category: 'Cleaning', stockQty: 65, unit: 'bar'),
  const PPProduct(id: 'p015', name: 'Toilet Paper x4', price: 120, category: 'Cleaning', stockQty: 38),
  const PPProduct(id: 'p016', name: 'Bleach 1L', price: 140, category: 'Cleaning', stockQty: 4, unit: 'bottle'),

  // ── Personal Care ──────────────────────────────────────────
  const PPProduct(id: 'p017', name: 'Colgate Toothpaste', price: 130, category: 'Personal Care', stockQty: 24),
  const PPProduct(id: 'p018', name: 'Dettol Soap 120g', price: 95, category: 'Personal Care', stockQty: 40, unit: 'bar'),
  const PPProduct(id: 'p019', name: 'Vaseline 100ml', price: 160, category: 'Personal Care', stockQty: 15),
  const PPProduct(id: 'p020', name: 'Paracetamol 24s', price: 60, category: 'Personal Care', stockQty: 50, isVatExempt: true),

  // ── Snacks ─────────────────────────────────────────────────
  const PPProduct(id: 'p021', name: 'Lays Crisps 100g', price: 70, category: 'Snacks', stockQty: 90),
  const PPProduct(id: 'p022', name: 'Biscuits Assorted', price: 50, category: 'Snacks', stockQty: 110),
  const PPProduct(id: 'p023', name: 'Chocolate Bar', price: 65, category: 'Snacks', stockQty: 55),
  const PPProduct(id: 'p024', name: 'Groundnuts 200g', price: 45, category: 'Snacks', stockQty: 3),
];

final kProductCategories = [
  'All',
  'Beverages',
  'Groceries',
  'Cleaning',
  'Personal Care',
  'Snacks',
];
