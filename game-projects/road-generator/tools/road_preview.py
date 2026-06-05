#!/usr/bin/env python3
"""
road_preview.py — Preview LIVE (Tkinter) couplé au convertisseur.

Utilise EXACTEMENT les mêmes project()/render() que road_bake.py (le bake) :
ce que tu vois ici = ce qui sera baké. Zéro ré-implémentation, zéro divergence.

Contrôles :
  - slider Vitesse (nibbles/s ; vitesse max jeu ≈ 26)
  - slider FPS cible
  - slider Step division /S  (la géométrie est quantifiée au /S = le cache)
  - flèches ← → : direction

Lancer AVEC LE VENV (qui a tkinter + Pillow) :
  .venv/bin/python3 tools/road_preview.py [circuit_id]     (def 22_hard_5)

Selftest (sans GUI, 1 frame) :
  .venv/bin/python3 tools/road_preview.py --selftest
"""
import sys, time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import road_bake as rb
from simulate_dfr_pipeline import parse_circuit, sparse_projection

ROOT = Path(__file__).resolve().parent.parent
SUBPOS = 16
GAME_MAX_SPEED = 26   # nibbles/s ≈ vitesse max jeu (5×$1AA×50/4096)


def list_circuits():
    return sorted(p.stem for p in (ROOT / 'engine/circuits').glob('*.asm'))


