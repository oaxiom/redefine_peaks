
import sys, os, glob, numpy
from glbase3 import *
import  matplotlib.pyplot as plot

peaks = sorted(list(glob.glob('../macs2/glbs/Hs_hesc_ctcf.rp*.glb')))
peaks = [glload(f) for f in peaks]

gl = glglob()
superset = gl.chip_seq_cluster(list_of_peaks=peaks)
superset.sort('loc')
superset = superset
#superset = superset.pointify().expand('loc', 100)

# Output a redefined peaklist for each inputted flat file:
flats = [
    flat_track(filename='../flats/Hs_hesc_ctcf.rp1.flat'),
    flat_track(filename='../flats/Hs_hesc_ctcf.rp2.flat'),
    flat_track(filename='../flats/Hs_hesc_ctcf.rp3.flat'),
    flat_track(filename='../flats/Hs_hesc_ctcf.rp4.flat'),
    ]

rets = gl.redefine_peaks(superset, flats, filename='models')

for f in rets:
    rets[f].saveBED('%s.bed' % f.replace(' ', '_'), uniqueID=True)
    rets[f].save('%s.glb' % f.replace(' ', '_'))
