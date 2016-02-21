#! /usr/bin/python
#
import xmltodict
import re
import datetime
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("input_file", help="GPX file to smooth")
parser.add_argument("-w","--window",  type=int, default=7, help="Size of smoothing window")

args=parser.parse_args()

#f=open("activity_866550078.gpx","r")
f=open(args.input_file,"r")
b=xmltodict.parse(f)
f.close()

p=[ (datetime.datetime.strptime(re.sub(".\d+Z","",x['time']),"%Y-%m-%dT%H:%M:%S").strftime("%s"),x['ele']) for x in b['gpx']['trk']['trkseg']['trkpt']]

points=b['gpx']['trk']['trkseg']['trkpt']
e0=int(datetime.datetime.strptime(re.sub(".\d+Z","",points[0]['time']),"%Y-%m-%dT%H:%M:%S").strftime("%s"))
for pt in points:
	epoch=datetime.datetime.strptime(re.sub(".\d+Z","",pt['time']),"%Y-%m-%dT%H:%M:%S").strftime("%s")
	pt['epoch']=int(epoch)-e0
	
window=args.window
mid=int(window-1)/2

numpts=len(points)
for ndx in range(0,numpts-window):
	xpt=[int(x['epoch']) for x in points[ndx:ndx+window]]
	ypt=[float(x['ele']) for x in points[ndx:ndx+window]]
	x=x2=y=xy=0.0
	for i in range(window):
		x += xpt[i]	
		y += ypt[i]	
		x2 += xpt[i]*xpt[i]	
		xy += xpt[i]*ypt[i]	
	det=window*x2-x*x
#	print x,x2,y,xy,det
	inter=(x2*y-x*xy)/det
	slope=(window*xy-x*y)/det
	fit = slope*xpt[mid]+inter
	
	print xpt[mid],ypt[mid],fit
	points[ndx+mid]['fit']=fit  

ofile=open("test.gpx","w")
ofile.write(xmltodict.unparse(b) )
ofile.close()

