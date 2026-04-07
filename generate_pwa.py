#!/usr/bin/env python3
"""Generate www/index.html from mathkids-v3.html with PWA transformations."""

import re

src = '/Users/segadharmawan/Desktop/WORKS/Claude/Mathkids/mathkids-v3.html'
dst = '/Users/segadharmawan/Desktop/WORKS/Claude/Mathkids/www/index.html'

with open(src, 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Insert PWA meta tags after <title>MathKids</title>
pwa_meta = """<meta name="description" content="Aplikasi belajar matematika yang menyenangkan untuk anak-anak">
<meta name="theme-color" content="#6D28D9">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="MathKids">
<link rel="manifest" href="manifest.json">
<link rel="icon" type="image/png" sizes="192x192" href="icons/icon-192x192.png">
<link rel="apple-touch-icon" href="icons/icon-192x192.png">"""

html = html.replace(
    '<title>MathKids</title>',
    '<title>MathKids</title>\n' + pwa_meta
)

# 2. CSS body: replace background and layout
html = html.replace(
    'background:#111;display:flex;align-items:center;justify-content:center;',
    'background:#1a1a2e;margin:0;padding:0;'
)

# 3. Replace .phone rule
html = re.sub(
    r'\.phone\{width:390px;height:844px;[^}]*\}',
    '.phone{width:100%;height:100dvh;position:relative;overflow:hidden;display:flex;flex-direction:column;}',
    html
)

# 4. Replace .notch CSS rule
html = re.sub(
    r'\.notch\{position:absolute;[^}]*\}',
    '.notch{display:none;}',
    html
)

# 5. Remove @media(max-width:430px){...} block, keep .home-topbar standalone
html = re.sub(
    r'@media\(max-width:430px\)\{[^}]*\{[^}]*\}[^}]*\{[^}]*\}[^}]*\{[^}]*\}[^}]*\{[^}]*\}\s*\}',
    '.home-topbar{padding-top:52px;}',
    html
)

# 6. Remove <div class="notch"></div> from HTML
html = re.sub(r'\s*<div class="notch"></div>', '', html)

# 7. Add service worker registration before closing
# The file ends with </script> and a blank line; we need to add </body></html> with SW script
# First, ensure we add it at the very end
html = html.rstrip()
html += '\n<script>if(\'serviceWorker\' in navigator){navigator.serviceWorker.register(\'sw.js\').catch(e=>console.warn(\'SW:\',e));}</script></body></html>\n'

with open(dst, 'w', encoding='utf-8') as f:
    f.write(html)

print(f"Generated {dst}")
print(f"Source lines: {open(src).read().count(chr(10))}")
print(f"Output lines: {html.count(chr(10))}")
