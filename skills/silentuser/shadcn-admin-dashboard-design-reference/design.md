# Design Reference: next-shadcn-admin-dashboard

This document extracts the concrete design system, tokens, layout rules, and component patterns from the https://github.com/arhamkhnz/next-shadcn-admin-dashboard repository.

## Color System

The dashboard uses shadcn/ui CSS variables with a neutral slate base and blue accent.

```css
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
  --card: 0 0% 100%;
  --card-foreground: 222.2 84% 4.9%;
  --popover: 0 0% 100%;
  --popover-foreground: 222.2 84% 4.9%;
  --primary: 221.2 83.2% 53.3%;        /* #2563eb */
  --primary-foreground: 210 40% 98%;
  --secondary: 210 40% 96.1%;
  --secondary-foreground: 222.2 47.4% 11.2%;
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%;
  --accent: 210 40% 96.1%;
  --accent-foreground: 222.2 47.4% 11.2%;
  --destructive: 0 84.2% 60.2%;
  --destructive-foreground: 210 40% 98%;
  --border: 214.3 31.8% 91.4%;
  --input: 214.3 31.8% 91.4%;
  --ring: 221.2 83.2% 53.3%;
  --radius: 0.5rem;
}

.dark {
  --background: 222.2 84% 4.9%;
  --foreground: 210 40% 98%;
  --card: 222.2 84% 4.9%;
  --card-foreground: 210 40% 98%;
  --primary: 217.2 91.2% 59.8%;
  --primary-foreground: 222.2 47.4% 11.2%;
  --secondary: 217.2 32.6% 17.5%;
  --secondary-foreground: 210 40% 98%;
  --muted: 217.2 32.6% 17.5%;
  --muted-foreground: 215 20.2% 65.1%;
  --accent: 217.2 32.6% 17.5%;
  --accent-foreground: 210 40% 98%;
  --border: 217.2 32.6% 17.5%;
  --input: 217.2 32.6% 17.5%;
  --ring: 224.3 76.3% 48%;
}
```

## Typography

- Font family: Inter (system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif)
- Headings: font-semibold tracking-tight
- Text sizes used:
  - h1: text-3xl font-semibold tracking-tight
  - h2: text-2xl font-semibold tracking-tight
  - h3: text-xl font-semibold tracking-tight
  - body: text-sm
  - small: text-xs text-muted-foreground

## Layout Architecture

- Sidebar: fixed `w-64` (256px), collapsible to `w-16` on mobile with overlay
- Header: `h-14` (56px) sticky top bar with `px-4` padding
- Main content: `flex-1` with `p-4 md:p-6` and max-width container `max-w-7xl`
- Grid gaps: `gap-4` for stat cards, `gap-6` for larger sections
- Card padding: `p-6`
- Border radius: `--radius` (0.5rem) on all cards, buttons, inputs
- Shadows: `shadow-sm` on cards, `shadow-md` on dropdowns/popovers

## Navigation Structure

Sidebar links use:
```tsx
<div className="flex items-center gap-3 rounded-lg px-3 py-2 text-muted-foreground hover:bg-accent hover:text-accent-foreground">
  <Icon className="h-4 w-4" />
  <span className="text-sm font-medium">Label</span>
</div>
```

Active state: `bg-accent text-accent-foreground font-medium`

Top nav includes: search input (`w-64`), notification bell with badge, user avatar dropdown.

## Component Patterns

### Stat Card
```tsx
<Card>
  <CardHeader className="flex flex-row items-center justify-between pb-2">
    <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
    <DollarSign className="h-4 w-4 text-muted-foreground" />
  </CardHeader>
  <CardContent>
    <div className="text-2xl font-bold">$45,231.89</div>
    <p className="text-xs text-muted-foreground">+20.1% from last month</p>
  </CardContent>
</Card>
```

### Data Table
Uses `@tanstack/react-table` with:
- Header: `bg-muted/50 text-xs font-medium uppercase tracking-wider`
- Cells: `px-4 py-3 text-sm`
- Row hover: `hover:bg-muted/50`
- Pagination: `flex items-center justify-between px-4 py-3`

### Chart Container
```tsx
<Card className="col-span-4">
  <CardHeader>
    <CardTitle>Revenue Overview</CardTitle>
  </CardHeader>
  <CardContent className="pl-2">
    <ResponsiveContainer width="100%" height={300}>
      <AreaChart data={data}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip />
        <Area type="monotone" dataKey="revenue" stroke="#2563eb" fill="#3b82f6" fillOpacity={0.2} />
      </AreaChart>
    </ResponsiveContainer>
  </CardContent>
</Card>
```

### Button Variants
- Primary: `bg-primary text-primary-foreground hover:bg-primary/90`
- Secondary: `bg-secondary text-secondary-foreground hover:bg-secondary/80`
- Outline: `border border-input bg-background hover:bg-accent hover:text-accent-foreground`
- Ghost: `hover:bg-accent hover:text-accent-foreground`

All buttons include `focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2`

## Responsive Breakpoints

- Mobile (< 768px): sidebar becomes drawer triggered by hamburger
- Tablet (768px–1024px): sidebar visible, reduced padding
- Desktop (≥ 1024px): full sidebar + 3–4 column stat grids

## Accessibility & States

- All interactive elements have visible focus rings using `--ring`
- Loading states use skeleton `animate-pulse bg-muted`
- Empty states centered with icon + text-muted-foreground
- Badge component: `inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold`

## Dark Mode Overrides

All components automatically inherit dark mode tokens via the `.dark` class on `html` or body. No additional per-component dark styles are required when using the CSS variables above.