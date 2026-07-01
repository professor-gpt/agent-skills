# Design Tokens Reference

Bu dosya, shadcn/ui tabanlı admin dashboard için tüm tasarım token'larını içerir. SKILL.md'deki referanslar bu bölümlere yönlendirir.

## §1 Color Tokens

### §1.1 Light Mode Tokens

```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 240 10% 3.9%;

    --card: 0 0% 100%;
    --card-foreground: 240 10% 3.9%;

    --popover: 0 0% 100%;
    --popover-foreground: 240 10% 3.9%;

    --primary: 240 5.9% 10%;
    --primary-foreground: 0 0% 98%;

    --secondary: 240 4.8% 95.9%;
    --secondary-foreground: 240 5.9% 10%;

    --muted: 240 4.8% 95.9%;
    --muted-foreground: 240 3.8% 46.1%;

    --accent: 240 4.8% 95.9%;
    --accent-foreground: 240 5.9% 10%;

    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;

    --border: 240 5.9% 90%;
    --input: 240 5.9% 90%;
    --ring: 240 5.9% 10%;

    --radius: 0.5rem;

    /* Admin dashboard extended tokens */
    --sidebar-background: 0 0% 98%;
    --sidebar-foreground: 240 5.3% 26.1%;
    --sidebar-primary: 240 5.9% 10%;
    --sidebar-primary-foreground: 0 0% 98%;
    --sidebar-accent: 240 4.8% 95.9%;
    --sidebar-accent-foreground: 240 5.9% 10%;
    --sidebar-border: 220 13% 91%;
    --sidebar-ring: 240 5.9% 10%;

    /* Chart colors */
    --chart-1: 12 76% 61%;
    --chart-2: 173 58% 39%;
    --chart-3: 197 37% 24%;
    --chart-4: 43 74% 66%;
    --chart-5: 27 87% 67%;

    /* Status colors */
    --success: 142 71% 45%;
    --success-foreground: 0 0% 100%;
    --warning: 38 92% 50%;
    --warning-foreground: 0 0% 100%;
    --info: 199 89% 48%;
    --info-foreground: 0 0% 100%;
  }
}
```

**Kullanım formatı:** `hsl(var(--token-name))` veya Tailwind config'te tanımlıysa doğrudan class olarak.

```tsx
// Doğru kullanım
<div className="bg-background text-foreground" />
<div className="border-border bg-card text-card-foreground" />
<span className="text-muted-foreground">Açıklama metni</span>

// Yanlış kullanım — hardcoded değer
<div className="bg-white text-gray-900" />
<div style={{ color: '#18181b' }} />
```

### §1.2 Dark Mode Tokens

```css
@layer base {
  .dark {
    --background: 240 10% 3.9%;
    --foreground: 0 0% 98%;

    --card: 240 10% 3.9%;
    --card-foreground: 0 0% 98%;

    --popover: 240 10% 3.9%;
    --popover-foreground: 0 0% 98%;

    --primary: 0 0% 98%;
    --primary-foreground: 240 5.9% 10%;

    --secondary: 240 3.7% 15.9%;
    --secondary-foreground: 0 0% 98%;

    --muted: 240 3.7% 15.9%;
    --muted-foreground: 240 5% 64.9%;

    --accent: 240 3.7% 15.9%;
    --accent-foreground: 0 0% 98%;

    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;

    --border: 240 3.7% 15.9%;
    --input: 240 3.7% 15.9%;
    --ring: 240 4.9% 83.9%;

    /* Admin dashboard extended tokens */
    --sidebar-background: 240 5.9% 10%;
    --sidebar-foreground: 240 4.8% 95.9%;
    --sidebar-primary: 224.3 76.3% 48%;
    --sidebar-primary-foreground: 0 0% 100%;
    --sidebar-accent: 240 3.7% 15.9%;
    --sidebar-accent-foreground: 240 4.8% 95.9%;
    --sidebar-border: 240 3.7% 15.9%;
    --sidebar-ring: 240 4.9% 83.9%;

    /* Chart colors (dark mode adjusted) */
    --chart-1: 220 70% 50%;
    --chart-2: 160 60% 45%;
    --chart-3: 30 80% 55%;
    --chart-4: 280 65% 60%;
    --chart-5: 340 75% 55%;

    /* Status colors */
    --success: 142 71% 45%;
    --success-foreground: 0 0% 100%;
    --warning: 38 92% 50%;
    --warning-foreground: 0 0% 100%;
    --info: 199 89% 48%;
    --info-foreground: 0 0% 100%;
  }
}
```

