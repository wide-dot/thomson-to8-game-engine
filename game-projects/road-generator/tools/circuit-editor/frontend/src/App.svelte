<script lang="ts">
  import { onMount } from 'svelte'
  import * as api from './lib/api'
  import type { Meta, Shape, Segment, Geometry } from './lib/api'
  import { buildPlan, buildRibbon } from './lib/track'
  import { Plus, Wand2, RotateCcw, Save, Trash2, ChevronLeft, ChevronRight,
    SkipBack, Play, Pause, Crosshair, Dices, Sparkles, Target, Pipette,
    Circle, Spline, Waves, Grid2x2, Mountain, TrendingUp, Package, Rocket } from '@lucide/svelte'
  const PROF_ICONS: Record<string, any> = {
    oval: Circle, technique: Spline, flowing: Waves, street: Grid2x2, montagne: Mountain, hillclimb: TrendingUp
  }

  /* ── état principal ── */
  let circuits = $state<string[]>([])
  let savedSet = $state<string[]>([])   // circuits ayant une sauvegarde éditée
  let circuitId = $state('22_hard_5')
  let meta = $state<Meta | null>(null)
  let shape = $state<Shape | null>(null)
  let geom = $state<Geometry | null>(null)
  let pos = $state(0), steer = $state(0)
  let segData = $state<Segment | null>(null)
  let levels = $state<number[]>([])
  let rev = $state(0)

  /* ── vues ── */
  const seg = $derived(meta ? Math.floor(pos / meta.subpos_per_seg) % meta.nb_segments : 0)
  const markFrac = $derived(meta && meta.nb_subpos ? pos / meta.nb_subpos : 0)
  const planSvg = $derived(geom ? buildPlan(geom, markFrac) : '')
  let yaw = $state(0.5), pitch = $state(0.6)
  // édition proportionnelle (impact voisins, à somme nulle = local)
  let propMode = $state(false), propRadius = $state(5), propStrength = $state(1)
  // zone d'influence proportionnelle matérialisée sur le ruban (si mode actif)
  const propHL = $derived(propMode && meta
    ? { seg, radius: propRadius, strength: propStrength, nbSeg: meta.nb_segments }
    : null)
  const ribbonSvg = $derived(geom ? buildRibbon(geom, markFrac, yaw, pitch, undefined, undefined, propHL) : '')
  let drag = false, lx = 0, ly = 0
  function rdown(e: PointerEvent) { drag=true; lx=e.clientX; ly=e.clientY; (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId) }
  function rmove(e: PointerEvent) { if(!drag)return; yaw+=(e.clientX-lx)*0.01; pitch=Math.max(.12,Math.min(1.48,pitch+(e.clientY-ly)*.008)); lx=e.clientX; ly=e.clientY }
  function rup() { drag=false }
  function resetView() { yaw=0.5; pitch=0.6 }
  const timeStr = $derived(meta ? `${(markFrac*108).toFixed(1)} s / 108 s` : '')

  /* ── modales ── */
  let showNew = $state(false), newName = $state(''), newSegs = $state(64), newError = $state('')
  let showGen = $state(false)
  // générateur
  let genProfile = $state('oval')
  let genSeed = $state(42), genTurns = $state(0.6), genElev = $state(0.5)
  let genStatus = $state('')

  /* ── palette TO8 indexée 16 couleurs (index 1..16) ──
     LV[i] = niveaux TO8 [R4,G4,B4]. Le rendu utilise palette[idx_texture-1]. */
  let LV = $state<number[][]>([])
  let selColor = $state(0)
  let bgIdx = $state(3)   // index palette du FOND non-dessiné (défaut ~ herbe)
  let defaultPal: number[][] = []
  const bgRGB = $derived(LV[bgIdx] ? LV[bgIdx].map(l => levels[l] ?? 0) : [60, 130, 60])
  const lvl = (i: number) => levels[i] ?? 0
  const hex = (t: number[]) => t ? '#' + t.map(i => lvl(i).toString(16).padStart(2,'0').toUpperCase()).join('') : '#000000'
  const snapIdx = (v: number) => levels.reduce((bi:number,l:number,i:number)=>Math.abs(l-v)<Math.abs(levels[bi]-v)?i:bi, 0)

  function rgb2hsv(r:number,g:number,b:number){ r/=255;g/=255;b/=255
    const mx=Math.max(r,g,b),mn=Math.min(r,g,b),d=mx-mn; let h=0
    if(d){ if(mx===r)h=((g-b)/d)%6; else if(mx===g)h=(b-r)/d+2; else h=(r-g)/d+4; h*=60; if(h<0)h+=360 }
    return [Math.round(h), Math.round(mx?d/mx*100:0), Math.round(mx*100)] }
  function hsv2rgb(h:number,s:number,v:number){ s/=100;v/=100
    const c=v*s, x=c*(1-Math.abs((h/60)%2-1)), m=v-c; let r=0,g=0,b=0
    if(h<60){r=c;g=x}else if(h<120){r=x;g=c}else if(h<180){g=c;b=x}
    else if(h<240){g=x;b=c}else if(h<300){r=x;b=c}else{r=c;b=x}
    return [Math.round((r+m)*255),Math.round((g+m)*255),Math.round((b+m)*255)] }

  // hsvBuf = HSV AUTORITAIRE (précis, non-snappé) par swatch. Préserve la teinte
  // même quand S/V passent à 0 (sinon perdue par le round-trip RGB->HSV).
  let hsvBuf = $state<number[][]>([])
  function syncHSV(){ hsvBuf = LV.map(c => rgb2hsv(lvl(c[0]), lvl(c[1]), lvl(c[2]))) }
  function reHSV(){ if (LV[selColor]) hsvBuf[selColor] = rgb2hsv(lvl(LV[selColor][0]), lvl(LV[selColor][1]), lvl(LV[selColor][2])) }

  function setRGB255(r: number, g: number, b: number) {
    LV[selColor] = [snapIdx(r), snapIdx(g), snapIdx(b)]; reHSV(); rev++
  }
  function setHex(hexStr: string) {
    const s = hexStr.replace('#',''); if (s.length !== 6) return
    const r = parseInt(s.slice(0,2),16), g = parseInt(s.slice(2,4),16), b = parseInt(s.slice(4,6),16)
    if (!isNaN(r)&&!isNaN(g)&&!isNaN(b)) setRGB255(r,g,b)
  }
  // édition TSV : édite le buffer précis -> dérive le TO8 (snappé). Teinte préservée.
  function setHSV(which:number, val:number){
    const h = [...(hsvBuf[selColor] ?? [0,0,0])]; h[which] = val; hsvBuf[selColor] = h
    const [r,g,b] = hsv2rgb(h[0],h[1],h[2]); LV[selColor] = [snapIdx(r),snapIdx(g),snapIdx(b)]; rev++
  }
  // HSV réellement obtenu APRÈS snap TO8 (pour afficher la valeur "mappée")
  const mappedHSV = $derived(LV[selColor] ? rgb2hsv(lvl(LV[selColor][0]), lvl(LV[selColor][1]), lvl(LV[selColor][2])) : [0,0,0])

  // Sélecteur 2D : un PLAN de 16×16 couleurs TO8 exactes + une bande pour le 3e canal.
  // plane = quels 2 canaux forment le plan ; le 3e (profondeur) est la bande.
  const CHN = ['R', 'G', 'B']
  const AX: Record<string, number[]> = { RG: [0,1,2], RB: [0,2,1], GB: [1,2,0] }  // [x, y, profondeur]
  let plane = $state('RG')
  const planeAx = $derived(AX[plane])
  const depName = $derived(CHN[planeAx[2]])
  const triHex = (t: number[]) => `rgb(${lvl(t[0])},${lvl(t[1])},${lvl(t[2])})`
  // matrice : y de 15 (haut) à 0
  const gCells = $derived.by(() => {
    const c = LV[selColor]; if (!c) return []
    const [ax, ay, dep] = planeAx, dv = c[dep]
    const out: { x:number; y:number; hex:string; sel:boolean }[] = []
    for (let y = 15; y >= 0; y--)
      for (let x = 0; x < 16; x++) {
        const t = [0,0,0]; t[ax] = x; t[ay] = y; t[dep] = dv
        out.push({ x, y, hex: triHex(t), sel: c[ax] === x && c[ay] === y })
      }
    return out
  })
  function pickCell(x: number, y: number) {
    const c = LV[selColor]; if (!c) return
    const [ax, ay] = planeAx, t = [...c]; t[ax] = x; t[ay] = y; LV[selColor] = t; reHSV(); rev++
  }
  // bande de gris : 16 niveaux R=G=B
  const grayCells = $derived.by(() => {
    const c = LV[selColor]
    return Array.from({ length: 16 }, (_, i) => ({
      i, hex: `rgb(${lvl(i)},${lvl(i)},${lvl(i)})`, sel: !!c && c[0] === i && c[1] === i && c[2] === i
    }))
  })
  function pickGray(i: number) { if (!LV[selColor]) return; LV[selColor] = [i, i, i]; reHSV(); rev++ }

  // ── Rampes RGB : par canal, 16 patches (ce canal varie 0..15, autres courants) ──
  const rgbCells = $derived.by(() => {
    const c = LV[selColor]; if (!c) return [[], [], []]
    return [0, 1, 2].map(ch => Array.from({ length: 16 }, (_, i) => {
      const t = [...c]; t[ch] = i
      return { i, hex: triHex(t), sel: c[ch] === i }
    }))
  })
  function pickRGB(ch: number, i: number) {
    const c = LV[selColor]; if (!c) return
    const t = [...c]; t[ch] = i; LV[selColor] = t; reHSV(); rev++
  }
  // ── Rampes TSV : 16 pas le long de chaque composante (T 0-360, S/V 0-100),
  //    couleur affichée = résultat SNAPPÉ TO8 (honnête sur ce qu'on obtient). ──
  const HSV_MAX = [360, 100, 100]
  const hsvCells = $derived.by(() => {
    const h = hsvBuf[selColor]; if (!h) return [[], [], []]
    return [0, 1, 2].map(comp => Array.from({ length: 16 }, (_, i) => {
      const hh = [...h]; hh[comp] = (i / 15) * HSV_MAX[comp]
      const [r, g, b] = hsv2rgb(hh[0], hh[1], hh[2])
      return { i, hex: triHex([snapIdx(r), snapIdx(g), snapIdx(b)]),
               sel: Math.round((h[comp] / HSV_MAX[comp]) * 15) === i }
    }))
  })
  function pickHSV(comp: number, i: number) { setHSV(comp, (i / 15) * HSV_MAX[comp]) }
  const RGBN = ['R', 'G', 'B'], HSVN = ['T', 'S', 'V']

  // glisser dans les grilles
  let dragging = false
  // pipette écran (API EyeDropper, Chromium) : capture une couleur à l'écran -> snap TO8
  async function pickScreen() {
    const ED = (window as any).EyeDropper
    if (!ED) { alert('Pipette écran non supportée par ce navigateur (Chrome/Edge requis).'); return }
    try { const r = await new ED().open(); setHex(r.sRGBHex) } catch { /* annulé */ }
  }

  /* ── presets de palette (localStorage) ── */
  let presets = $state<Record<string, number[][]>>({})
  let presetSel = $state('')
  function loadPresets(){ try{ presets = JSON.parse(localStorage.getItem('lce_palettes')||'{}') }catch{ presets={} } }
  function savePreset(){ const n = prompt('Nom du preset', presetSel||'Ma palette'); if(!n) return
    presets = {...presets, [n]: LV.map(c=>[...c])}; localStorage.setItem('lce_palettes', JSON.stringify(presets)); presetSel=n }
  function applyPreset(n:string){ if(presets[n]){ LV = presets[n].map(c=>[...c]); syncHSV(); presetSel=n; rev++ } }
  function deletePreset(){ if(!presetSel||!presets[presetSel])return; const p={...presets}; delete p[presetSel]
    presets=p; localStorage.setItem('lce_palettes',JSON.stringify(presets)); presetSel='' }
  function resetPalette(){ LV = defaultPal.map(c=>[...c]); syncHSV(); presetSel=''; rev++ }

  /* ── édition ── */
  const CURVE_MAX = 8, PITCH_MAX = 8

  /* ── transport play ── */
  let playing = $state(false)
  let playSpeed = $state(6)    // nib/s (1-26)
  let playTimer = 0
  let posF = 0                 // accumulateur flottant (défilement régulier)
  const PLAY_MS = 120
  function playTick() {
    if (!meta) return
    posF = (posF + playSpeed * (PLAY_MS / 1000)) % meta.nb_subpos
    pos = Math.floor(posF)     // pos entier -> phase = pos*256 défile les bandes
  }
  function togglePlay() {
    playing = !playing
    clearInterval(playTimer)
    if (playing) { posF = pos; playTimer = setInterval(playTick, PLAY_MS) as unknown as number }
  }
  function backToStart() { pos = 0; posF = 0; playing = false; clearInterval(playTimer) }
  $effect(() => { if (!playing) clearInterval(playTimer) })

  /* ── resize ── */
  let nbSegsEdit = $state(64)
  $effect(() => { if (meta) nbSegsEdit = meta.nb_segments })
  let resizeTimer = 0
  async function doResize(nb: number) {
    clearTimeout(resizeTimer)
    resizeTimer = setTimeout(async () => {
      const r = await api.resizeCircuit(circuitId, nb)
      if (meta) meta = { ...meta, nb_segments: r.nb_segments, nb_subpos: r.nb_subpos }
      if (meta && pos >= meta.nb_subpos) pos = 0
      await refreshViews()
    }, 200) as unknown as number
  }

  /* ── chargement ── */
  async function loadCircuit(c: string) {
    meta = await api.getMeta(c); shape = await api.getShape(c)
    geom = await api.getGeometry(c)
    pos = 0; posF = 0; playSpeed = 26   // début de piste (slider + marqueurs 2D/3D) + vitesse max
  }
  async function refreshViews() {
    shape = await api.getShape(circuitId); geom = await api.getGeometry(circuitId); rev++
  }
  async function refreshCircuits() {
    const r = await api.getCircuits(); circuits = r.circuits; savedSet = r.saved
  }
  // sauvegarde les édits courants (saved/{cid}.json — jamais le natif)
  async function saveCircuit() {
    await api.saveCircuit(circuitId); await refreshCircuits()
  }
  // déploie le circuit dans l'engine + patche la config (bascule = déployer la cible)
  let deploying = $state(false)
  async function deployCircuit() {
    if (!confirm(`Déployer « ${circuitId} » comme circuit ACTIF ?\nGénère objects/circuits/${circuitId}/ et patche main.properties / main.asm / road-engine.asm.`)) return
    deploying = true
    try {
      await api.saveCircuit(circuitId)                 // fige les édits courants
      const r = await api.deployCircuit(circuitId, LV)
      alert(`✓ ${r.circuit} déployé (${r.nchunks} chunks, ${r.frames} frames).\nRebuild le mode road-stream pour jouer ce circuit.`)
    } catch (e) { alert('Échec du déploiement : ' + e) }
    finally { deploying = false }
  }
  // exporte le zip (piste native .asm + stream .bin/objets + textures reteintées)
  let exporting = $state(false)
  async function exportCircuit() {
    exporting = true
    try {
      await api.saveCircuit(circuitId)               // fige les édits courants côté backend
      const a = document.createElement('a')
      a.href = api.exportUrl(circuitId, LV)
      a.download = `${circuitId}.zip`
      document.body.appendChild(a); a.click(); a.remove()
    } finally { setTimeout(() => (exporting = false), 1200) }
  }
  // réinitialise aux données natives (supprime la sauvegarde ; custom -> blanc)
  async function resetCircuit() {
    if (!confirm(`Réinitialiser « ${circuitId} » aux données natives ? Les modifs sauvegardées seront perdues.`)) return
    await api.resetCircuit(circuitId)
    await loadCircuit(circuitId)
    await refreshCircuits()
  }

  /* ── nouveau circuit ── */
  async function createCircuit() {
    newError = ''
    try {
      const r = await api.newCircuit(newName.trim(), newSegs)
      await refreshCircuits()
      circuitId = r.id; await loadCircuit(r.id)
      showNew = false; newName = ''
    } catch(e) { newError = String(e) }
  }

  /* ── générateur ── */
  const PROFILES: Record<string, { label: string; icon: string }> = {
    oval:      { label: 'Ovale',     icon: '⭕' },
    technique: { label: 'Technique', icon: '🔀' },
    flowing:   { label: 'Flowing',   icon: '〰️' },
    street:    { label: 'Street',    icon: '🔲' },
    montagne:  { label: 'Montagne',  icon: '⛰️' },
    hillclimb: { label: 'Hillclimb', icon: '📈' },
  }
  async function runGenerator() {
    genStatus = '⏳ génération…'
    try {
      await api.generateCircuit(circuitId, genProfile, genSeed, genTurns, genElev)
      await refreshViews()
      genStatus = '✓ généré'
      setTimeout(() => { genStatus = '' }, 2000)
    } catch(e) { genStatus = '✗ erreur' }
  }
  function randomSeed() { genSeed = Math.floor(Math.random() * 99999) }

  /* ── édition segment ── */
  let inflight = false, pending: api.SegPatch | null = null
  // édition directe (sans prop)
  async function liveCommit(patch: api.SegPatch) {
    pending = { ...pending, ...patch }
    if (inflight) return
    inflight = true
    while (pending) {
      const p = pending; pending = null
      segData = await api.patchSegment(circuitId, seg, p)
      await refreshViews()
    }
    inflight = false
  }
  async function commit(patch: api.SegPatch) {
    segData = await api.patchSegment(circuitId, seg, patch); await refreshViews()
  }
  // proportionnel : debounced (côté serveur modifie N segments)
  let propTimer = 0
  let propBaseV = { curve: 0, pitch: 0 }   // valeur au début du drag
  function propStart() {
    if (segData) propBaseV = { curve: segData.delta_curve, pitch: segData.delta_pitch }
  }
  async function livePropCommit(field: 'curve'|'pitch', value: number) {
    clearTimeout(propTimer)
    propTimer = setTimeout(async () => {
      shape = await api.propEdit(circuitId, seg, field, value, propRadius, propStrength)
      geom = await api.getGeometry(circuitId); rev++
    }, 80) as unknown as number
  }

  $effect(() => { const s = seg; if (meta) api.getSegment(circuitId, s).then(d => (segData = d)) })
  function gotoSeg(i: number) { if (meta) pos = ((i%meta.nb_segments)+meta.nb_segments)%meta.nb_segments*meta.subpos_per_seg }
  onMount(async () => {
    await refreshCircuits()
    levels = (await api.getPalette()).levels
    const pd = await api.getPaletteDefault()
    defaultPal = pd.levels
    LV = defaultPal.map(l => [...l])
    syncHSV()
    loadPresets()
    // fond par défaut = la couleur la plus verte (herbe) parmi les 16
    bgIdx = LV.reduce((best, c, i) => {
      const score = (lvl(c[1]) - lvl(c[0]) - lvl(c[2]))
      const bs = (lvl(LV[best][1]) - lvl(LV[best][0]) - lvl(LV[best][2]))
      return score > bs ? i : best
    }, 0)
    await loadCircuit(circuitId)
  })
