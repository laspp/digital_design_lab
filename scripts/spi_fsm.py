"""Generate img/spi_fsm.png (state diagram of the suggested SPI controller)."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch

fig, ax = plt.subplots(figsize=(12, 5.8))
ax.set_xlim(-5, 118); ax.set_ylim(-14, 50); ax.axis("off"); ax.set_aspect("equal")

R = 8.5
Y = 26
pos = {"IDLE": (13, Y), "LOW": (59, Y), "HIGH": (105, Y)}
fc = {"IDLE": "#e8e8e8", "LOW": "#cfe2f3", "HIGH": "#d9ead3"}
ec = {"IDLE": "#555555", "LOW": "#3d6fa5", "HIGH": "#4f8a3b"}
sub = {"IDLE": "BUSY = 0\nSCLK = 0", "LOW": "BUSY = 1\nSCLK = 0", "HIGH": "BUSY = 1\nSCLK = 1"}
for k, (x, y) in pos.items():
    ax.add_patch(Circle((x, y), R, fc=fc[k], ec=ec[k], lw=2))
    ax.text(x, y + 2.6, k, ha="center", va="center", fontsize=13, fontweight="bold")
    ax.text(x, y - 3.2, sub[k], ha="center", va="center", fontsize=9, linespacing=1.3)

def arrow(p, q, rad=0.0):
    ax.add_patch(FancyArrowPatch(p, q, connectionstyle=f"arc3,rad={rad}",
                 arrowstyle="-|>", mutation_scale=15, lw=1.6, color="black",
                 shrinkA=0, shrinkB=0))

def label(x, y, t, fs=9):
    ax.text(x, y, t, ha="center", va="center", fontsize=fs, linespacing=1.35)

def loop(name, text):
    x, y = pos[name]
    arrow((x - 4.5, y + 7.2), (x + 4.5, y + 7.2), -1.6)
    label(x, y + 18, text)

# IDLE -> LOW (straight, middle)
arrow((pos["IDLE"][0] + R, Y), (pos["LOW"][0] - R, Y))
label(36, Y + 8.5, "write to DATA and BUSY = 0\n---\nTxShift <- data\nBit <- 0, Cnt <- 0")
# LOW -> HIGH (upper straight)
arrow((pos["LOW"][0] + R, Y + 3), (pos["HIGH"][0] - R, Y + 3))
label(82, Y + 10, "Cnt = DIV\n---\nSCLK <- 1, sample MISO\nCnt <- 0")
# HIGH -> LOW (lower straight)
arrow((pos["HIGH"][0] - R, Y - 3), (pos["LOW"][0] + R, Y - 3))
label(82, Y - 10.5, "Cnt = DIV and Bit != 7\n---\nSCLK <- 0, shift TxShift\nBit <- Bit + 1, Cnt <- 0")
# HIGH -> IDLE (long arc below)
arrow((pos["HIGH"][0] - 3, Y - R), (pos["IDLE"][0] + 3, Y - R), -0.4)
label(59, -10, "Cnt = DIV and Bit = 7\n---\nSCLK <- 0, BUSY <- 0, DONE <- 1, RxData <- received byte")

loop("IDLE", "no write to DATA")
loop("LOW", "Cnt != DIV\nCnt <- Cnt + 1")
loop("HIGH", "Cnt != DIV\nCnt <- Cnt + 1")

# reset marker
arrow((-4, Y), (pos["IDLE"][0] - R, Y))
label(-1.5, Y + 2.5, "reset")

fig.savefig("img/spi_fsm.png", dpi=200, bbox_inches="tight", facecolor="white")
