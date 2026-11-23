"""Generate img/spi_block.png (block diagram of the OBI SPI peripheral)."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Rectangle

fig, ax = plt.subplots(figsize=(12, 6))
ax.set_xlim(-11, 122); ax.set_ylim(0, 54); ax.axis("off")

def box(x, y, w, h, title, body, fc, ec, fs=9.5):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0,rounding_size=1.2", fc=fc, ec=ec, lw=1.8))
    ax.text(x + w/2, y + (h - 2.2 if body else h/2), title, ha="center", va="center", fontsize=10.5, fontweight="bold")
    ax.text(x + w/2, y + (h - 4)/2, body, ha="center", va="center", fontsize=fs, linespacing=1.5)

def arrow(p, q, both=False):
    ax.add_patch(FancyArrowPatch(p, q, arrowstyle="<|-|>" if both else "-|>", mutation_scale=14,
                 lw=1.6, color="black", shrinkA=0, shrinkB=0))

def lab(x, y, t, fs=8.5, ha="center"):
    ax.text(x, y, t, ha=ha, va="center", fontsize=fs, linespacing=1.3,
            bbox=dict(fc="white", ec="none", pad=0.8))

# SPI peripheral outline
ax.add_patch(Rectangle((16, 2), 84, 50, fc="#f7f7f7", ec="#555555", lw=1.5, ls="--"))
ax.text(17.5, 49.5, "spi (OBI slave)", fontsize=11.5, fontweight="bold", va="center")

# crossbar side
box(0, 12, 10, 28, "OBI\\ncrossbar".replace("\\n", "\n"), "", "#fff2cc", "#b8962e")
# interface
box(20, 8, 27, 38, "OBI slave\ninterface",
    "Gnt = 1\nAccept = Req & Gnt\nWeQ, AddrQ captured\non Accept\nRvalid = Accept\ndelayed by 1\n\nwrite decode\nread mux", "#d9ead3", "#4f8a3b")
# registers
box(58, 34, 28, 14, "Registers", "DIV[15:0]        CS[0]", "#cfe2f3", "#3d6fa5")
# engine
box(58, 6, 28, 24, "SPI engine", "FSM: IDLE / LOW / HIGH\nCnt, Bit counters\nTxShift, RxShift", "#cfe2f3", "#3d6fa5")
# synchronizer
box(88, 6, 11, 7, "2-FF\nsync", "", "#fce5cd", "#b8782e")
ax.text(93.5, 11.8, "", fontsize=1)

# pins
def pin(y, t):
    ax.add_patch(FancyBboxPatch((108, y - 2.4), 12, 4.8, boxstyle="round,pad=0,rounding_size=0.8", fc="#f4cccc", ec="#a64d4d", lw=1.6))
    ax.text(114, y, t, ha="center", va="center", fontsize=10)
pin(40, "CSN"); pin(28, "SCLK"); pin(20, "MOSI"); pin(9.5, "MISO")

# crossbar <-> interface
arrow((9, 32), (20, 32)); lab(14.5, 35.5, "Req, Addr,\nWe, Be, Wdata")
arrow((20, 18), (9, 18)); lab(14.5, 14.5, "Gnt, Rvalid,\nRdata")
# interface <-> registers
arrow((47, 44), (58, 44)); lab(52.5, 47.3, "write enable,\nWdata")
arrow((58, 39), (47, 39)); lab(52.5, 35.6, "DIV, CS\n(read-back)")
# interface <-> engine
arrow((47, 24), (58, 24)); lab(52.5, 27.3, "Start,\nTxData")
arrow((58, 13), (47, 13)); lab(52.5, 9.6, "Busy, Done,\nRxData")
# registers -> engine
arrow((72, 34), (72, 30)); lab(78.5, 32, "DIV")
# registers -> CSN pin
arrow((86, 40), (108, 40)); lab(97, 42.6, "CSN = ~CS")
# engine -> pins
arrow((86, 28), (108, 28)); lab(97, 30.4, "SCLK")
arrow((86, 20), (108, 20)); lab(97, 22.4, "MOSI")
# MISO pin -> sync -> engine
arrow((108, 9.5), (99, 9.5)); arrow((88, 9.5), (86, 9.5))
lab(103.5, 12.2, "MISO\n(async)")

fig.savefig("img/spi_block.png", dpi=200, bbox_inches="tight", facecolor="white")
