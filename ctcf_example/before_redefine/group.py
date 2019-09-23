
import glob
from glbase3 import *

config.draw_mode = "png"

filenames = [os.path.split(f)[1] for f in glob.glob("../clus/*.bed")]

trks = [
    flat_track(filename='../flats/Hs_hesc_ctcf.rp1.flat'),
    flat_track(filename='../flats/Hs_hesc_ctcf.rp2.flat'),
    flat_track(filename='../flats/Hs_hesc_ctcf.rp3.flat'),
    flat_track(filename='../flats/Hs_hesc_ctcf.rp4.flat'),
    ]


peaks = [
    glload(filename="../macs2/glbs/Hs_hesc_ctcf.rp1.glb"),
    glload(filename="../macs2/glbs/Hs_hesc_ctcf.rp2.glb"),
    glload(filename="../macs2/glbs/Hs_hesc_ctcf.rp3.glb"),
    glload(filename="../macs2/glbs/Hs_hesc_ctcf.rp4.glb"),
    ]

gl = glglob()
ret = gl.chip_seq_cluster_heatmap(peaks, trks, "heatmap.png",
    cache_data="data.bin",
    #bracket=[5.43544, 7.12835359573],
    imshow=True, bracket = [6.0, 10.0],
    pileup_distance=4000,
    bins=30, read_extend=0)
gl.chip_seq_cluster_pileup(filename="clus/clusters.png")

for cid in ret:
    print("cid:", cid, "len:", len(ret[cid]["genelist"]))
    ret[cid]["genelist"].saveBED(filename="clus/cid_%s.bed" % cid, uniqueID=True)

