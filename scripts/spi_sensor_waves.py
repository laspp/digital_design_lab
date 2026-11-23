"""Generate img/spi_sensor_read.png and img/spi_sensor_zoom.png:
waveforms of an ADXL362 burst read (X, Y, Z) with the SPI master of the homework."""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

BLUE, GREEN, RED, GREY = "#3d6fa5", "#4f8a3b", "#a64d4d", "#aaaaaa"

def bits(v):
    return [(v >> (7 - i)) & 1 for i in range(8)]

def hline(ax, y0, t0, t1, hi, color="black", lw=1.8, h=0.6):
    y = y0 + (h if hi else 0)
    ax.plot([t0, t1], [y, y], color=color, lw=lw, solid_capstyle="butt")

def step(ax, y0, segs, color="black", h=0.6):
    """segs: list of (t0, t1, level). Draw as a digital waveform with vertical edges."""
    prev = None
    for t0, t1, lv in segs:
        y = y0 + (h if lv else 0)
        if prev is not None and prev != lv:
            ax.plot([t0, t0], [y0, y0 + h], color=color, lw=1.8)
        ax.plot([t0, t1], [y, y], color=color, lw=1.8, solid_capstyle="butt")
        prev = lv

def cells(ax, y0, t0, bitlist, color, h=0.6, fs=9, dont_care=False):
    for k, b in enumerate(bitlist):
        x = t0 + k
        ax.add_patch(Rectangle((x, y0), 1, h, fc="#eeeeee" if dont_care else "white",
                               ec=GREY if dont_care else color, lw=1.4,
                               hatch="////" if dont_care else None))
        if not dont_care:
            ax.text(x + 0.5, y0 + h/2, str(b), ha="center", va="center", fontsize=fs)

# ------------------------------------------------------------------ figure 1: whole transaction
mosi_bytes = [0x0B, 0x08, 0x00, 0x00, 0x00]
miso_bytes = [None, None, 0x01, 0xFE, 0x40]            # X=1, Y=-2, Z=64
names_top = ["command\n0x0B (read)", "address\n0x08", "dummy 0x00\nX = 0x01", "dummy 0x00\nY = 0xFE (-2)", "dummy 0x00\nZ = 0x40 (64)"]
GAP = 1.2
starts = [i * (8 + GAP) + 1.5 for i in range(5)]
tend = starts[-1] + 8 + 1.5

fig, ax = plt.subplots(figsize=(14, 4.9))
ax.set_xlim(-6, tend + 1); ax.set_ylim(-0.4, 12); ax.axis("off")

rows = {"CSN": 9.2, "SCLK": 6.6, "MOSI": 4.0, "MISO": 1.4}
for n, y in rows.items():
    ax.text(-5.5, y + 0.3, n, fontsize=12, fontweight="bold", va="center")

# CSN: high, low for the whole transaction, high
step(ax, rows["CSN"], [(0, 0.8, 1), (0.8, tend - 0.8, 0), (tend - 0.8, tend, 1)])
ax.text(0.9, rows["CSN"] + 1.0, "CSN falls", fontsize=8.5, ha="left")
ax.text(tend - 0.9, rows["CSN"] + 1.0, "CSN rises", fontsize=8.5, ha="right")

# SCLK
segs = [(0, starts[0], 0)]
for i, t0 in enumerate(starts):
    for k in range(8):
        segs += [(t0 + k, t0 + k + 0.5, 0), (t0 + k + 0.5, t0 + k + 1, 1)]
    nxt = starts[i + 1] if i < 4 else tend
    segs.append((t0 + 8, nxt, 0))
step(ax, rows["SCLK"], segs, color=BLUE)

# MOSI / MISO as bit cells
for i, t0 in enumerate(starts):
    cells(ax, rows["MOSI"], t0, bits(mosi_bytes[i]), GREEN)
    if miso_bytes[i] is None:
        cells(ax, rows["MISO"], t0, [0]*8, RED, dont_care=True)
    else:
        cells(ax, rows["MISO"], t0, bits(miso_bytes[i]), RED)
    # byte labels on top of the SCLK bursts
    ax.text(t0 + 4, rows["SCLK"] + 1.55, names_top[i], ha="center", va="bottom", fontsize=9, linespacing=1.3)
    ax.plot([t0, t0 + 8], [rows["SCLK"] + 1.35]*2, color="black", lw=1)
    ax.plot([t0, t0], [rows["SCLK"] + 1.25, rows["SCLK"] + 1.45], color="black", lw=1)
    ax.plot([t0 + 8, t0 + 8], [rows["SCLK"] + 1.25, rows["SCLK"] + 1.45], color="black", lw=1)
    if i < 4:
        ax.text(t0 + 8 + GAP/2, rows["MOSI"] - 0.45, "", fontsize=7)

