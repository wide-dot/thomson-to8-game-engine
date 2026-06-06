// Accès au backend FastAPI (pont sur le pipeline Python = source de vérité).
const BASE = (import.meta as any).env?.VITE_API ?? 'http://127.0.0.1:8765'

export interface Meta { id: string; nb_segments: number; nb_subpos: number; subpos_per_seg: number }
export interface Shape { n: number; delta_curve: number[]; delta_pitch: number[]; flags: { pit: boolean; start: boolean }[] }
export interface Segment { circuit: string; segment: number; delta_curve: number; delta_pitch: number; flags: { pit: boolean; start: boolean }; min_y: number }
export interface Geometry { n: number; x: number[]; y: number[]; z: number[]; heading: number[] }

const j = (p: string) => fetch(`${BASE}${p}`).then(r => r.json())

export interface SegPatch { delta_curve?: number; delta_pitch?: number; pit?: boolean; start?: boolean }

export const renderUrl = (circuit: string, pos: number, steer = 0, rev = 0, pal?: number[][], bg?: number[]) => {
  let u = `${BASE}/render?circuit=${encodeURIComponent(circuit)}&pos=${pos}&steer=${steer}&v=${rev}`
  if (pal) u += '&pal=' + pal.flat().join(',')
  if (bg) u += '&bg=' + bg.join(',')
  return u
}
// URL de téléchargement du zip d'export (piste native + stream + textures reteintées)
export const exportUrl = (circuit: string, pal?: number[][]) => {
  let u = `${BASE}/export/${encodeURIComponent(circuit)}`
  if (pal) u += '?pal=' + pal.flat().join(',')
  return u
}
// déploie le circuit dans l'arbre engine + patche la config (1 circuit actif / build)
export const deployCircuit = (c: string, pal?: number[][]): Promise<{ ok: boolean; circuit: string; nchunks: number; frames: number; deployed_dir: string; patched: string[] }> =>
  fetch(`${BASE}/deploy/${encodeURIComponent(c)}${pal ? '?pal=' + pal.flat().join(',') : ''}`, { method: 'POST' }).then(r => {
    if (!r.ok) return r.json().then(e => Promise.reject(e.detail ?? 'erreur déploiement'))
    return r.json()
  })
export const getCircuits = (): Promise<{ circuits: string[]; saved: string[]; custom: string[] }> => j('/circuits')
export const saveCircuit = (c: string): Promise<{ ok: boolean; saved: boolean }> =>
  fetch(`${BASE}/save/${c}`, { method: 'POST' }).then(r => r.json())
export const getMeta = (c: string): Promise<Meta> => j(`/circuit/${c}`)
export const getShape = (c: string): Promise<Shape> => j(`/shape/${c}`)
export const getGeometry = (c: string): Promise<Geometry> => j(`/geometry/${c}`)
export const getSegment = (c: string, i: number): Promise<Segment> => j(`/segment/${c}/${i}`)
export const getPalette = (): Promise<{ levels: number[] }> => j('/palette/to8')
export const getPaletteDefault = (): Promise<{ levels: number[][]; to8: number[] }> => j('/palette/default')
export const patchSegment = (c: string, i: number, patch: SegPatch): Promise<Segment> =>
  fetch(`${BASE}/segment/${c}/${i}`, {
    method: 'PATCH', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(patch),
  }).then(r => r.json())

export const resizeCircuit = (c: string, nb: number): Promise<{ id: string; nb_segments: number; nb_subpos: number }> =>
  fetch(`${BASE}/circuit/${c}/resize?nb_segs=${nb}`, { method: 'PATCH' }).then(r => r.json())

export const propEdit = (c: string, seg: int, field: 'curve'|'pitch', value: int, radius: int, strength: number): Promise<Shape> =>
  fetch(`${BASE}/circuit/${c}/prop?seg=${seg}&field=${field}&value=${value}&radius=${radius}&strength=${strength}`, { method: 'PATCH' }).then(r => r.json())

export const resetCircuit = (c: string): Promise<{ ok: boolean; circuit: string }> =>
  fetch(`${BASE}/reset/${c}`, { method: 'POST' }).then(r => r.json())

export const generateCircuit = (c: string, profile: string, seed: int, turns: number, elev: number): Promise<{ id: string; generated: boolean; closure_check: int }> =>
  fetch(`${BASE}/circuit/${c}/generate?profile=${profile}&seed=${seed}&turns=${turns}&elev=${elev}`, { method: 'POST' }).then(r => r.json())

// alias type
type int = number

export const newCircuit = (name = '', nbSegs = 64): Promise<{ id: string; nb_segments: number }> =>
  fetch(`${BASE}/circuit/new?name=${encodeURIComponent(name)}&nb_segs=${nbSegs}`, { method: 'POST' }).then(r => {
    if (!r.ok) return r.json().then(e => Promise.reject(e.detail ?? 'erreur'))
    return r.json()
  })
