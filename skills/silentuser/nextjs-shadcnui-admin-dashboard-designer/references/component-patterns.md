# Admin Dashboard Component Patterns

Bu dosya, admin dashboard'da kullanılan temel component pattern'lerini gerçek JSX/Tailwind koduyla içerir.

## §1 Layout Structure

### §1.1 AppShell (Root Layout)

```tsx
// app/(dashboard)/layout.tsx
import { SidebarProvider } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"
import { TopNav } from "@/components/top-nav"

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <SidebarProvider>
      <div className="flex min-h-screen">
        <AppSidebar />
        <div className="flex flex-1 flex-col">
          <TopNav />
          <main className="flex-1 overflow-y-auto bg-background p-6">
            <div className="mx-auto max-w-screen-2xl">
              {children}
            </div>
          </main>
        </div>
      </div>
    </SidebarProvider>
  )
}
```

### §1.2 TopNav (Header Bar)

```tsx
// components/top-nav.tsx
import { Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbPage, BreadcrumbSeparator } from "@/components/ui/breadcrumb"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Menu, Search, Bell, User } from "lucide-react"

export function TopNav() {
  return (
    <header className="sticky top-0 z-30 flex h-16 items-center gap-4 border-b bg-background px-6">
      {/* Mobile menu trigger */}
      <Sheet>
        <SheetTrigger asChild>
          <Button variant="outline" size="icon" className="md:hidden">
            <Menu className="h-5 w-5" />
            <span className="sr-only">Menüyü aç</span>
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="w-[280px] p-0">
          {/* Mobile sidebar içeriği */}
        </SheetContent>
      </Sheet>

      {/* Breadcrumb */}
      <Breadcrumb className="hidden md:flex">
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbLink href="/dashboard">Dashboard</BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbPage>Analitik</BreadcrumbPage>
          </BreadcrumbItem>
        </BreadcrumbList>
      </Breadcrumb>

      {/* Search */}
      <div className="ml-auto flex items-center gap-2">
        <div className="relative hidden md:block">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            type="search"
            placeholder="Ara..."
            className="w-[200px] pl-8 lg:w-[300px]"
          />
        </div>

        {/* Notifications */}
        <Button variant="outline" size="icon" className="relative">
          <Bell className="h-4 w-4" />
          <span className="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-destructive text-[10px] text-destructive-foreground">
            3
          </span>
          <span className="sr-only">Bildirimler</span>
        </Button>

        {/* User menu */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="outline" size="icon">
              <User className="h-4 w-4" />
              <span className="sr-only">Kullanıcı menüsü</span>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-56">
            <DropdownMenuLabel>Hesabım</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Profil</DropdownMenuItem>
            <DropdownMenuItem>Ayarlar</DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem>Çıkış Yap</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  )
}
```

## §2 Stat Cards

### §2.1 KPI Stat Card

```tsx
// components/stat-card.tsx
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { LucideIcon } from "lucide-react"

interface StatCardProps {
  title: string
  value: string
  description: string
  icon: LucideIcon
  trend?: {
    value: string
    positive: boolean
  }
}

export function StatCard({ title, value, description, icon: Icon, trend }: StatCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">
          {title}
        </CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        <p className="text-xs text-muted-foreground">
          {trend && (
            <span className={trend.positive ? "text-green-600" : "text-red-600"}>
              {trend.value}
            </span>
          )}{" "}
          {description}
        </p>
      </CardContent>
    </Card>
  )
}
```

### §2.2 Stat Cards Grid Usage

```tsx
// app/(dashboard)/dashboard/page.tsx
import { DollarSign, Users, CreditCard, Activity } from "lucide-react"
import { StatCard } from "@/components/stat-card"

export default function DashboardPage() {
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <StatCard
        title="Toplam Gelir"
        value="$45,231.89"
        description="geçen aya göre"
        icon={DollarSign}
        trend={{ value: "+20.1%", positive: true }}
      />
      <StatCard
        title="Abonelikler"
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
        title="Aktif Kullanıcı"
        value="+573"
        description="son 24 saatte"
        icon={Activity}
        trend={{ value: "+201", positive: true }}
      />
    </div>
  )
}
```

## §3 Data Tables

