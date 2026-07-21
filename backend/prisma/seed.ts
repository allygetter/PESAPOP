import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('Seeding PESAPOP database...');

  const business = await prisma.business.upsert({
    where: { phone: '+254712000001' },
    update: {},
    create: { name: 'Kamau General Store', phone: '+254712000001', email: 'demo@pesapop.africa' },
  });

  const branch = await prisma.branch.upsert({
    where: { id: 'branch-main' },
    update: {},
    create: { id: 'branch-main', businessId: business.id, name: 'Main Branch', isDefault: true },
  });

  await prisma.user.upsert({
    where: { phone: '+254712000001' },
    update: {},
    create: {
      businessId: business.id, branchId: branch.id,
      name: 'John Kamau', phone: '+254712000001',
      email: 'demo@pesapop.africa', role: 'OWNER',
    },
  });

  // Seed categories
  const categories = ['Beverages', 'Groceries', 'Cleaning', 'Personal Care', 'Snacks'];
  const catMap: Record<string, string> = {};
  for (const name of categories) {
    const cat = await prisma.category.upsert({
      where: { businessId_name: { businessId: business.id, name } },
      update: {}, create: { businessId: business.id, name },
    });
    catMap[name] = cat.id;
  }

  // Seed products
  const products = [
    { name: 'Tusker Lager 500ml', price: 180, costPrice: 140, category: 'Beverages', sku: 'BEV-001', barcode: '6001234000001', unit: 'bottle', stockQty: 48 },
    { name: 'Coca-Cola 500ml', price: 80, costPrice: 60, category: 'Beverages', sku: 'BEV-002', unit: 'bottle', stockQty: 120 },
    { name: 'Dairyland Milk 500ml', price: 70, costPrice: 55, category: 'Beverages', sku: 'BEV-003', unit: 'packet', stockQty: 35 },
    { name: 'Mineral Water 1L', price: 60, costPrice: 40, category: 'Beverages', sku: 'BEV-004', unit: 'bottle', stockQty: 200 },
    { name: 'Unga Pembe 2kg', price: 240, costPrice: 190, category: 'Groceries', sku: 'GRO-001', unit: 'bag', stockQty: 30 },
    { name: 'Sugar 1kg', price: 160, costPrice: 130, category: 'Groceries', sku: 'GRO-002', unit: 'kg', stockQty: 55 },
    { name: 'Cooking Oil 1L', price: 350, costPrice: 290, category: 'Groceries', sku: 'GRO-003', unit: 'bottle', stockQty: 18 },
    { name: 'Rice 1kg', price: 180, costPrice: 145, category: 'Groceries', sku: 'GRO-004', unit: 'kg', stockQty: 42 },
    { name: 'Omo Detergent 1kg', price: 320, costPrice: 250, category: 'Cleaning', sku: 'CLN-001', stockQty: 12 },
    { name: 'Sunlight Bar Soap', price: 55, costPrice: 40, category: 'Cleaning', sku: 'CLN-002', unit: 'bar', stockQty: 65 },
    { name: 'Bleach 1L', price: 140, costPrice: 100, category: 'Cleaning', sku: 'CLN-003', unit: 'bottle', stockQty: 4 },
    { name: 'Colgate Toothpaste', price: 130, costPrice: 100, category: 'Personal Care', sku: 'PRC-001', stockQty: 24 },
    { name: 'Paracetamol 24s', price: 60, costPrice: 40, category: 'Personal Care', sku: 'PRC-002', isVatExempt: true, stockQty: 50 },
    { name: 'Lays Crisps 100g', price: 70, costPrice: 50, category: 'Snacks', sku: 'SNK-001', stockQty: 90 },
    { name: 'Groundnuts 200g', price: 45, costPrice: 30, category: 'Snacks', sku: 'SNK-002', unit: 'bag', stockQty: 3 },
  ];

  for (const p of products) {
    const { stockQty, category, ...data } = p;
    const product = await prisma.product.upsert({
      where: { businessId_sku: { businessId: business.id, sku: data.sku } },
      update: {},
      create: { ...data, businessId: business.id, categoryId: catMap[category], reorderLevel: 5 },
    });
    await prisma.stockItem.upsert({
      where: { productId_branchId: { productId: product.id, branchId: branch.id } },
      update: {},
      create: { productId: product.id, branchId: branch.id, qty: stockQty },
    });
  }

  console.log('✅ Seed complete!');
  console.log(`Business: ${business.name}`);
  console.log(`Demo phone: +254712000001 (use any 6-digit OTP in dev)`);
}

main().catch(console.error).finally(() => prisma.$disconnect());
