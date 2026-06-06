// Construit les SVG plan (vue de dessus) + ruban 3D à partir de la géométrie
// FIDÈLE renvoyée par le backend (/geometry : x,y,z,heading par segment, déjà
// intégrée via la récurrence du moteur). Ici : juste projection + auto-fit.
import type { Geometry } from './api'

const rgb = (r: number, g: number, b: number) => `rgb(${r | 0},${g | 0},${b | 0})`

// auto-fit : centre + zoom une liste de points écran dans WxH avec marge
function fit(pts: [number, number][], W: number, H: number, margin: number) {
  const xs = pts.map(p => p[0]), ys = pts.map(p => p[1])
  const mnx = Math.min(...xs), mxx = Math.max(...xs), mny = Math.min(...ys), mxy = Math.max(...ys)
  const w = mxx - mnx || 1, h = mxy - mny || 1
  const sc = Math.min((W - 2 * margin) / w, (H - 2 * margin) / h)
  const ox = (W - w * sc) / 2 - mnx * sc, oy = (H - h * sc) / 2 - mny * sc
  return (p: [number, number]): [number, number] => [p[0] * sc + ox, p[1] * sc + oy]
}

export function buildPlan(g: Geometry, markFrac: number, W = 300, H = 224): string {
  // monde -> écran : y_monde vers le HAUT (SVG y inversé) pour respecter le sens des virages
  const world: [number, number][] = g.x.map((x, i) => [x, -g.y[i]])
  const T = fit(world, W, H, 22)
  const P = world.map(T)
  const d = P.map((p, i) => (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1)).join(' ')
  const mi = Math.min(P.length - 1, Math.max(0, Math.round(markFrac * (P.length - 1))))
  const m = P[mi] ?? P[0], s0 = P[0] ?? [0, 0]
  return `<svg viewBox="0 0 ${W} ${H}" preserveAspectRatio="xMidYMid meet" style="width:100%;height:100%">
    <path d="${d}" fill="none" stroke="#10131a" stroke-width="13" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="${d}" fill="none" stroke="#5a86c8" stroke-width="6.5" stroke-linecap="round" stroke-linejoin="round"/>
    <rect x="${s0[0] - 5}" y="${s0[1] - 5}" width="10" height="10" fill="#e9edf5" opacity=".85"/>
    <circle cx="${m[0]}" cy="${m[1]}" r="6" fill="#ffb454" stroke="#06101f" stroke-width="1.6"/>
    <circle cx="${m[0]}" cy="${m[1]}" r="11" fill="none" stroke="#ffb454" stroke-opacity=".4" stroke-width="1.5"/>
  </svg>`
}

// caméra orbitale : yaw autour de la verticale, pitch = angle d'élévation
// (pitch→π/2 = vue de dessus, pitch→0 = vue de côté). Projection orthographique.
// interpolation Catmull-Rom : lisse un tableau en K sous-points/intervalle
// (passe par les points d'origine, continuité C1). Bornes clampées.
function crSample(a: number[], K: number): number[] {
  const m = a.length; if (m < 2) return a.slice()
  const at = (i: number) => a[Math.max(0, Math.min(m - 1, i))]
  const out: number[] = []
  for (let i = 0; i < m; i++) {
    const p0 = at(i - 1), p1 = at(i), p2 = at(i + 1), p3 = at(i + 2)
    for (let k = 0; k < K; k++) {
      const t = k / K, t2 = t * t, t3 = t2 * t
      out.push(0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3))
    }
  }
  out.push(a[m - 1])
  return out
}

const RIBBON_SUBDIV = 5   // sous-points / segment (lissage hauteurs + courbes)

// zone d'influence proportionnelle à matérialiser sur le ruban
export interface PropHL { seg: number; radius: number; strength: number; nbSeg: number }
// poids falloff smooth (miroir du backend) : 1 au centre -> 0 au bord du rayon
function falloffW(d: number, radius: number): number {
  const t = Math.max(0, 1 - d / Math.max(1, radius + 1))
  return 0.5 - 0.5 * Math.cos(Math.PI * t)
}

