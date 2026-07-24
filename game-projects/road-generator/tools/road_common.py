#!/usr/bin/env python3
"""
Utilitaires partagés des générateurs de route Thomson TO8.

Fournit :
- Lecture PNG indexé (color_type=3, filtre 0/1, sans dépendance Pillow)
- Détection de la zone non-transparente d'une ligne (`measure_effective_width`)
- Conversion d'une ligne de pixels en plans BM16 RAMA/RAMB
- Écriture textuelle d'un fichier .asm

Ces helpers étaient historiquement définis dans `compile_road_sprites.py`
(générateur v1, obsolète). Extraits ici pour les rendre réutilisables
par `compile_road_sprites_ram.py` (v4) sans dépendre du v1.
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path


# ── Largeur cible de la fenêtre de rendu ─────────────────────────────────────
WINDOW_PX = 160           # le batch écrit toujours 160 pixels écran


# ── PNG indexé (color_type=3) ─────────────────────────────────────────────────

def read_png_indexed(path: Path):
    """Lit un PNG indexé. Renvoie (width, height, pixels_2d).
       pixels_2d : list[list[int]] d'indices PNG (0..255). 0 = transparent."""
    data = path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f"Pas un PNG : {path}")
    pos = 8
    width = height = depth = ctype = 0
    idat = b''
    while pos < len(data):
        clen = struct.unpack('>I', data[pos:pos + 4])[0]
        tag = data[pos + 4:pos + 8]
        payload = data[pos + 8:pos + 8 + clen]
        pos += 8 + clen + 4
        if tag == b'IHDR':
            width, height, depth, ctype = struct.unpack('>IIBB', payload[:10])
            if ctype != 3:
                raise ValueError(f"PNG non paletté : {path}")
        elif tag == b'IDAT':
            idat += payload
        elif tag == b'IEND':
            break
    raw = zlib.decompress(idat)
    pixels = []
    stride = 1 + width
    for y in range(height):
        ls = y * stride
        filt = raw[ls]
        line = raw[ls + 1:ls + 1 + width]
        if filt == 0:
            pixels.append(list(line))
        elif filt == 1:
            cur = bytearray(line)
            for x in range(1, len(cur)):
                cur[x] = (cur[x] + cur[x - 1]) & 0xff
            pixels.append(list(cur))
        else:
            raise ValueError(f"Filter PNG non géré : {filt}")
    return width, height, pixels


# ── Détection de zone effective ──────────────────────────────────────────────

def measure_effective_width(row):
    """Renvoie (start, end, eff_w) — indices début/fin contenu non-transparent
       et largeur effective. row : liste d'indices PNG, 0 = transparent."""
    start = next((i for i, p in enumerate(row) if p != 0), -1)
    if start < 0:
        return 0, 0, 0
    end = next((len(row) - i for i, p in enumerate(reversed(row)) if p != 0), 0)
    return start, end, end - start


# ── Pixel row → plans BM16 RAMA / RAMB ────────────────────────────────────────

def pixels_to_bm16(pixel_row):
    """Convertit une ligne de pixels (indices PNG 1..16) en bytes RAMA/RAMB.
       Mapping PNG → TO8 : index 0 (transparent) interdit, sinon -1.
       Renvoie (rama, ramb)."""
    n = len(pixel_row)
    if n % 4 != 0:
        raise ValueError(f"Largeur non multiple de 4 : {n}")
    rama = bytearray(n // 4)
    ramb = bytearray(n // 4)
    for k in range(n // 4):
        p = pixel_row[4 * k:4 * k + 4]
        if any(px == 0 for px in p):
            raise ValueError(f"Pixel transparent dans contenu sprite à pos {4*k}..{4*k+3}")
        p = [(px - 1) & 0x0F for px in p]
        rama[k] = (p[0] << 4) | p[1]
        ramb[k] = (p[2] << 4) | p[3]
    return bytes(rama), bytes(ramb)


# ── Écriture PNG indexé (color_type=3) ───────────────────────────────────────

def write_png_indexed(path: Path, width, height, pixels, palette_rgb,
                      *, transparent0=True):
    """Écrit un PNG indexé 8 bpp. pixels : list[list[int]] d'indices,
       palette_rgb : list[(r, g, b)]. Si transparent0, l'index 0 est
       déclaré transparent via tRNS."""
    def chunk(tag, payload):
        c = struct.pack('>I', len(payload)) + tag + payload
        return c + struct.pack('>I', zlib.crc32(tag + payload) & 0xffffffff)

    ihdr = struct.pack('>IIBBBBB', width, height, 8, 3, 0, 0, 0)
    plte = b''.join(bytes(rgb) for rgb in palette_rgb)
    raw = b''.join(b'\x00' + bytes(row) for row in pixels)
    out = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'PLTE', plte)
    if transparent0:
        out += chunk(b'tRNS', b'\x00')
    out += chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b'')
    path.write_bytes(out)


# ── Écriture asm ──────────────────────────────────────────────────────────────

def write_asm(path: Path, lines):
    """Écrit un fichier .asm : `\\n`.join(lines) + newline final."""
    path.write_text("\n".join(lines) + "\n")
