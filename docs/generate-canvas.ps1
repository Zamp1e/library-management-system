Add-Type -AssemblyName System.Drawing
$outDir = "C:\Users\19094\Desktop"
$outPath = "$outDir\systematic-silence.png"

$bmp = New-Object System.Drawing.Bitmap(1600, 2200)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'HighQuality'
$g.TextRenderingHint = 'AntiAliasGridFit'

# Aged paper background
$g.Clear([System.Drawing.Color]::FromArgb(252, 248, 240))

# ---- Dot grid texture (subtle) ----
$dotPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(10, 170, 160, 140), 0.8)
for ($gy = 40; $gy -lt 2160; $gy += 24) {
    for ($gx = 60; $gx -lt 1540; $gx += 24) {
        $g.DrawEllipse($dotPen, $gx, $gy, 1.0, 1.0)
    }
}
$dotPen.Dispose()

# ---- Vertical structural line ----
$vPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 150, 135, 115), 1.2)
$g.DrawLine($vPen, 540, 100, 540, 2100)
$vPen.Dispose()

# ---- Load fonts ----
$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$fontDir = "C:\Users\19094\.claude\plugins\cache\anthropic-agent-skills\document-skills\da20c92503b2\skills\canvas-design\canvas-fonts"
$pfc.AddFontFile("$fontDir\LibreBaskerville-Regular.ttf")
$pfc.AddFontFile("$fontDir\CrimsonPro-Regular.ttf")
$pfc.AddFontFile("$fontDir\GeistMono-Regular.ttf")
$pfc.AddFontFile("$fontDir\InstrumentSerif-Regular.ttf")

$ffLibre = ($pfc.Families | Where-Object Name -eq 'Libre Baskerville')
$ffCrim = ($pfc.Families | Where-Object Name -eq 'Crimson Pro')
$ffMono = ($pfc.Families | Where-Object Name -eq 'Geist Mono')
$ffInst = ($pfc.Families | Where-Object Name -eq 'Instrument Serif')

if (-not $ffLibre) { $ffLibre = New-Object System.Drawing.FontFamily('Georgia') }
if (-not $ffCrim) { $ffCrim = New-Object System.Drawing.FontFamily('Georgia') }
if (-not $ffMono) { $ffMono = New-Object System.Drawing.FontFamily('Consolas') }
if (-not $ffInst) { $ffInst = New-Object System.Drawing.FontFamily('Georgia') }

# ---- LEFT: Title and Classification numbers ----
$titleF = New-Object System.Drawing.Font($ffLibre, 18, [System.Drawing.FontStyle]::Regular)
$titleB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 55, 42, 30))
$g.DrawString("SYSTEMATIC", $titleF, $titleB, 60, 80)
$g.DrawString("SILENCE", $titleF, $titleB, 60, 108)

# Thin divider
$divP = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 160, 140, 115), 0.8)
$g.DrawLine($divP, 60, 142, 480, 142)

# Classification entries
$entries = @(
    @{num="004"; cat="Computer Science"},
    @{num="005"; cat="Software Engineering"},
    @{num="020"; cat="Library & Information"},
    @{num="100"; cat="Philosophy"},
    @{num="300"; cat="Social Sciences"},
    @{num="510"; cat="Mathematics"},
    @{num="530"; cat="Physics"},
    @{num="800"; cat="Literature"},
    @{num="900"; cat="History & Geography"}
)

$numF = New-Object System.Drawing.Font($ffMono, 24, [System.Drawing.FontStyle]::Regular)
$catF = New-Object System.Drawing.Font($ffCrim, 11, [System.Drawing.FontStyle]::Regular)
$inkB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 55, 42, 30))
$fadeB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 140, 125, 100))

$y = 175
foreach ($e in $entries) {
    $g.DrawString($e.num, $numF, $inkB, 60, $y)
    $g.DrawString($e.cat, $catF, $fadeB, 200, $y + 6)
    $sP = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(15, 160, 140, 115), 0.3)
    $g.DrawLine($sP, 60, $y + 50, 480, $y + 50)
    $sP.Dispose()
    $y += 72
}
$numF.Dispose(); $catF.Dispose(); $inkB.Dispose(); $fadeB.Dispose()