export function buildRibbon(g: Geometry, markFrac: number, yaw = 0.5, pitch = 0.6, W = 700, Hh = 280, hl: PropHL | null = null): string {
  const K = RIBBON_SUBDIV
  // x, y ET z interpolés Catmull-Rom -> ruban lisse (collines non facettées)
  const gx = crSample(g.x, K), gy = crSample(g.y, K), gz = crSample(g.z, K)
  const n = gx.length
  const cx = (Math.max(...gx) + Math.min(...gx)) / 2
  const cy = (Math.max(...gy) + Math.min(...gy)) / 2
  const span = Math.max(Math.max(...gx) - Math.min(...gx), Math.max(...gy) - Math.min(...gy)) || 1
  const zUnit = span * 0.16
  const cY = Math.cos(yaw), sY = Math.sin(yaw), cP = Math.cos(pitch), sP = Math.sin(pitch)
  // projette un point monde (X latéral, Y avance, Z hauteur) -> écran
  const proj = (X: number, Y: number, Z: number): [number, number] => {
    const x1 = X * cY - Y * sY, y1 = X * sY + Y * cY
    return [x1, -(y1 * sP + Z * cP)]
  }
  // largeur de route en ESPACE MONDE (perpendiculaire à la tangente dans le plan sol)
  const hw = span * 0.038
  const L: [number, number][] = [], R: [number, number][] = [], TP: [number, number][] = [], BP: [number, number][] = []
  for (let i = 0; i < n; i++) {
    const X = gx[i] - cx, Y = gy[i] - cy
    const i0 = Math.max(0, i - 1), i1 = Math.min(n - 1, i + 1)
    let tx = (gx[i1] - gx[i0]), ty = (gy[i1] - gy[i0])
    const tl = Math.hypot(tx, ty) || 1; tx /= tl; ty /= tl
    const px = -ty, py = tx
    TP.push(proj(X, Y, gz[i] * zUnit))
    BP.push(proj(X, Y, 0))
    L.push(proj(X + px * hw, Y + py * hw, gz[i] * zUnit))
    R.push(proj(X - px * hw, Y - py * hw, gz[i] * zUnit))
  }
  const T = fit([...TP, ...BP, ...L, ...R], W, Hh, 26)
  const sTP = TP.map(T), sBP = BP.map(T), sL = L.map(T), sR = R.map(T)
  let quads = '', posts = '', dashes = '', hlPolys = ''
  for (let i = 0; i < n; i++) {
    if (i % (3 * K) === 0 && Math.abs(sBP[i][1] - sTP[i][1]) > 4)
      posts += `<line x1="${sTP[i][0].toFixed(1)}" y1="${sTP[i][1].toFixed(1)}" x2="${sBP[i][0].toFixed(1)}" y2="${sBP[i][1].toFixed(1)}" stroke="#262b36" stroke-width="1"/>`
    if (i > 0) {
      const f = 0.30 + 0.62 * (i / n), b = Math.floor(i / K) % 2 ? [58, 66, 86] : [48, 55, 73]
      const poly = `${sL[i-1][0].toFixed(1)},${sL[i-1][1].toFixed(1)} ${sR[i-1][0].toFixed(1)},${sR[i-1][1].toFixed(1)} ${sR[i][0].toFixed(1)},${sR[i][1].toFixed(1)} ${sL[i][0].toFixed(1)},${sL[i][1].toFixed(1)}`
      quads += `<polygon points="${poly}" fill="${rgb(b[0]*f+22,b[1]*f+24,b[2]*f+30)}" stroke="#11141a" stroke-width=".3"/>`
      // overlay zone d'influence proportionnelle (ambre, opacité = poids falloff × force)
      if (hl) {
        const oseg = Math.floor(i / K) % hl.nbSeg
        let d = Math.abs(oseg - hl.seg); d = Math.min(d, hl.nbSeg - d)
        if (d <= hl.radius) {
          const wv = d === 0 ? 1 : falloffW(d, hl.radius) * hl.strength
          if (wv > 0.02)
            hlPolys += `<polygon points="${poly}" fill="#ffb454" fill-opacity="${(0.18 + 0.55 * wv).toFixed(2)}" stroke="none"/>`
        }
      }
      if (i % 2 === 0)
        dashes += `<line x1="${sTP[i-1][0].toFixed(1)}" y1="${sTP[i-1][1].toFixed(1)}" x2="${sTP[i][0].toFixed(1)}" y2="${sTP[i][1].toFixed(1)}" stroke="#e6ebf4" stroke-opacity=".5" stroke-width="1.2" stroke-dasharray="4 4"/>`
    }
  }
  const mi = Math.min(n - 1, Math.max(0, Math.round(markFrac * (n - 1))))
  const mt = sTP[mi]
  const marker = `<circle cx="${mt[0].toFixed(1)}" cy="${mt[1].toFixed(1)}" r="8" fill="#ffb454" stroke="#06101f" stroke-width="2"/>
    <circle cx="${mt[0].toFixed(1)}" cy="${mt[1].toFixed(1)}" r="13" fill="none" stroke="#ffb454" stroke-opacity=".4" stroke-width="1.5"/>`
  return `<svg viewBox="0 0 ${W} ${Hh}" preserveAspectRatio="xMidYMid meet" style="width:100%;height:100%">${posts}${quads}${hlPolys}${dashes}${marker}</svg>`
}
