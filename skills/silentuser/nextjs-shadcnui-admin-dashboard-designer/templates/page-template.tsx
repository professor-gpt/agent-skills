// Admin Dashboard Page Template
// Bu şablonu yeni sayfa oluştururken başlangıç noktası olarak kullanın.
// app/(dashboard)/[page-name]/page.tsx konumuna kaydedin.

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Separator } from "@/components/ui/separator"

// Page metadata (Next.js App Router)
export const metadata = {
  title: "Sayfa Adı | Admin Panel",
  description: "Sayfa açıklaması",
}

export default function PageNamePage() {
  return (
    <div className="space-y-8">
      {/* ── Page Header ── */}
      <div className="flex items-center justify-between">
        <div className="space-y-1">
          <h1 className="text-3xl font-semibold tracking-tight">
            Sayfa Başlığı
          </h1>
          <p className="text-sm text-muted-foreground">
            Sayfanın kısa açıklaması ve amacı.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm">İkincil Aksiyon</Button>
          <Button size="sm">Birincil Aksiyon</Button>
        </div>
      </div>

      <Separator />

      {/* ── Main Content Grid ── */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {/* Card 1 */}
        <Card className="col-span-2">
          <CardHeader>
            <CardTitle>Ana İçerik</CardTitle>
            <CardDescription>
              Bu bölüm ana içeriği barındırır — tablo, grafik veya form.
            </CardDescription>
          </CardHeader>
          <CardContent>
            {/* Tablo, grafik veya form component'i buraya */}
            <div className="flex h-[300px] items-center justify-center rounded-md border border-dashed border-border">
              <p className="text-sm text-muted-foreground">
                İçerik alanı
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Card 2 — Sidebar panel */}
        <Card>
          <CardHeader>
            <CardTitle>Yan Panel</CardTitle>
            <CardDescription>
              Filtreler, özet bilgiler veya hızlı aksiyonlar.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Yan panel içeriği */}
            <div className="rounded-lg bg-muted p-4">
              <p className="text-sm font-medium">Özet Bilgi</p>
              <p className="text-sm text-muted-foreground">Açıklama metni</p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}