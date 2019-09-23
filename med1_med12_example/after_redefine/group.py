
import glob
from glbase3 import *

config.draw_mode = ["png", 'pdf']

filenames = [os.path.split(f)[1] for f in glob.glob("../clus/*.bed")]

trks = [
    flat_track(filename='../flats/esc_med1.flat'),
    flat_track(filename='../flats/esc_med12.flat'),
    ]

peaks = [
    glload(filename="../redefine/esc_med1.glb"),
    glload(filename="../redefine/esc_med12.glb"),
    ]

gl = glglob()
ret = gl.chip_seq_cluster_heatmap(peaks, trks, "heatmap.png",
    cache_data="data.bin", bracket=[9,14],
    imshow=True, log=2,
    pileup_distance=2000,
    bins=50, read_extend=0)
gl.chip_seq_cluster_pileup(filename="clus/clusters.png")

for cid in ret:
    print("cid:", cid, "len:", len(ret[cid]["genelist"]))
    ret[cid]["genelist"].saveBED(filename="clus/cid_%s.bed" % cid, uniqueID=True)

