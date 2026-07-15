#!/usr/bin/env python3
"""Regenerate the osc_x cosine table pasted into objects/byfx/byfx.asm.

Prints the asm; paste it over the existing `osc_x` block. The table is baked
into the source rather than computed at runtime because the 6809 has no cosine
and the mode's render loop is already the tightest code here.

If you change XMIN/XMAX, widen TB_COL0/TB_NCOL in global/textband.asm to match:
that band is what repaints the nebula behind the text, and any x the text can
reach but the band cannot will smear.
"""
import math

N = 100          # entries = 50Hz frames per full round trip (100 -> 2s)
XMIN, XMAX = 50, 90


def main():
    mid, amp = (XMIN + XMAX) / 2, (XMAX - XMIN) / 2
    vals = [round(mid - amp * math.cos(2 * math.pi * i / N)) for i in range(N)]
    cols = sorted({v >> 2 for v in vals})
    print(f"* x = {mid:.0f} - {amp:.0f}*cos(2*pi*i/{N}) -> {min(vals)}..{max(vals)}")
    print(f"* byte columns {cols[0]}..{cols[-1]} = {len(cols)} distinct positions (draw does x>>2)")
    print("osc_x")
    for i in range(0, N, 10):
        print("        fcb   " + ",".join(str(v) for v in vals[i:i + 10]))


if __name__ == "__main__":
    main()
