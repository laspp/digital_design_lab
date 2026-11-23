"""Generate img/hipv_soc_block.png (block diagram of the HIPV SoC)."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Rectangle

fig, ax = plt.subplots(figsize=(11, 5.6))
ax.set_xlim(0, 110); ax.set_ylim(-11, 56); ax.axis("off")

def box(x, y, w, h, text, fc, ec, fs=10.5, bold=False):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0,rounding_size=1.2",
                                fc=fc, ec=ec, lw=1.6))
    ax.text(x + w/2, y + h/2, text, ha="center", va="center", fontsize=fs,
            fontweight="bold" if bold else "normal", linespacing=1.4)

def arrow(p, q, both=False, color="black", style="-|>", ls="-"):
    ax.add_patch(FancyArrowPatch(p, q, arrowstyle="<|-|>" if both else style,
                                 mutation_scale=13, lw=1.6, color=color, ls=ls,
                                 shrinkA=0, shrinkB=0))

# SoC boundary
ax.add_patch(Rectangle((1, -1), 72, 53, fc="#f7f7f7", ec="#555555", lw=1.5, ls="--"))
ax.text(2.5, 49.5, "HIPV SoC (inside the FPGA)", fontsize=11.5, fontweight="bold", va="center")

G, GE = "#d9ead3", "#4f8a3b"
box(4, 20, 17, 14, "RV32I core\n5-stage pipeline\nreset vector\n0x0000_0000", "#cfe2f3", "#3d6fa5", bold=False)
box(31, 8, 9, 38, "OBI\ncrossbar\n\n(address\ndecoder)", "#fff2cc", "#b8962e")

# slaves
sl = {"ram": (37, "RAM  64 KiB\ncode  0x0000_0000\ndata  0x1000_0000"),
      "uart": (26, "UART\n0x2000_0000"),
      "timer": (14, "TIMER\n0x2000_1000"),
      "gpio": (3.5, "GPIO\n0x2000_2000")}
SX, SW_ = 49, 22
ys = {}
for k, (y, t) in sl.items():
    h = 8.5 if k != "ram" else 10
    box(SX, y, SW_, h, t, G, GE, fs=10)
    ys[k] = y + h/2
    arrow((40, y + h/2), (SX, y + h/2), both=True)

# core -> crossbar (two ports)
arrow((21, 30), (31, 30), color="#3d6fa5"); ax.text(26, 31.3, "instruction\nport", ha="center", va="bottom", fontsize=8.5, color="#3d6fa5")
arrow((21, 24), (31, 24), color="#3d6fa5"); ax.text(26, 22.7, "data port", ha="center", va="top", fontsize=8.5, color="#3d6fa5")

# board side
R, RE = "#f4cccc", "#a64d4d"
bx, bw = 85, 22
box(bx, 26, bw, 8.5, "USB-UART\n(serial terminal)", R, RE)
box(bx, 14, bw, 8.5, "led_timer\n(LED 8)", R, RE)
box(bx, 3.5, bw, 8.5, "8 LEDs  led[7:0]", R, RE, fs=10)
box(bx, -9.5, bw, 8.5, "8 switches  sw[7:0]", R, RE, fs=10)

arrow((SX+SW_, ys["uart"]), (bx, 30.25), both=True)
ax.text((SX+SW_+bx)/2, 31.2, "Tx / Rx", ha="center", fontsize=8.5)
arrow((SX+SW_, ys["timer"]), (bx, 18.25))
ax.text((SX+SW_+bx)/2, 19.2, "overflow", ha="center", fontsize=8.5)
arrow((SX+SW_, ys["gpio"]), (bx, 7.75))
ax.text((SX+SW_+bx)/2, 8.7, "GpioOut", ha="center", fontsize=8.5)
# switches -> GPIO: enters the GPIO block from below
ax.plot([bx, 60], [-5.25, -5.25], color="black", lw=1.6)
arrow((60, -5.25), (60, 3.5))
ax.text(72, -4.2, "GpioIn", ha="center", fontsize=8.5)

# legend-ish note
ax.text(37, 0.2, "", fontsize=8)
fig.savefig("img/hipv_soc_block.png", dpi=200, bbox_inches="tight", facecolor="white")
