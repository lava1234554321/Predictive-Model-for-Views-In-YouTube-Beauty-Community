# Youtube Makeup Thesis

###Background
This repository is for a Duke University Statistics thesis on the YouTube makeup community. The files availalbe are meant to enable users to sample makeup videos, scrape mundane and metadata, download thumbnails, perform face recognition on thumbnails, download auto-generated transcrips of the videos, download comments (through YouTube API), and finally, perform analysis on the resulting data set. All file names mentioned are for the purposes of this markdown, and can be changed. 


###1. Starting link set (start_node.csv)
The analysis starts with a user-generated starting link set. The entie project will refer to Youtube videoIDs, which are the unique id vr all YouTube videos, located in the URL. 
```
Ex. For http://www.youtube.com/watch?v=9bZkp7q19f0, videoID = 9bZkp7q19f0
```
To begin the analysis, the user should generate a list of starting makeupvideo "nodes" (see paper for instructions on creating the list). This file must be in a .csv format, contain only videoIds, and not contain headers. 

###2. Snowball Sampling (node_sample.csv)
Next, the user will run the snowball sampling file to sample additional makeup videos based on the starting set. Note: the user here will specify an input file (start_node.csv), an output file(node_sample.csv), and a depth for the snowball sampling. The depth used in the initial analysis was 3, and any larger depths will cause an exponential increase in run time. 
```
python Snowball_Sampling.py -i <input file name> -o <output file name>-d <depth>
```

###3. Scrape basic data
This step involve the node_sample.csv file, and will scrape the basic available mundane and meta data from the sample of YouTube videos. Variables include likes, dislikes, tags, author, subscribers, etc. This command is fairly time expensive; for a sample size of 710 videos, the run time is around an hour. 
```
python Working_1.py -i <input file path> -o <output file path>
```

###4. Cut node sample 
This step (not necessary) will cut the node sample file into different "chunks" to allow you to run later programs synchronously. When used, it saves the input file into x number of output files where each output file has maximum 35 entries (currently only one column as it was created to work with node_sample.csv. 
```
python cut_node_sample_data.py -i <input file name>
```
###5. Download faces and use FaceDetect
This command downloads the thumbnail images for all of the videos inputted (in format of node_sample.csv). It also requires the location of the haar cascade file (located in the repository) to run correctly. The output is a file named called face_detect_result.csv that has four columns, one for every image, with cells filled with the number of detected faces per image. Thanks to [Real Python][pyth] for direction on using OpenCV. 
[pyth]: https://realpython.com/blog/python/face-recognition-with-python/
```
python face_detect.py -i /<input file>-p /<location of haar file>
```



