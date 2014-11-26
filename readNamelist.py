#!/usr/bin/env python

import sys
import re
import os
from subprocess import Popen, PIPE
import string

SCRIPT_PATH = os.path.dirname(os.path.realpath(__file__))
repeatThreashold = 4
tmp_settings_file = '/tmp/TMP.gem_settings.nml'

# Get namelist
nlfile=''
if len(sys.argv) >= 1:
	nlfile=sys.argv[1]

# First, remove some of the known replacement strings
if (False):
	f=open(nlfile,'r')
	output='';
	for line in f.readlines():
		# Start and end dates
		line = re.sub(r"((strt_|end_).*)\s*=\s*('|\")[a-zA-Z].*('|\")\s*,", r"\1 = '0',", line)

		# Other known constants
		line = re.sub(r"=(\s*)PTOPO_NPE.", r"=\1 0        ", line)

		output = output + line;
	f = open(tmp_settings_file,'w')
	f.write(output)
	f.close() 

	nlfile=tmp_settings_file

proc = Popen("%s/_readNamelist %s"%(SCRIPT_PATH, nlfile), stdout=PIPE, stderr=None, shell=True)
(namelistContent, err) = proc.communicate()

#namelistContent = """
#Test
#multiline content
#here
#"""
#print namelistContent.splitlines()

it = iter(namelistContent.splitlines())
#print it.next()

repeat = 0;
lastline = "";
namelist=''
output=''
skip = False;
reKey = re.compile(r'[a-zA-Z].*=')
for i,line in enumerate(it):
	# Figure out what namelist we're in
	match = re.search(r'\&(\w+)', line)
	if match:
		namelist=match.group(1)

	if skip and i < 7695:
		continue

	# Ignore lines outside a namelist
	#if namelist == '':
	#	continue;

	# Clean up input a bit
	line = re.sub(r'^\s([a-zA-Z])', r'\1', line, re.IGNORECASE)
	line = re.sub(r'\s+,', r',', line)
	line = re.sub(r'\s*=\s+', r' = ', line)
	line = re.sub(r"^\s*([\d'-])", r' \1', line, re.IGNORECASE)
	line = re.sub(r"\s*$", r'', line, re.IGNORECASE)
	line = re.sub(r"\s*&", r'&', line, re.IGNORECASE)


	# Get rid of messed up characters
	line = filter(lambda x: x in string.printable, line)


	# Get rid of blank/useless lines
	if line == ",":
		continue;

	# Check for repeats
	if line == lastline:
		repeat+=1;
		if repeat>repeatThreashold:
			continue;
	else:
		#print "%d: \"%s\""%(i-1,lastline)
		#print "%d: \"%s\"\n"%(i,line)
		if repeat>repeatThreashold:
			# This adds an annoying coupling to the contactenation section below,
			# only real clean way to avoid this would be to add another loup
			# explicitly for concatenation
			line = " <Line repeated %d times>"%(repeat-repeatThreashold) + \
					('\n' if reKey.match(line, re.IGNORECASE) else ',') + line
		repeat = 0;

	# Now, concatenate arrays into the same line.  Hopefully this'll still work with gfortran
	#match = re.search(r'^[a-zA-Z].*=', line, re.IGNORECASE)
	#match = re.match(r'[a-zA-Z].*=', line, re.IGNORECASE)
	matchNN = re.search(r'^\s*&', line, re.IGNORECASE)
	if reKey.match(line, re.IGNORECASE) or matchNN or line==' /':
	#if match or matchNN or line==' /':
		output += '\n'
		#print 'reKey=',reKey.match(line, re.IGNORECASE),' match=',reKey.search(line, re.IGNORECASE), ', re.match=', match
		if matchNN:
			output += '\n'
		#output += "%3d: "%(i)
	output += line;

	#print "%3d: (%s) '%s'"%(i,namelist,line)
	#print "%3d: %s\n"%(i,lastline) 

	lastline=line

	if skip and i > 7704:
		break

# Now, comform this to CSV, keeping the values in a second column
# (even if they're arrays)
oldOutput=output;
output='';
reKeyVal=re.compile(r"(\w[^ ]*)\s*=\s*(.*)$");
it = iter(oldOutput.splitlines())
for i,line in enumerate(it):
	# Remove ending comma, I know it's in the original, but it's ugly
	line = re.sub(',$', '', line)
	
	# Normal key/values
	if reKeyVal.match(line):
		output += reKeyVal.sub(r'"\1","\2"', line, re.IGNORECASE) + '\n'
	else:
		output += '"%s",""\n'%(line)

	#output += line + '\n'

print output
