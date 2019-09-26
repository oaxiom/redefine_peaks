
import sys, os, glob, numpy
from glbase3 import *
import  matplotlib.pyplot as plot
config.draw_mode = 'pdf'

peaks = [
    genelist(filename="../peaks/esc_med1.rp1_summits.bed.gz", format=format.minimal_bed, gzip=True),
    genelist(filename="../peaks/esc_med12.rp1_summits.bed.gz", format=format.minimal_bed, gzip=True),
    ]

gl = glglob()
superset = gl.chip_seq_cluster(list_of_peaks=peaks)
superset.sort('loc')

# Output a redefined peaklist for each inputted flat file:
flats = [
    flat_track(filename='../flats/esc_med1.flat'),
    flat_track(filename='../flats/esc_med12.flat'),
    ]

rets = gl.redefine_peaks(superset, flats, filename='models')

for f in rets:
    rets[f].saveBED('%s.bed' % f.replace(' ', '_'), uniqueID=True)
    rets[f].save('%s.glb' % f.replace(' ', '_'))