### §3.1 Table with shadcn/ui

```tsx
// components/recent-sales-table.tsx
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"

const sales = [
  {
    id: "1",
    name: "Olivia Martin",
    email: "olivia.martin@email.com",
    amount: "+$1,999.00",
    status: "completed",
    avatar: "/avatars/01.png",
  },
  {
    id: "2",
    name: "Jackson Lee",
    email: "jackson.lee@email.com",
    amount: "+$39.00",
    status: "pending",
    avatar: "/avatars/02.png",
  },
  {
    id: "3",
    name: "Isabella Nguyen",
    email: "isabella.nguyen@email.com",
    amount: "+$299.00",
    status: "completed",
    avatar: "/avatars/03.png",
  },
]

export function RecentSalesTable() {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Son Satışlar</CardTitle>
        <CardDescription>Bu ay toplam 265 satış yapıldı.</CardDescription>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Müşteri</TableHead>
              <TableHead className="hidden md:table-cell">Durum</TableHead>
              <TableHead className="text-right">Tutar</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {sales.map((sale) => (
              <TableRow key={sale.id}>
                <TableCell>
                  <div className="flex items-center gap-3">
                    <Avatar className="h-8 w-8">
                      <AvatarImage src={sale.avatar} alt={sale.name} />
                      <AvatarFallback>
                        {sale.name.split(" ").map(n => n[0]).join("")}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <div className="font-medium">{sale.name}</div>
                      <div className="text-sm text-muted-foreground">
                        {sale.email}
                      </div>
                    </div>
                  </div>
                </TableCell>
                <TableCell className="hidden md:table-cell">
                  <Badge variant={sale.status === "completed" ? "default" : "secondary"}>
                    {sale.status}
                  </Badge>
                </TableCell>
                <TableCell className="text-right font-medium">
                  {sale.amount}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}
```

## §4 Chart Containers

### §4.1 Area Chart Card

```tsx
// components/revenue-chart.tsx
"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Area, AreaChart, CartesianGrid, XAxis, YAxis, ResponsiveContainer, Tooltip } from "recharts"

const data = [
  { name: "Oca", revenue: 4000, profit: 2400 },
  { name: "Şub", revenue: 3000, profit: 1398 },
  { name: "Mar", revenue: 2000, profit: 9800 },
  { name: "Nis", revenue: 2780, profit: 3908 },
  { name: "May", revenue: 1890, profit: 4800 },
  { name: "Haz", revenue: 2390, profit: 3800 },
  { name: "Tem", revenue: 3490, profit: 4300 },
]

export function RevenueChart() {
  return (
    <Card className="col-span-4">
      <CardHeader>
        <CardTitle>Gelir Genel Bakış</CardTitle>
        <CardDescription>Son 7 ayın gelir ve kar analizi</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="h-[300px] w-full">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={data}>
              <defs>
                <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--chart-1))" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="hsl(var(--chart-1))" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid
                strokeDasharray="3 3"
                stroke="hsl(var(--border))"
                vertical={false}
              />
              <XAxis
                dataKey="name"
                stroke="hsl(var(--muted-foreground))"
                fontSize={12}
                tickLine={false}
                axisLine={false}
              />
              <YAxis
                stroke="hsl(var(--muted-foreground))"
                fontSize={12}
                tickLine={false}
                axisLine={false}
                tickFormatter={(value) => `$${value}`}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: "hsl(var(--popover))",
                  border: "1px solid hsl(var(--border))",
                  borderRadius: "var(--radius)",
                  color: "hsl(var(--popover-foreground))",
                }}
              />
              <Area
                type="monotone"
                dataKey="revenue"
                stroke="hsl(var(--chart-1))"
                strokeWidth={2}
                fillOpacity={1}
                fill="url(#colorRevenue)"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  )
}
```

## §5 Form Layouts

### §5.1 Settings Form Page