### §1.3 Semantic Color Mapping

| Semantic Kullanım | Light Token | Dark Token | Tailwind Class |
|---|---|---|---|
| Sayfa arka planı | `--background` | `--background` | `bg-background` |
| Kart arka planı | `--card` | `--card` | `bg-card` |
| Birincil buton | `--primary` | `--primary` | `bg-primary text-primary-foreground` |
| İkincil buton | `--secondary` | `--secondary` | `bg-secondary text-secondary-foreground` |
| Pasif metin | `--muted-foreground` | `--muted-foreground` | `text-muted-foreground` |
| Border/sınır | `--border` | `--border` | `border-border` |
| Hata/silme | `--destructive` | `--destructive` | `bg-destructive text-destructive-foreground` |
| Sidebar arka plan | `--sidebar-background` | `--sidebar-background` | `bg-sidebar-background` |
| Hover durumu | `--accent` | `--accent` | `hover:bg-accent hover:text-accent-foreground` |

## §2 Typography

### §2.1 Font Stack

```css
/* globals.css */
@layer base {
  body {
    font-family: var(--font-sans);
    /* Next.js App Router'da genellikle: */
    /* --font-sans: 'Inter', ui-sans-serif, system-ui, -apple-system, sans-serif; */
  }
}
```

### §2.2 Type Scale

| Kullanım | Tailwind Class | Font Size | Line Height | Weight |
|---|---|---|---|---|
| Sayfa başlığı (H1) | `text-3xl font-semibold tracking-tight` | 30px | 36px | 600 |
| Bölüm başlığı (H2) | `text-2xl font-semibold tracking-tight` | 24px | 32px | 600 |
| Alt başlık (H3) | `text-xl font-semibold` | 20px | 28px | 600 |
| Kart başlığı | `text-lg font-semibold` | 18px | 28px | 600 |
| Body metin | `text-base` | 16px | 24px | 400 |
| Küçük metin | `text-sm` | 14px | 20px | 400 |
| Caption/etiket | `text-xs` | 12px | 16px | 400 |
| Sidebar group label | `text-xs font-semibold uppercase tracking-wider` | 12px | 16px | 600 |
| KPI değer | `text-3xl font-bold tabular-nums` | 30px | 36px | 700 |
| Tablo başlık hücresi | `text-xs font-medium text-muted-foreground uppercase` | 12px | 16px | 500 |

### §2.3 Typography Patterns

```tsx
// Sayfa başlığı + açıklama pattern
<div className="space-y-1">
  <h1 className="text-3xl font-semibold tracking-tight">
    Dashboard
  </h1>
  <p className="text-sm text-muted-foreground">
    Genel performans metriklerini ve son aktiviteleri görüntüleyin.
  </p>
</div>

// KPI kartı tipografi
<Card>
  <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
    <CardTitle className="text-sm font-medium">
      Toplam Gelir
    </CardTitle>
    <DollarSign className="h-4 w-4 text-muted-foreground" />
  </CardHeader>
  <CardContent>
    <div className="text-2xl font-bold">$45,231.89</div>
    <p className="text-xs text-muted-foreground">
      +20.1% geçen aya göre
    </p>
  </CardContent>
</Card>
```

## §3 Spacing

### §3.1 Layout Spacing

