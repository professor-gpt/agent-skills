---
name: silentuser/nextjs-shadcnui-admin-dashboard-designer
description: Use this skill when building admin dashboard pages, layouts, or components using Next.js App Router and shadcn/ui, following the design patterns from the next-shadcn-admin-dashboard reference implementation.
category: design
tags: [nextjs, shadcn-ui, admin-dashboard, tailwind-css, ui-design, react]
---

# Skill: Next.js shadcn/ui Admin Dashboard Designer

## Description

Bu skill, Next.js App Router ve shadcn/ui component library kullanarak profesyonel admin dashboard sayfaları ve bileşenleri oluşturmak için tasarlanmıştır. `arhamkhnz/next-shadcn-admin-dashboard` reposundaki tasarım dilini, layout pattern'lerini ve component yapılarını referans alarak tutarlı, erişilebilir ve production-ready UI üretir.

## Instructions

1. **Kullanıcı isteğini analiz et.** Kullanıcı hangi sayfayı, bileşeni veya layout'u oluşturmak istiyor belirle. İstek belirsizse şu soruları sor:
   - Hangi sayfa türü gerekli? (dashboard overview, list page, detail page, settings, form page)
   - Sidebar'da hangi navigasyon öğeleri olmalı?
   - Sayfada hangi veri görselleştirmeleri gerekli? (KPI kartları, tablolar, grafikler)

2. **Design token'ları yükle.** `./references/design-tokens.md` dosyasındaki §1 Color Tokens, §2 Typography ve §3 Spacing bölümlerinden gerekli CSS custom property değerlerini al. Üretilen her JSX çıktısında hardcoded renk değeri (hex, rgb) kullanma — yalnızca `hsl(var(--token-name))` formatını kullan.

3. **Layout iskeletini oluştur.** `./references/component-patterns.md` §1 Layout Structure bölümündeki AppShell pattern'ini uygula:
   - Sol sidebar: 280px genişlik, collapsible (70px icon-only mode)
   - Üst topbar: 64px yükseklik, breadcrumb + kullanıcı menüsü
   - Ana içerik alanı: `max-w-screen-2xl mx-auto p-6` container

4. **Sayfa bileşenlerini yerleştir.** İstenen sayfa türüne göre `./references/component-patterns.md` dosyasındaki ilgili bölümü referans al:
   - KPI kartları için → §2 Stat Cards
   - Veri tabloları için → §3 Data Tables
   - Grafik alanları için → §4 Chart Containers
   - Form sayfaları için → §5 Form Layouts
   - Navigasyon için → §6 Sidebar Navigation

5. **Responsive davranışı uygula.** Her component için `./references/design-tokens.md` §4 Breakpoints bölümündeki breakpoint değerlerini kullan. Sidebar mobilde drawer, tablette overlay, masaüstünde fixed olmalı.

6. **Dark mode uyumluluğunu doğrula.** Üretilen her component'in dark mode'da doğru çalıştığını kontrol et — `./references/design-tokens.md` §1.2 Dark Mode Tokens bölümündeki değerleri referans al. Tüm renklerin `dark:` variant'ı tanımlı olmalı.

7. **Erişilebilirlik kontrollerini uygula:**
   - Tüm interactive elementler `focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring` sınıflarına sahip olmalı
   - Sidebar navigasyon linkleri `aria-current="page"` ile aktif sayfa belirtmeli
   - Tablolar `<caption>` veya `aria-label` ile tanımlanmalı
   - Renk kontrastı WCAG AA standardına uygun olmalı (minimum 4.5:1)

8. **Çıktıyı doğrula ve teslim et.** Üretilen kodu şu kriterlere göre kontrol et:
   - Hardcoded renk değeri yok (tüm renkler CSS custom property)
   - Tüm shadcn/ui component'leri doğru import path'inden (`@/components/ui/...`)
   - Lucide icon'ları `lucide-react` paketinden import ediliyor
   - Responsive breakpoint'ler tanımlı
   - Dark mode token'ları uyumlu

## Constraints

- Yalnızca Next.js App Router (Next.js 14+) ile uyumlu component'ler üret. Pages Router pattern'leri kullanma.
- shadcn/ui component'lerini `@/components/ui/` path'inden import et. Bu component'lerin zaten projede kurulu olduğunu varsay.
- Tailwind CSS v3.4+ sınıf isimlerini kullan. Arbitrary value kullanımını minimize et, mümkünse config'e token ekle.
- Zustand, Jotai veya Redux gibi global state kütüphaneleri kullanma — component-level state ve React Context yeterli.
- Backend entegrasyonu yapma — mock data ve statik içerik kullan. API çağrıları için placeholder comment bırak.
- shadcn/ui'nin varsayılan tema yapısını koru — yeni renkler eklerken mevcut token sistemine (HSL formatında CSS custom property) ekle.
- Admin dashboard context'i dışındaki sayfalar (landing page, marketing page, blog) bu skill'in kapsamı dışındadır.

## Output Format

Her çıktı şu yapıda olmalı:

```
## Sayfa: [Sayfa Adı]

### Layout
[AppShell wrapper kodu]

### Bileşenler
[Her component ayrı code block, import'lar dahil]

### Açıklamalar
- Kullanılan design token'lar
- Responsive davranış notları
- Dark mode notları
```

## Context

`arhamkhnz/next-shadcn-admin-dashboard` reposu şu teknik stack üzerine kurulu:
- **Framework:** Next.js 14+ (App Router, Server Components varsayılan)
- **UI Library:** shadcn/ui (Radix UI primitives + Tailwind CSS)
- **Icons:** Lucide React
- **Charts:** Recharts (veya benzeri)
- **State:** React useState/useReducer (component-level)
- **Styling:** Tailwind CSS + CSS Custom Properties (HSL formatında)
- **Layout Pattern:** Fixed sidebar + sticky topbar + scrollable main content

Sidebar navigation grupları: Dashboard, Analytics, Customers, Products, Settings gibi bölümlerden oluşur. Her grup başlığı `text-xs font-semibold text-muted-foreground uppercase` formatında render edilir.