```tsx
// app/(dashboard)/settings/page.tsx
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { Separator } from "@/components/ui/separator"

export default function SettingsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold tracking-tight">Ayarlar</h1>
        <p className="text-sm text-muted-foreground">
          Hesap ayarlarınızı ve e-posta tercihlerinizi yönetin.
        </p>
      </div>
      <Separator />

      <Card>
        <CardHeader>
          <CardTitle>Profil</CardTitle>
          <CardDescription>
            Profil bilgilerinizi güncelleyin. Değişiklikler hemen yansır.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="first-name">Ad</Label>
              <Input id="first-name" placeholder="Adınız" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="last-name">Soyad</Label>
              <Input id="last-name" placeholder="Soyadınız" />
            </div>
          </div>
          <div className="space-y-2">
            <Label htmlFor="email">E-posta</Label>
            <Input id="email" type="email" placeholder="ornek@email.com" />
          </div>
        </CardContent>
        <CardFooter>
          <Button>Değişiklikleri Kaydet</Button>
        </CardFooter>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Bildirimler</CardTitle>
          <CardDescription>
            Hangi bildirimleri almak istediğinizi seçin.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="space-y-0.5">
              <Label htmlFor="email-notifications">E-posta bildirimleri</Label>
              <p className="text-sm text-muted-foreground">
                Önemli güncellemeler için e-posta alın.
              </p>
            </div>
            <Switch id="email-notifications" defaultChecked />
          </div>
          <Separator />
          <div className="flex items-center justify-between">
            <div className="space-y-0.5">
              <Label htmlFor="marketing">Pazarlama e-postaları</Label>
              <p className="text-sm text-muted-foreground">
                Yeni özellikler ve kampanyalardan haberdar olun.
              </p>
            </div>
            <Switch id="marketing" />
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
```

## §6 Sidebar Navigation

### §6.1 Sidebar Component

```tsx
// components/app-sidebar.tsx
"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  LayoutDashboard,
  BarChart3,
  Users,
  Package,
  ShoppingCart,
  Settings,
  HelpCircle,
  ChevronLeft,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { ScrollArea } from "@/components/ui/scroll-area"
import { cn } from "@/lib/utils"

const navGroups = [
  {
    title: "Genel",
    items: [
      { title: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
      { title: "Analitik", href: "/analytics", icon: BarChart3 },
    ],
  },
  {
    title: "Yönetim",
    items: [
      { title: "Müşteriler", href: "/customers", icon: Users },
      { title: "Ürünler", href: "/products", icon: Package },
      { title: "Siparişler", href: "/orders", icon: ShoppingCart },
    ],
  },
  {
    title: "Diğer",
    items: [
      { title: "Ayarlar", href: "/settings", icon: Settings },
      { title: "Yardım", href: "/help", icon: HelpCircle },
    ],
  },
]

export function AppSidebar() {
  const pathname = usePathname()

  return (
    <aside className="hidden md:flex md:w-[280px] md:flex-col md:fixed md:inset-y-0 border-r border-sidebar-border bg-sidebar-background">
      {/* Logo */}
      <div className="flex h-16 items-center gap-2 px-6 border-b border-sidebar-border">
        <div className="h-8 w-8 rounded-lg bg-primary flex items-center justify-center">
          <span className="text-primary-foreground font-bold text-sm">A</span>
        </div>
        <span className="font-semibold text-sidebar-foreground">Admin Panel</span>
      </div>

      {/* Navigation */}
      <ScrollArea className="flex-1 py-4">
        <nav className="space-y-6 px-3">
          {navGroups.map((group) => (
            <div key={group.title} className="space-y-1">
              <h3 className="px-3 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                {group.title}
              </h3>
              <div className="space-y-1">
                {group.items.map((item) => {
                  const isActive = pathname === item.href
                  return (
                    <Link
                      key={item.href}
                      href={item.href}
                      aria-current={isActive ? "page" : undefined}
                      className={cn(
                        "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                        isActive
                          ? "bg-sidebar-accent text-sidebar-accent-foreground"
                          : "text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
                      )}
                    >
                      <item.icon className="h-4 w-4" />
                      {item.title}
                    </Link>
                  )
                })}
              </div>
            </div>
          ))}
        </nav>
      </ScrollArea>

      {/* Footer */}
      <div className="border-t border-sidebar-border p-4">
        <Button variant="outline" className="w-full justify-start gap-2">
          <ChevronLeft className="h-4 w-4" />
          Sidebar'ı Daralt
        </Button>
      </div>
    </aside>
  )
}
```