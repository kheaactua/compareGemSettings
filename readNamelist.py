#!/usr/bin/env python
import sys
import re
import os
from subprocess import Popen, PIPE
import string

class NSParser(object): 
    """ class to make dealing with parsing easier """
    repeat_threshold = 4
    re_key = re.compile(r'[a-zA-Z].*=')

    def __init__(self, proc):
        (namelist_content, err) = proc.communicate()
        self.it = iter(namelist_content.splitlines())

        self.repeat = 0
        self.output = ''

    @staticmethod
    def strip_whitespace(line):
        """ strips unecessary whitespace *including trailing newlines* from a single line """
        line = re.sub(r'^\s([a-zA-Z])', r'\1', line, re.IGNORECASE)
        line = re.sub(r'\s+,', r',', line)
        line = re.sub(r'\s*=\s+', r' = ', line)
        line = re.sub(r"^\s*([\d'-])", r' \1', line, re.IGNORECASE)
        line = re.sub(r"\s*$", r'', line, re.IGNORECASE)
        line = re.sub(r"\s*&", r'&', line, re.IGNORECASE)
        return line

    @staticmethod
    def filter_line(line):
        """ filters a single line """
        line = filter(lambda x: x in string.printable, line)
        return line

    def parse_line(self, line, lastline):
        """ parses a single line """
        result = ''

        if line == lastline:
            self.repeat += 1
            if self.repeat > NSParser.repeat_threshold:
                return
        else:
            if self.repeat > NSParser.repeat_threshold:
                line = " <Line repeated %d times>" % ( self.repeat - NSParser.repeat_threshold ) + ('\n' if NSParser.re_key.match(line, re.IGNORECASE) else ',') + line
            self.repeat = 0

        # Now, concatenate arrays into the same line.
        # Hopefully this'll still work with gfortran
        match_nn = re.search(r'^\s*&', line, re.IGNORECASE)
        match_array = re.search(r'^\s+(?=.+=.+)', line)

        if NSParser.re_key.match(line, re.IGNORECASE) or match_nn or line==' /':
            result += '\n'
            if match_nn:
                result += '\n'
                #output += "%3d: "%(i)
        elif match_array:
            # remove leading spaces from array values
            line = re.sub(r'^\s*(?=.*=)', r'', line)

        result += line
        return result

    def parse(self):
        """ main method to parse entire file """
        self.output = ''
        lastline = ''
        for i, line in enumerate(self.it):

            line = self.strip_whitespace(line)
            line = self.filter_line(line)
            line = self.parse_line(line, lastline)

            if line is not None and line != ",":
                self.output += line
                lastline = line
        return self

    def print_csv(self):
        """ print to output as CSV """
        re_key_val = re.compile(r"(\w[^ ]*)\s*=\s*(.*)$")

        print_output = ''
        it = iter(self.output.splitlines())

        for i, line in enumerate(it):
            # Remove ending comma, I know it's in the original, but it's ugly
            line = re.sub(',$', '', line)
            # Normal key/values
            if re_key_val.match(line):
                print_output += re_key_val.sub(r'"\1","\2"', line, re.IGNORECASE) + '\n'
            else:
                print_output += '"%s",""\n' % (line)
        print print_output

def main():
    """ sets up variables for pipe and then prints the parse as CSV """
    tmp_settings_file = '/tmp/TMP.gem_settings.nml'
    script_path = os.path.dirname(os.path.realpath(__file__))

    # Get namelist
    nlfile = ''
    if len(sys.argv) >= 2:
        nlfile = sys.argv[1]

    # First, remove some of the known replacement strings
    # Often the 'aftermod' file should be used (which doesn't include these)
    # rather than the 'beforemod' fileo
    #
    # In any case, skip this for now.
    if (False):
        f = open(nlfile,'r')
        output = ''
        for line in f.readlines():
            # Start and end dates
            line = re.sub(r"((strt_|end_).*)\s*=\s*('|\")[a-zA-Z].*('|\")\s*,", r"\1 = '0',", line)
            # Other known constants
            line = re.sub(r"=(\s*)PTOPO_NPE.", r"=\1 0 ", line)
            output = output + line
            f = open(tmp_settings_file,'w')
            f.write(output)
            f.close()
            nlfile = tmp_settings_file

    proc = Popen("%s/_readNamelist %s" \
            %(script_path, nlfile), stdout=PIPE, stderr=None, shell=True)

    my_parse = NSParser(proc)
    #print my_parse.parse().output
    my_parse.parse().print_csv()

    if os.path.isfile(tmp_settings_file):
        os.unlink(tmp_settings_file)

if __name__ == "__main__":
    main()
