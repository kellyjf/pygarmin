import xmltodict
import re
import datetime


f=open("activity_866550078.gpx","r")
b=xmltodict.parse(f)
f.close()

p=[ (datetime.datetime.strptime(re.sub(".\d+Z","",x['time']),"%Y-%m-%dT%H:%M:%S").strftime("%s"),x['ele']) for x in b['gpx']['trk']['trkseg']['trkpt']]

for pt in p:
	print "%s\t%s"%pt
	



