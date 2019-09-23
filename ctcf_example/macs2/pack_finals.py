
import glob, os, numpy
from glbase3 import *
import matplotlib.pyplot as plot

bad_samples = []

# Remove previous runs
files = glob.glob("glbs/*.glb")
[os.remove(f) for f in files]
files = glob.glob("beds/*.bed")
[os.remove(f) for f in files]

overlap_reps = []

good_chroms = list(range(1,25)) + ['X', 'Y']
good_chroms = [str(i) for i in good_chroms]

labs = []
vals = []

for f in sorted(list(glob.glob('raw_data/*_peaks.narrowPeak'))):
    bn = os.path.split(f)[1].replace('_peaks.narrowPeak', '')

    print(bn)
    if bn in bad_samples:
        continue
    if bn.replace('.rp1', '').replace('.rp2', '') not in overlap_reps:
        p = genelist(filename=f, name=bn, format=format.minimal_bed)

        newp = []
        for peak in p:
            if peak['loc']['chr'] in good_chroms:
                newp.append(peak)

        print('Cut %s peaks from %s total to leave %s' % (len(p)-len(newp), len(p), len(newp)))
        p.linearData = newp
        p._optimiseData()

        p.save('glbs/%s.glb' % bn)
        p.saveBED('beds/%s.bed' % bn)


        labs.append(bn)
        vals.append(len(p))

fig = plot.figure(figsize=[5,1+(0.3*len(vals))])
ax = fig.add_subplot(111)
ax.set_position([0.5, 0.05, 0.4, 0.90])
ax.barh(numpy.arange(len(vals)), vals)
ax.set_yticks(numpy.arange(len(vals)))
ax.set_yticklabels(labs)

fig.savefig('peak_counts.png')
