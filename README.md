# Youtube Makeup Thesis

###Background
This repository is for a Duke University Statistics thesis on the YouTube makeup community. The files availalbe are meant to enable users to sample makeup videos, scrape mundane and metadata, download thumbnails, perform face recognition on thumbnails, download auto-generated transcrips of the videos, download comments (through YouTube API), and finally, perform analysis on the resulting data set. All file names mentioned are for the purposes of this markdown, and can be changed. 


###Starting link set - start_node.csv
The analysis starts with a user-generated starting link set. The entie project will refer to Youtube videoIDs, which are the unique id vr all YouTube videos, located in the URL. 
```
Ex. For http://www.youtube.com/watch?v=9bZkp7q19f0, videoID = 9bZkp7q19f0
```
To begin the analysis, the user should generate a list of starting makeupvideo "nodes" (see paper for instructions on creating the list). This file must be in a .csv format, contain only videoIds, and not contain headers. 

###Snowball Sampling - node_sample.csv
Next, the user will run the snowball sampling file to sample additional makeup videos based on the starting set. Note: the user here will specify an input file (start_node.csv), an output file(node_sample.csv), and a depth for the snowball sampling. The depth used in the initial analysis was 3, and any larger depths will cause an exponential increase in run time. 
```
python Snowball_Sampling.py -i <input file name> -o <output file name>-d <depth>
```


