from pycaption import CaptionConverter
from pycaption import SRTWriter
from pycaption import WebVTTReader
import re
import os
import argparse


def convertText(inputfile):
    file_names = os.listdir(inputfile) 
    for sample_name in file_names:         
        with open(inputfile+"/" + sample_name, 'r') as f:
            read_data = f.read()
        f.closed
        read_data = read_data.decode("utf8")
        read_data = unicode(read_data)
        converter = CaptionConverter()
        converter.read(read_data, WebVTTReader())
        f = converter.write(SRTWriter())
        trythis = list(f)
        myre = '([0-9]){2}:([0-9]){2}:([0-9]){2},([0-9]){3}'
        myre2 = '([0-9])+'   
        char = ""        
        words = []
        for i in trythis:
            if i!="\n":
                char = char + i
            else:
                if re.search(myre, char): 
                    char = ""
                elif re.search(myre2, char):
                    char = ""
                elif char == '-->':
                    char = ""
                else:
                    words.append(char)
                    char = ""
                                
                    
        words =  set(words)
        f = " ".join(words)
        output_file = open("/Users/lavanyasunder1/Subtitles/TXT/%s.txt" % (sample_name), 'w+') 
        output_file.write(f.encode("utf-8")) 
        output_file.write("\n")
        output_file.close()
        
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest ="input")
    args = parser.parse_args()
    convertText(args.input)