ax.text(starts[0] + 8, rows["MISO"] - 0.35, "ignored (sensor still receiving the command)", fontsize=8.5,
        ha="center", va="top", color="#555555")
ax.text((starts[1] + starts[2]) / 2 + 4 + 0.5, -0.1, "", fontsize=1)
ax.text(starts[0] + 8 + GAP / 2 + 0.0, rows["SCLK"] - 0.55, "", fontsize=1)
fig.savefig("img/spi_sensor_read.png", dpi=200, bbox_inches="tight", facecolor="white")
plt.close(fig)

# ------------------------------------------------------------------ figure 2: zoom on one byte
xb = bits(0x01)          # X axis = 0x01 while the master sends the dummy 0x00
fig, ax = plt.subplots(figsize=(12, 4.6))
ax.set_xlim(-3.5, 14.5); ax.set_ylim(-1.6, 10.2); ax.axis("off")
rows = {"CSN": 7.6, "SCLK": 5.1, "MOSI": 2.6, "MISO": 0.1}
for n, y in rows.items():
    ax.text(-3.4, y + 0.3, n, fontsize=12, fontweight="bold", va="center")

step(ax, rows["CSN"], [(-0.5, 8.5, 0)])
ax.text(8.7, rows["CSN"] + 0.3, "CSN low", fontsize=9, va="center")

segs = [(-0.5, 0, 0)]
for k in range(8):
    segs += [(k, k + 0.5, 0), (k + 0.5, k + 1, 1)]
segs.append((8, 8.5, 0))
step(ax, rows["SCLK"], segs, color=BLUE)

cells(ax, rows["MOSI"], 0, bits(0x00), GREEN)
cells(ax, rows["MISO"], 0, xb, RED)
for k in range(8):
    ax.text(k + 0.5, rows["MISO"] - 0.55, f"D{7-k}", ha="center", fontsize=8, color="#555555")

# rising edges: sampling instants
for k in range(8):
    x = k + 0.5
    ax.plot([x, x], [rows["MISO"] - 0.2, rows["SCLK"] + 0.75], color="#888888", lw=0.9, ls="--")
ax.text(0.5, rows["SCLK"] + 1.0, "rising edge:\nmaster samples MISO", fontsize=8.5, ha="center", va="bottom", color="#555555")
ax.text(7.0, rows["SCLK"] + 1.0, "falling edge:\nnext bit appears", fontsize=8.5, ha="center", va="bottom", color="#555555")
for x in (1, 2, 3, 4, 5, 6, 7, 8):
    ax.plot([x, x], [rows["SCLK"] - 0.15, rows["MISO"] - 0.2], color="#dddddd", lw=0.7, ls=":")

# T markers under the first bit period
ax.annotate("", xy=(0, rows["SCLK"] - 0.35), xytext=(0.5, rows["SCLK"] - 0.35), arrowprops=dict(arrowstyle="<->", lw=1.1))
ax.annotate("", xy=(0.5, rows["SCLK"] - 0.35), xytext=(1, rows["SCLK"] - 0.35), arrowprops=dict(arrowstyle="<->", lw=1.1))
ax.text(0.25, rows["SCLK"] - 0.7, "T", ha="center", va="top", fontsize=9)
ax.text(0.75, rows["SCLK"] - 0.7, "T", ha="center", va="top", fontsize=9)
ax.text(8.8, rows["MOSI"] + 0.3, "dummy byte 0x00", fontsize=9, va="center", ha="left", color=GREEN)
ax.text(8.8, rows["MISO"] + 0.3, "X axis = 0x01\n(MSB first)", fontsize=9, va="center", ha="left", color=RED)
ax.text(-3.4, 9.6, "Third byte of the burst read in detail (mode 0, T = DIV + 1 clock cycles)", fontsize=10, va="center", ha="left", fontweight="bold")

fig.savefig("img/spi_sensor_zoom.png", dpi=200, bbox_inches="tight", facecolor="white")
