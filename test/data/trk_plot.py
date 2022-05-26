# Track check
from matplotlib import pyplot as plt
from mpl_toolkits.basemap import Basemap
import numpy as np
import matplotlib.cm as cm
import matplotlib.colors as co
import matplotlib

# Define map
m = Basemap(projection='cyl', \
        llcrnrlat= 25, urcrnrlat= 40, \
        llcrnrlon= -100, urcrnrlon= -80, \
        resolution='l')

# Define plot size
fig, ax = plt.subplots(figsize=(8,8))

#model track 
csv_file = "fort.69"
tc = np.recfromcsv(csv_file, unpack=True, names=['stormid', 'count', 'initdate', 'constant', 'atcf', 'leadtime', 'lat','lon','ws','mslp', \
                   'placehoder', 'thresh', 'neq', 'blank1', 'blank2', 'blank3','blank4','blank5','blank6','blank7'], dtype=None)

# Initialize blank lists
xs1 = []
ys1 = []
xs2 = []
ys2 = []

tclon =[]
tclat=[]
ws=[]
bxs1 = []
bys1 = []
ballon=[]
ballat=[]

bal_file ="bal022019_post.dat"
bal = np.recfromcsv(bal_file,unpack=True,delimiter=",",usecols=[0,3,4,5,6],names=['time','lat','lon','ws','mslp'],dtype=None)

# Prepare color map based on vortex center maximum wind speed
cmap=plt.cm.jet
norm=co.Normalize(vmin=9,vmax=55)
colors=plt.cm.ScalarMappable(norm,cmap)
col=colors.to_rgba(tc.ws)
bcol=colors.to_rgba(bal.ws)


# Read the vortex center, lat and lon, from Best Track data
for k in range(len(bal.lat)):
       ballon=float(bal.lon[k][1:6])*1.*(-1)
       ballat=float(bal.lat[k][1:5])*1.
       lonn,latt=ballon,ballat
       xptt,yptt=m(lonn,latt)
       lonptt,latptt=m(xptt,yptt,inverse=True)
       bxs1.append(lonn)
       bys1.append(latt)

cs1=m.plot(bxs1, bys1, linestyle='--',color='Black',label='Best Track')
bxs1 = []
bys1 = []
ballon=[]
ballat=[]
count=0
for k in range(len(bal.lat)):
        ballon=float(bal.lon[k][1:6])*1*(-1)
        ballat=float(bal.lat[k][1:5])*1
        lonn,latt=ballon,ballat
        xptt,yptt=m(lonn,latt)
        lonptt,latptt=m(xptt,yptt,inverse=True)
        bxs1.append(lonn)
        bys1.append(latt)
        m.plot(bxs1[count], bys1[count], marker='o',color=bcol[k,:])
        count=count+1

encoding='utf-8'

#
for j in range(len(tc.ws)):
    tcstormid=str(tc.stormid[j],encoding)
    print(tcstormid)
    if tcstormid=='AL' and tc.count[j]== 2 and tc.thresh[j]==34 and tc.leadtime[j]<=9000:
        tclon=float(tc.lon[j][1:5])*0.1*(-1)
        tclat=float(tc.lat[j][1:4])*0.1
        lon, lat = tclon, tclat
        xpt, ypt = m(lon, lat)
        lonpt, latpt = m(xpt, ypt, inverse=True)
        xs1.append(lon)
        ys1.append(lat)

cs2=m.plot(xs1, ys1, linestyle='--',color='Red',label='SRW')

xs1 = []
ys1 = []
xs2 = []
ys2 = []
tclon =[]
tclat=[]
count=0
for j in range(len(tc.ws)):
    tcstormid=str(tc.stormid[j],encoding)
    if tcstormid=='AL' and tc.count[j]==2 and tc.thresh[j]==34 and tc.leadtime[j]<=9000:
        tclon=float(tc.lon[j][1:5])*0.1*(-1)
        tclat=float(tc.lat[j][1:4])*0.1
        lon, lat = tclon, tclat
        xpt, ypt = m(lon, lat)
        lonpt, latpt = m(xpt, ypt, inverse=True)
        xs1.append(lon)
        ys1.append(lat)
        m.plot(xs1[count], ys1[count], marker='o',color=col[j,:])
        count=count+1


# Draw coastline
m.drawcoastlines()
m.drawcountries()
m.drawstates()
m.drawmapboundary(fill_color='#99ffff')
m.fillcontinents(color='white',lake_color='#99ffff')
colors.set_array([])

# Show and save the plot
plt.legend()
plt.title('Hurricane Barry Tracks from 00Z 12 Jul to 00Z 14 Jul 2019')
plt.colorbar(colors,fraction=0.035,pad=0.04,label='vortex maximum 10-m wind (kt)')
plt.show()
plt.savefig('Barry_trk.png')
