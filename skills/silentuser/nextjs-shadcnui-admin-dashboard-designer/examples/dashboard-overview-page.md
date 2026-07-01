# Example: Dashboard Overview Page

Bu örnek, admin dashboard'un ana sayfasının tam implementasyonunu gösterir.

## Input

Kullanıcı: "Admin dashboard'un ana overview sayfasını oluştur. 4 KPI kartı, gelir grafiği ve son satışlar tablosu olsun."

## Agent Output

### Sayfa: Dashboard Overview

#### Layout

```tsx
// app/(dashboard)/dashboard/page.tsx
import { DollarSign, Users, CreditCard, Activity } from "lucide-react"
import { StatCard } from "@/components/stat-card"
import { RevenueChart } from "@/components/revenue-chart"
import { RecentSalesTable } from "@/components/recent-sales-table"

export default function DashboardPage() {
  return (
    <div className="space-y-8">
      {/* Page header */}
      <div className="flex items-center justify-between">
        <div className="space-y-1">
          <h1 className="text-3xl font-semibold tracking-tight">Dashboard</h1>
          <p className="text-sm text-muted-foreground">
            İşletmenizin genel performansını görüntüleyin.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm">Dışa Aktar</Button>
          <Button size="sm">Rapor Oluştur</Button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Toplam Gelir"
          value="$45,231.89"
          description="geçen aya göre"
          icon={DollarSign}
          trend={{ value: "+20.1%", positive: true }}
        />
        <StatCard
          title="Yeni Müşteriler"
          value="+2,350"
          description="geçen aya göre"
          icon={Users}
          trend={{ value: "+180.1%", positive: true }}
        />
        <StatCard
          title="Satışlar"
          value="+12,234"
          description="geçen aya göre"
          icon={CreditCard}
          trend={{ value: "+19%", positive: true }}
        />
        <StatCard
          title="Aktif Şimdi"
          value="+573"
          description="son 1 saatte"
          icon={Activity}
          trend={{ value: "+201", positive: true }}
        />
      </div>

      {/* Charts and Tables */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <RevenueChart />
        <RecentSalesTable />
      </div>
    </div>
  )
}
```

#### Kullanılan Design Token'lar

- `bg-background`, `text-foreground` — sayfa genel
- `text-muted-foreground` — açıklama metinleri
- `bg-sidebar-accent` — aktif sidebar öğesi
- `border-sidebar-border` — sidebar ayırıcı
- `bg-card`, `text-card-foreground` — kartlar
- `bg-primary`, `text-primary-foreground` — birincil butonlar

#### Responsive Davranış

- **Mobil:** KPI kartları tek kolon, grafik ve tablo alt alta
- **Tablet (md):** KPI kartları 2x2 grid, grafik ve tablo yan yana (eşit genişlik)
- **Masaüstü (lg):** KPI kartları 4 kolon, grafik 4/7 genişlik, tablo 3/7 genişlik

#### Dark Mode Notları

- Tüm kartlar `bg-card` token'ını kullanır, dark mode'da otomatik olarak `240 10% 3.9%` değerini alır
- Chart gradient'leri `hsl(var(--chart-1))` ile dark mode'da uyumlu renk kullanır
- Trend göstergeleri `text-green-600` / `text-red-600` — dark mode'da görünürlük için yeterli kontrast sağlanır