</script>

<svelte:window onpointerup={() => (dragging = false)} />
<div class="app">
  <div class="topbar">
    <h1>🏁 Lotus Circuit Editor</h1>
    <select bind:value={circuitId} onchange={() => loadCircuit(circuitId)}>
      {#each circuits as c}<option value={c}>{savedSet.includes(c) ? '● ' : ''}{c}</option>{/each}
    </select>
    <button class="btn ico-btn" title="sauvegarder les modifications (saved/{circuitId}.json)" onclick={saveCircuit}><Save size={14}/> Sauver</button>
    <span class="ico" title="réinitialiser aux données natives" role="button" tabindex="0" onclick={resetCircuit} onkeydown={()=>{}}><RotateCcw size={14}/></span>
    <button class="btn ico-btn" onclick={() => { showNew=true; newName=''; newError='' }}><Plus size={14}/> Nouveau</button>
    <button class="btn ico-btn" onclick={() => (showGen = !showGen)} style={showGen ? 'background:var(--accent);color:#06101f' : ''}><Wand2 size={14}/> Générateur</button>
    <span class="sp"></span>
    <button class="btn ico-btn" title="déployer comme circuit actif (génère objects/circuits/ + patche la config)" onclick={deployCircuit} disabled={deploying} style="background:var(--accent);color:#06101f"><Rocket size={14}/> {deploying ? 'Déploiement…' : 'Déployer'}</button>
    <button class="btn ico-btn" title="exporter un zip : piste native .asm + données stream + textures" onclick={exportCircuit} disabled={exporting}><Package size={14}/> {exporting ? 'Export…' : 'Exporter'}</button>
  </div>

  <!-- modale nouveau circuit -->
  {#if showNew}
  <div style="position:fixed;inset:0;background:rgba(0,0,0,.65);display:flex;align-items:center;justify-content:center;z-index:100">
    <div style="background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:24px 28px;min-width:320px;display:flex;flex-direction:column;gap:14px">
      <span style="font-size:13px;font-weight:600">Nouveau circuit</span>
      <div style="display:flex;flex-direction:column;gap:6px">
        <label for="nc-name" style="font-size:11px;color:var(--dim)">Nom</label>
        <input id="nc-name" bind:value={newName} placeholder="circuit_01 (vide = auto)"
          style="background:#101319;border:1px solid var(--line);color:var(--ink);border-radius:6px;padding:6px 9px;font-size:13px;font-family:var(--mono)"
          onkeydown={(e) => e.key==='Enter' && createCircuit()} />
      </div>
      <div style="display:flex;flex-direction:column;gap:6px">
        <label for="nc-segs" style="font-size:11px;color:var(--dim)">Segments : {newSegs}</label>
        <input id="nc-segs" type="range" min="16" max="200" step="8" bind:value={newSegs} style="accent-color:var(--accent)" />
      </div>
      {#if newError}<span style="font-size:11px;color:var(--red)">{newError}</span>{/if}
      <div style="display:flex;gap:8px;justify-content:flex-end">
        <button class="btn" onclick={() => (showNew=false)}>Annuler</button>
        <button class="btn acc" onclick={createCircuit}>Créer</button>
      </div>
    </div>
  </div>
  {/if}

  <div class="main">
    <!-- LEFT : palette -->
    <div class="col">
      <div class="panel pal" style="flex:1">
        <div class="h"><span class="dot" style="background:var(--amber)"></span>Palette
          <span class="r"><span class="ico" title="réinitialiser la palette par défaut" role="button" tabindex="0" onclick={resetPalette} onkeydown={()=>{}}><RotateCcw size={13}/></span></span></div>
        <!-- presets -->
        <div style="display:flex;gap:5px;align-items:center;padding:7px 9px;border-bottom:1px solid #20232b">
          <select bind:value={presetSel} onchange={() => applyPreset(presetSel)} style="flex:1;background:var(--panel2);color:var(--ink);border:1px solid var(--line);border-radius:5px;font-size:11px;padding:3px 5px">
            <option value="">— preset —</option>
            {#each Object.keys(presets) as n}<option value={n}>{n}</option>{/each}
          </select>
          <span class="ico" title="enregistrer la palette comme preset" role="button" tabindex="0" onclick={savePreset} onkeydown={()=>{}}><Save size={13}/></span>
          {#if presetSel}<span class="ico" title="supprimer le preset" role="button" tabindex="0" onclick={deletePreset} onkeydown={()=>{}}><Trash2 size={13}/></span>{/if}
        </div>
        <!-- 16 swatches (index 1..16), toujours affichés -->
        <div class="grid">
          {#each LV as t, i}
            <div class="sw" class:sel={i===selColor} title="index {i+1}{i===bgIdx ? ' (fond)' : ''}"
              style="background:{hex(t)}; {i===bgIdx ? 'box-shadow:0 0 0 2px var(--green)' : ''}"
              onclick={() => (selColor=i)} role="button" tabindex="0" onkeydown={()=>{}}></div>
          {/each}
        </div>
        <div style="padding:5px 10px 7px;border-bottom:1px solid #20232b;display:flex;align-items:center;gap:8px">
          <span style="font-size:11px;color:var(--dim)">Index {selColor+1}</span>
          <button class="btn" style="font-size:10px;padding:3px 12px;margin-left:auto" onclick={() => (bgIdx = selColor)}>Fond</button>
        </div>
        {#if LV[selColor]}
        <div class="ed" style="overflow:auto">
          <!-- grand aperçu de la couleur sélectionnée -->
          <div style="height:54px;border-radius:7px;border:1px solid var(--line);background:{hex(LV[selColor])};box-shadow:inset 0 0 0 1px #0006;margin-bottom:9px"></div>
          <div class="hexrow">
            <button class="ico" title="pipette écran — capturer une couleur à l'écran" onclick={pickScreen}><Pipette size={13}/></button>
            <input type="text" value={hex(LV[selColor])} onchange={(e) => setHex(e.currentTarget.value)} style="flex:1" />
          </div>
          <!-- bande de gris (R=G=B) en tête — sans label -->
          <div class="ramps">
            <div class="ramp">
              {#each grayCells as cell}
                <div class:sel={cell.sel} title="gris {cell.i} · {lvl(cell.i)}" style="background:{cell.hex}"
                  onpointerdown={() => { dragging = true; pickGray(cell.i) }} onpointerenter={() => dragging && pickGray(cell.i)}
                  role="button" tabindex="0" onkeydown={()=>{}}></div>
              {/each}
            </div>
          </div>
          <!-- rampes RGB puis TSV : patches sélectionnables (clic + glisser), sans label -->
          <div class="ramps">
            {#each rgbCells as strip, ch}
              <div class="ramp">
                {#each strip as cell}
                  <div class:sel={cell.sel} title="{RGBN[ch]} {cell.i} · {lvl(cell.i)}" style="background:{cell.hex}"
                    onpointerdown={() => { dragging = true; pickRGB(ch, cell.i) }} onpointerenter={() => dragging && pickRGB(ch, cell.i)}
                    role="button" tabindex="0" onkeydown={()=>{}}></div>
                {/each}
              </div>
            {/each}
          </div>
          <div class="ramps">
            {#each hsvCells as strip, comp}
              <div class="ramp">
                {#each strip as cell}
                  <div class:sel={cell.sel} title="{HSVN[comp]} {Math.round(cell.i/15*HSV_MAX[comp])}" style="background:{cell.hex}"
                    onpointerdown={() => { dragging = true; pickHSV(comp, cell.i) }} onpointerenter={() => dragging && pickHSV(comp, cell.i)}
                    role="button" tabindex="0" onkeydown={()=>{}}></div>
                {/each}
              </div>
            {/each}
          </div>
          <!-- sélecteur 2D : plan de couleurs TO8 exactes + bande pour le 3e canal -->
          <div style="font-size:10px;color:var(--dim);margin:9px 0 3px;display:flex;align-items:center;gap:6px">
            <span>Plan</span>
            <select bind:value={plane} style="background:var(--panel2);color:var(--ink);border:1px solid var(--line);border-radius:4px;font-size:10px;padding:1px 4px">
              <option value="RG">R × G</option><option value="RB">R × B</option><option value="GB">G × B</option>
            </select>
            <span style="margin-left:auto;font-family:var(--mono)">{depName} = {LV[selColor][planeAx[2]]} · {lvl(LV[selColor][planeAx[2]])}</span>
          </div>
          <div style="display:grid;grid-template-columns:repeat(16,1fr);gap:1px;aspect-ratio:1;border:1px solid var(--line);border-radius:5px;overflow:hidden;padding:2px;background:#000;touch-action:none">
            {#each gCells as cell}
              <div title="{CHN[planeAx[0]]}{cell.x} {CHN[planeAx[1]]}{cell.y}" style="background:{cell.hex};cursor:pointer; {cell.sel ? 'box-shadow:0 0 0 2px #fff, inset 0 0 0 1px #000;z-index:1;position:relative' : ''}"
                onpointerdown={() => { dragging = true; pickCell(cell.x, cell.y) }} onpointerenter={() => dragging && pickCell(cell.x, cell.y)}
                role="button" tabindex="0" onkeydown={()=>{}}></div>
            {/each}
          </div>
        </div>
        {/if}
      </div>
    </div>

    <!-- CENTER : ruban + sim + transport -->
    <div class="col">
      <!-- panneau générateur (inline sous le ruban quand ouvert) -->
      {#if showGen}
      <div class="panel" style="flex:0 0 auto">
        <div class="h"><span class="dot" style="background:var(--green)"></span>Générateur procédural
          <span class="r"><span style="font-size:11px;color:var(--green)">{genStatus}</span></span></div>
        <div style="padding:10px 12px;display:flex;flex-direction:column;gap:10px">
          <!-- profils -->
          <div style="display:flex;gap:6px;flex-wrap:wrap">
            {#each Object.entries(PROFILES) as [k,v]}
              {@const Ico = PROF_ICONS[k]}
              <button onclick={() => (genProfile=k)} style="flex:1;min-width:80px;display:flex;flex-direction:column;align-items:center;gap:3px;padding:7px 4px;border-radius:7px;border:1px solid {genProfile===k ? 'var(--accent)' : 'var(--line)'};background:{genProfile===k ? '#1a2a3a' : 'var(--panel2)'};color:{genProfile===k ? 'var(--accent)' : 'var(--dim)'};font-size:11px;cursor:pointer">
                <Ico size={16}/>{v.label}
              </button>
            {/each}
          </div>
          <!-- paramètres -->
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px 14px">
            <div><label for="g-turns" style="font-size:10px;color:var(--dim)">Virages {genTurns.toFixed(1)}</label><br>
              <input id="g-turns" type="range" min="0" max="1" step="0.1" bind:value={genTurns} style="width:100%;accent-color:var(--accent)"/></div>
            <div><label for="g-elev" style="font-size:10px;color:var(--dim)">Relief {genElev.toFixed(1)}</label><br>
              <input id="g-elev" type="range" min="0" max="1" step="0.1" bind:value={genElev} style="width:100%;accent-color:var(--green)"/></div>
            <div style="display:flex;align-items:center;gap:6px">
              <label for="g-seed" style="font-size:10px;color:var(--dim)">Graine</label>
              <input id="g-seed" type="number" bind:value={genSeed} style="flex:1;background:#101319;border:1px solid var(--line);color:var(--ink);border-radius:5px;padding:3px 6px;font-family:var(--mono);font-size:11px"/>
              <button onclick={randomSeed} title="graine aléatoire" style="display:inline-flex;align-items:center;padding:4px 7px;border-radius:5px;background:var(--panel2);border:1px solid var(--line);color:var(--dim);cursor:pointer"><Dices size={14}/></button>
            </div>
            <button class="btn acc ico-btn" style="align-self:end" onclick={runGenerator}><Sparkles size={14}/> Générer</button>
          </div>
        </div>
      </div>
      {/if}

      <div class="panel" style="flex:1.5">
        <div class="h"><span class="dot" style="background:var(--green)"></span>Ruban 3D
          <span class="r"><span class="ico" title="réinitialiser la vue" role="button" tabindex="0" onclick={resetView} onkeydown={()=>{}}><RotateCcw size={13}/></span></span></div>
        <div class="b" style="cursor:grab;touch-action:none" role="application" aria-label="Vue 3D orientable"
          onpointerdown={rdown} onpointermove={rmove} onpointerup={rup} onpointerleave={rup}>{@html ribbonSvg}</div>
      </div>
      <div class="panel" style="flex:1.05">
        <div class="h"><span class="dot" style="background:var(--amber)"></span>Simulateur
          <span class="r"><span class="btn">✓ pipeline</span></span></div>
        <div class="b" style="display:flex;align-items:center;justify-content:center;overflow:hidden">
          <img class="simimg" src={api.renderUrl(circuitId, pos, steer, rev, LV, bgRGB)} alt="frame" />
        </div>
      </div>
      <div class="transport">
        <button class="tbtn" onclick={backToStart} title="Retour au début"><SkipBack size={14}/></button>
        <button class="tbtn {playing ? '' : 'play'}" onclick={togglePlay} title={playing ? 'Pause' : 'Play'}>
          {#if playing}<Pause size={14}/>{:else}<Play size={14}/>{/if}
        </button>
        <div class="ctl" title="Vitesse de défilement (nib/s)">
          <input type="range" min="1" max="26" step="1" bind:value={playSpeed} style="width:64px;accent-color:var(--accent)" />
          <span style="font-family:var(--mono);font-size:10px;color:var(--dim)">{playSpeed}</span>
        </div>
        <div class="ctl">dir<input type="range" min="-192" max="192" bind:value={steer} /></div>
        <input class="scrub" type="range" min="0" max={meta ? meta.nb_subpos-1 : 0} bind:value={pos} />
        <span style="font-family:var(--mono);font-size:11px;color:var(--dim)">{seg}/{meta?.nb_segments ?? '—'} · {timeStr}</span>
      </div>
    </div>

    <!-- RIGHT : plan | resize | segment -->
    <div class="col">
      <div class="panel" style="flex:0 0 220px">
        <div class="h"><span class="dot"></span>Vue de dessus</div>
        <div class="b">{@html planSvg}</div>
      </div>

      <div class="panel" style="flex:0 0 auto">
        <div class="h"><span class="dot" style="background:var(--dim)"></span>Segments
          <span class="r" style="font-family:var(--mono);font-size:12px;color:var(--ink)">{nbSegsEdit} / 200</span></div>
        <div style="padding:8px 10px">
          <input type="range" min="1" max="200" step="1" bind:value={nbSegsEdit}
            oninput={() => doResize(nbSegsEdit)} style="width:100%;accent-color:var(--accent)" />
        </div>
      </div>

      <div class="panel seg" style="flex:1">
        <div class="h"><span class="dot" style="background:var(--amber)"></span>Segment
          <span class="r">
            <span class="ico" onclick={() => gotoSeg(seg-1)} role="button" tabindex="0" onkeydown={()=>{}}><ChevronLeft size={14}/></span>
            <b style="font-family:var(--mono);font-size:11px;color:var(--ink)">{seg}</b>
            <span class="ico" onclick={() => gotoSeg(seg+1)} role="button" tabindex="0" onkeydown={()=>{}}><ChevronRight size={14}/></span>
          </span></div>
        <div class="b">
          {#if segData}
            <div class="grp">
              <div class="lbl"><span>Courbure</span><b>Δ {segData.delta_curve}</b></div>
              <input type="range" min={-CURVE_MAX} max={CURVE_MAX} step="1" value={segData.delta_curve}
                onpointerdown={propStart}
                oninput={(e) => {
                  if (segData) segData.delta_curve = +e.currentTarget.value
                  if (propMode) livePropCommit('curve', +e.currentTarget.value)
                  else liveCommit({ delta_curve: +e.currentTarget.value })
                }} />
            </div>
            <div class="grp">
              <div class="lbl"><span>Pente</span><b>Δ {segData.delta_pitch}</b></div>
              <input type="range" min={-PITCH_MAX} max={PITCH_MAX} step="1" value={segData.delta_pitch}
                onpointerdown={propStart}
                oninput={(e) => {
                  if (segData) segData.delta_pitch = +e.currentTarget.value
                  if (propMode) livePropCommit('pitch', +e.currentTarget.value)
                  else liveCommit({ delta_pitch: +e.currentTarget.value })
                }} />
            </div>
            <div class="grp">
              <div class="lbl"><span>Horizon (min_y)</span><b>{segData.min_y}</b></div>
            </div>
            <div class="flags">
              <span class="tog" class:on={segData.flags.start} role="button" tabindex="0"
                onclick={() => commit({ start: !segData!.flags.start })} onkeydown={() => {}}>START</span>
              <span class="tog" class:on={segData.flags.pit} role="button" tabindex="0"
                onclick={() => commit({ pit: !segData!.flags.pit })} onkeydown={() => {}}>PIT</span>
            </div>

            <!-- Section dédiée : édition proportionnelle (impact sur les voisins) -->
            <div class="grp" style="border-top:1px solid var(--line)">
              <div class="lbl" style="margin-bottom:8px">
                <span style="display:flex;align-items:center;gap:5px"><Target size={12}/> Proportionnel</span>
                <button class="ico-btn" onclick={() => (propMode=!propMode)}
                  style="padding:2px 9px;border-radius:5px;border:1px solid {propMode ? 'var(--accent)' : 'var(--line)'};background:{propMode ? '#1a2a3a' : 'var(--panel2)'};color:{propMode ? 'var(--accent)' : 'var(--dim)'};font-size:10px;cursor:pointer">
                  {propMode ? 'actif' : 'inactif'}
                </button>
              </div>
              <div style="opacity:{propMode ? 1 : 0.45};pointer-events:{propMode ? 'auto' : 'none'};display:flex;flex-direction:column;gap:9px">
                <div>
                  <div style="display:flex;justify-content:space-between;font-size:11px;color:var(--dim);margin-bottom:3px"><span>Rayon</span><span style="font-family:var(--mono);color:var(--ink)">{propRadius} seg</span></div>
                  <input type="range" min="1" max="60" bind:value={propRadius} style="width:100%;accent-color:var(--accent)" />
                </div>
                <div>
                  <div style="display:flex;justify-content:space-between;font-size:11px;color:var(--dim);margin-bottom:3px"><span>Force</span><span style="font-family:var(--mono);color:var(--ink)">{Math.round(propStrength*100)}%</span></div>
                  <input type="range" min="0" max="1" step="0.05" bind:value={propStrength} style="width:100%;accent-color:var(--amber)" />
                </div>
              </div>
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>
</div>