| Kullanım | Değer | Tailwind |
|---|---|---|
| Sayfa padding | 24px | `p-6` |
| Kart iç padding | 24px | `p-6` |
| Kartlar arası gap | 16px | `gap-4` |
| Section'lar arası gap | 32px | `gap-8` |
| Grid column gap | 16px | `gap-4` |
| Sidebar item padding | 8px 12px | `px-3 py-2` |
| Topbar yükseklik | 64px | `h-16` |
| Sidebar genişlik (expanded) | 280px | `w-[280px]` |
| Sidebar genişlik (collapsed) | 70px | `w-[70px]` |

### §3.2 Component Internal Spacing

```tsx
// Card internal structure
<Card className="p-6">
  <CardHeader className="pb-2">
    <CardTitle>Başlık</CardTitle>
    <CardDescription>Açıklama</CardDescription>
  </CardHeader>
  <CardContent className="space-y-4">
    {/* İçerik */}
  </CardContent>
  <CardFooter className="pt-4">
    {/* Aksiyonlar */}
  </CardFooter>
</Card>

// Sayfa header + content spacing
<div className="flex flex-1 flex-col space-y-8">
  {/* Header */}
  <div className="flex items-center justify-between">
    <div className="space-y-1">
      <h1 className="text-3xl font-semibold tracking-tight">Sayfa</h1>
      <p className="text-sm text-muted-foreground">Açıklama</p>
    </div>
    <div className="flex items-center gap-2">
      {/* Aksiyonlar */}
    </div>
  </div>

  {/* Content grid */}
  <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    {/* Kartlar */}
  </div>
</div>
```

## §4 Breakpoints

| Breakpoint | Genişlik | Davranış |
|---|---|---|
| Mobile (default) | < 640px | Sidebar drawer, tek kolon, topbar hamburger menü |
| `sm:` | ≥ 640px | Sidebar drawer, 2 kolon grid |
| `md:` | ≥ 768px | Sidebar overlay, 2-3 kolon grid |
| `lg:` | ≥ 1024px | Sidebar fixed, 3-4 kolon grid |
| `xl:` | ≥ 1280px | Sidebar fixed, tam grid, geniş içerik alanı |
| `2xl:` | ≥ 1536px | max-w-screen-2xl container centered |

### §4.1 Responsive Grid Patterns

```tsx
// KPI kartları grid
<div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
  <StatCard />
  <StatCard />
  <StatCard />
  <StatCard />
</div>

// Dashboard 2-kolon layout (chart + table)
<div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
  <Card className="col-span-4">
    {/* Ana grafik */}
  </Card>
  <Card className="col-span-3">
    {/* Son işlemler tablosu */}
  </Card>
</div>
```

### §4.2 Sidebar Responsive Behavior

```tsx
// Mobile: Sheet/Drawer
<Sheet>
  <SheetTrigger asChild>
    <Button variant="outline" size="icon" className="md:hidden">
      <Menu className="h-5 w-5" />
    </Button>
  </SheetTrigger>
  <SheetContent side="left" className="w-[280px] p-0">
    <SidebarContent />
  </SheetContent>
</Sheet>

// Desktop: Fixed sidebar
<aside className="hidden md:flex md:w-[280px] md:flex-col md:fixed md:inset-y-0">
  <SidebarContent />
</aside>

// Main content offset
<main className="md:pl-[280px]">
  {/* İçerik */}
</main>
```

## §5 Border & Shadow Tokens

### §5.1 Border Radius

```css
/* Tüm component'ler --radius token'ını kullanır */
--radius: 0.5rem; /* 8px */

/* shadcn/ui variant'ları */
rounded-sm:  calc(var(--radius) - 4px);  /* 4px */
rounded-md:  calc(var(--radius) - 2px);  /* 6px */
rounded-lg:  var(--radius);               /* 8px */
rounded-xl:  calc(var(--radius) + 4px);  /* 12px */
```

### §5.2 Shadow Patterns

```tsx
// Kart shadow (subtle)
<Card className="shadow-sm">

// Dropdown/Popover shadow
<PopoverContent className="shadow-md">

// Dialog/Modal shadow
<DialogContent className="shadow-lg">

// Sidebar (border-right, no shadow)
<aside className="border-r border-sidebar-border">
```