# ---- RIGHT: Geometric book-spine pattern ----
$shelfY = 155
$spineColors = @(
    @([System.Drawing.Color]::FromArgb(45, 85, 75, 55), 40),
    @([System.Drawing.Color]::FromArgb(60, 120, 100, 70), 44),
    @([System.Drawing.Color]::FromArgb(35, 95, 80, 58), 38),
    @([System.Drawing.Color]::FromArgb(55, 110, 92, 62), 46),
    @([System.Drawing.Color]::FromArgb(40, 78, 65, 48), 36),
    @([System.Drawing.Color]::FromArgb(50, 105, 88, 60), 42),
    @([System.Drawing.Color]::FromArgb(65, 130, 108, 75), 48),
    @([System.Drawing.Color]::FromArgb(38, 90, 72, 50), 34),
    @([System.Drawing.Color]::FromArgb(48, 100, 82, 55), 40),
    @([System.Drawing.Color]::FromArgb(42, 88, 70, 48), 38)
)

for ($row = 0; $row -lt 10; $row++) {
    $sy = $shelfY + $row * 72
    $col = $spineColors[$row][0]
    $count = 3 + ($row % 4)
    $bb = New-Object System.Drawing.SolidBrush($col)
    for ($b = 0; $b -lt $count; $b++) {
        $bw = 18 + ($b % 3) * 14
        $bh = 46 + ($row % 3) * 5
        $bx = 580 + $b * 110
        $rr = New-Object System.Drawing.Drawing2D.GraphicsPath
        $rr.AddArc($bx, $sy, 4, 4, 180, 90)
        $rr.AddArc($bx + $bw - 4, $sy, 4, 4, 270, 90)
        $rr.AddArc($bx + $bw - 4, $sy + $bh - 4, 4, 4, 0, 90)
        $rr.AddArc($bx, $sy + $bh - 4, 4, 4, 90, 90)
        $rr.CloseFigure()
        $g.FillPath($bb, $rr)
        $rr.Dispose()
    }
    $bb.Dispose()
    # Shelf line
    $shP = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(25, 150, 130, 105), 0.6)
    $g.DrawLine($shP, 580, $sy + 52, 1520, $sy + 52)
    $shP.Dispose()
}

# ---- BOTTOM: Anchor text ----
$botY = 1250
$sepP = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(70, 160, 140, 110), 1.2)
$g.DrawLine($sepP, 560, $botY, 1520, $botY)
$sepP.Dispose()

$txtF = New-Object System.Drawing.Font($ffInst, 14, [System.Drawing.FontStyle]::Regular)
$txtB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(130, 100, 85, 60))

$col1 = "Knowledge does not announce itself.`nIt waits, arranged with quiet precision,`nfor the moment of discovery.`nEvery spine aligned to the millimeter.`nEvery number carrying a universe`nof meaning within its digits."
$col2 = "The catalog is not a list —`nit is a map of human thought.`nThe library asks nothing of you`nbut patience. It rewards the careful`neye, the lingering hand, the mind`nthat traces systems back to their origin."

$g.DrawString($col1, $txtF, $txtB, 580, $botY + 30)
$g.DrawString($col2, $txtF, $txtB, 960, $botY + 30)
$txtF.Dispose(); $txtB.Dispose()

# ---- Footer catalog reference ----
$refF = New-Object System.Drawing.Font($ffMono, 9, [System.Drawing.FontStyle]::Regular)
$refB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(55, 150, 130, 105))
$g.DrawString("CAT.025.431 — SYSTEMATIC SILENCE — MMXXVI", $refF, $refB, 560, 2100)
$refF.Dispose(); $refB.Dispose()

# ---- Additional right panel: Floating abstract marks ----
$markY = 1000
$markPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(35, 110, 95, 70), 0.8)
for ($i = 0; $i -lt 8; $i++) {
    $mx = 580 + $i * 100
    $mk = 3 + ($i % 3) * 2
    for ($j = 0; $j -lt $mk; $j++) {
        $my = $markY + $j * 22
        $mw = 60 + ($i * 7) % 40
        $g.DrawLine($markPen, $mx, $my, $mx + $mw, $my)
        # Small dot marker
        $dotB = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50, 130, 110, 80))
        $g.FillEllipse($dotB, $mx + $mw + 6, $my - 2, 4, 4)
        $dotB.Dispose()
    }
}
$markPen.Dispose()

# ---- Cleanup and save ----
$titleF.Dispose(); $titleB.Dispose(); $divP.Dispose()
$g.Dispose()
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Output "Saved: $outPath ($(1600)x$(2200))"