class Preview:
    def __init__(self, circuit='22_hard_5'):
        self.assets = rb.load_assets()
        self.pos = 0.0
        self.steer = 0.0
        self.keys = set()
        self.load_circuit(circuit)

    def load_circuit(self, circuit):
        """(Re)charge un circuit : segments + lignes utiles (pour la taille data)."""
        self.circuit = circuit
        self.segs = parse_circuit(ROOT / 'engine/circuits' / f'{circuit}.asm', circuit)
        self.nb_seg = rb.circuit_nb_segments(circuit)
        self.npos = self.nb_seg * SUBPOS
        self.useful = [96 - sparse_projection(self.segs, p // SUBPOS, p % SUBPOS,
                                              self.assets['horizon'], self.assets['scaling'])[1]
                       for p in range(self.npos)]
        self.pos = self.pos % self.npos

    def datasize(self, S):
        idxs = range(0, self.npos, S)
        return len(idxs), sum(self.useful[p] * 6 + 1 for p in idxs)

    def frame(self, S, speed, fps):
        """1 game-frame : avance, quantifie /S, projette, rend. Retourne (PIL img, infos)."""
        frameDt = 1.0 / fps
        # steering : se déplace tant qu'on appuie, RESTE en place sinon (pas de recentrage auto)
        if 'Left' in self.keys:
            self.steer = max(self.steer - 12, -150)
        elif 'Right' in self.keys:
            self.steer = min(self.steer + 12, 150)
        self.pos = (self.pos + speed * frameDt) % self.npos
        geom = int(self.pos // S) * S                 # géométrie QUANTIFIÉE /S (= le cache)
        dense, min_y = rb.project_pos(self.segs, self.nb_seg, geom, self.assets)
        # phase live (bandes dark/light qui défilent) = position CONTINUE (pas quantifiée)
        # ~ (track_pos.lower>>4)&$7FF : +256 par nibble parcouru, conforme DrawFrameRoad.
        phase = int(self.pos * 256) & 0x7FF
        img = rb.render(dense, int(self.steer), phase)
        n, blob = self.datasize(S)
        adv = speed / fps
        info = {
            'seg': geom // SUBPOS, 'min_y': min_y, 'lines': 96 - min_y,
            'adv': adv, 'snap': S / 2, 'lap': (self.npos / speed) if speed > 0.5 else None,
            'positions': n, 'bytes': blob, 'steer': int(self.steer),
            'verdict': 'palier <= avance -> INVISIBLE' if S / 2 <= adv else 'palier > avance -> stepping VISIBLE',
        }
        return img, info


# ── GUI Tkinter ─────────────────────────────────────────────────────────────
def raise_window(root):
    """Force la fenêtre au premier plan (macOS : sinon elle s'ouvre derrière)."""
    root.update_idletasks()
    root.deiconify()
    root.lift()
    root.attributes('-topmost', True)
    root.after(300, lambda: root.attributes('-topmost', False))
    try:
        root.focus_force()
    except Exception:
        pass


def run_gui(circuit):
    import tkinter as tk
    import traceback
    from PIL import Image, ImageTk
    print(f"[preview] init circuit {circuit} … (précompute ~0.5s)")
    pv = Preview(circuit)
    print("[preview] fenêtre Tkinter en cours d'ouverture — regarde au premier plan / dans le Dock")

    root = tk.Tk()
    root.title(f"Road Preview — {circuit} (project/render = road_bake, byte-exact)")
    root.configure(bg='#111')

    # --- row 0 : sélecteur de circuit ---
    topf = tk.Frame(root, bg='#111')
    topf.grid(row=0, column=0, columnspan=3, sticky='w', padx=8, pady=(8, 0))
    tk.Label(topf, text='Circuit :', fg='#9cf', bg='#111').pack(side='left')
    cvar = tk.StringVar(value=circuit)

    def on_circuit(name):
        print(f"[preview] chargement circuit {name} …")
        pv.load_circuit(name)
        root.title(f"Road Preview — {name}")
    om = tk.OptionMenu(topf, cvar, *list_circuits(), command=on_circuit)
    om.configure(bg='#222', fg='#ffd', highlightthickness=0, width=16)
    om.pack(side='left', padx=6)

    # --- row 1 : canvas 160×96 -> 640×192 (NEAREST = pixels 2:1 nets, BM16 TO8) ---
    DW, DH = 640, 192
    canvas = tk.Canvas(root, width=DW, height=DH, bg='#000', highlightthickness=0)
    canvas.grid(row=1, column=0, columnspan=3, padx=8, pady=8)
    cimg = canvas.create_image(0, 0, anchor='nw')

    # --- rows 2-3 : sliders ---
    def mkslider(col, label, frm, to, init):
        tk.Label(root, text=label, fg='#9cf', bg='#111').grid(row=2, column=col, sticky='w', padx=8)
        s = tk.Scale(root, from_=frm, to=to, orient='horizontal', length=200,
                     bg='#222', fg='#ffd', troughcolor='#333', highlightthickness=0)
        s.set(init)
        s.grid(row=3, column=col, padx=8)
        return s

    spd = mkslider(0, 'Vitesse / anim lignes (max jeu~26)', 0, 60, 20)
    fps = mkslider(1, 'FPS cible', 3, 25, 12)
    step = mkslider(2, 'Step division /S', 1, 48, 1)

    # --- row 4 : infos. Taille FIXE (width chars + height lignes + anchor nw)
    #     -> le layout ne bouge plus quand le texte change. Police monospace. ---
    info = tk.Label(root, text='', fg='#ddd', bg='#111', justify='left', anchor='nw',
                    font=('Menlo', 12), width=72, height=4)
    info.grid(row=4, column=0, columnspan=3, sticky='w', padx=8, pady=6)

    def on_key(e, down):
        k = e.keysym
        if k in ('Left', 'Right'):
            (pv.keys.add if down else pv.keys.discard)(k)
    root.bind('<KeyPress>', lambda e: on_key(e, True))
    root.bind('<KeyRelease>', lambda e: on_key(e, False))
    canvas.focus_set()

    state = {'img': None, 'n': 0}

    def loop():
        try:
            S = int(step.get()); speed = spd.get(); fpsv = fps.get()
            img, nf = pv.frame(S, speed, fpsv)
            disp = img.resize((DW, DH), Image.NEAREST)   # ×4 h, ×2 v = 2:1
            state['img'] = ImageTk.PhotoImage(disp)        # garder la ref (sinon GC)
            canvas.itemconfig(cimg, image=state['img'])
            canvas.image = state['img']                    # ceinture+bretelles anti-GC
            lap = f"{nf['lap']:.0f}s" if nf['lap'] else '--'
            info.config(text=(
                f"seg {nf['seg']:>3d}/{pv.nb_seg:<3d}  horizon {nf['min_y']:>2d}  lignes {nf['lines']:>2d}/96  steer {nf['steer']:>+4d}  tour {lap:>5s}\n"
                f"avance {nf['adv']:5.2f} nib/frame   snap {nf['snap']:4.1f}   {nf['verdict']:<34s}\n"
                f"DATA /S={S:<2d}: {nf['positions']:>4d} pos   {nf['bytes']/1024:6.1f} Ko brut   {nf['bytes']/3/1024:6.1f} Ko ZX0\n"
                f"        RAM 512Ko (decompresse) : {'OK ' if nf['bytes']<=512*1024 else 'NON'}"
            ))
            state['n'] += 1
            if state['n'] == 1:
                print("[preview] 1ère frame affichée ✓ (si tu ne vois rien, la fenêtre est cachée derrière)")
        except Exception:
            import traceback; traceback.print_exc()
        root.after(max(1, int(1000 / fpsv)), loop)    # cadence = fps cible (on VOIT la saccade)

    raise_window(root)
    loop()
    root.mainloop()


def selftest(circuit):
    pv = Preview(circuit)
    img, nf = pv.frame(S=4, speed=20, fps=12)
    print(f"selftest OK : circuit={circuit} nb_seg={pv.nb_seg} npos={pv.npos}")
    print(f"  image={img.size} seg={nf['seg']} lignes={nf['lines']} verdict='{nf['verdict']}'")
    print(f"  DATA /4 : {nf['positions']} pos, {nf['bytes']/1024:.1f} Ko brut, {nf['bytes']/3/1024:.1f} Ko ZX0")


def imgtest(circuit):
    """Fenêtre MINIMALE : 1 image statique. Diagnostic affichage Tkinter+ImageTk."""
    import tkinter as tk
    from PIL import Image, ImageTk
    assets = rb.load_assets()
    segs = parse_circuit(ROOT / 'engine/circuits' / f'{circuit}.asm', circuit)
    dense, _ = rb.project(segs, 34, 8, assets)             # un virage bien visible
    img = rb.render(dense, 0).resize((640, 192), Image.NEAREST)
    root = tk.Tk()
    root.title("imgtest — tu dois voir UNE route (virage)")
    tkimg = ImageTk.PhotoImage(img)
    lbl = tk.Label(root, image=tkimg)
    lbl.image = tkimg
    lbl.pack()
    tk.Label(root, text="Si tu vois la route ci-dessus → Tkinter+image OK (le souci est la boucle).\n"
                        "Si fenêtre vide/absente → souci d'affichage Tkinter macOS.",
             justify='left').pack()
    raise_window(root)
    print("[imgtest] fenêtre ouverte — vois-tu une route en virage ?")
    root.mainloop()


if __name__ == '__main__':
    args = [a for a in sys.argv[1:]]
    if '--selftest' in args:
        args.remove('--selftest')
        selftest(args[0] if args else '22_hard_5')
    elif '--imgtest' in args:
        args.remove('--imgtest')
        imgtest(args[0] if args else '22_hard_5')
    else:
        run_gui(args[0] if args else '22_hard_5')
