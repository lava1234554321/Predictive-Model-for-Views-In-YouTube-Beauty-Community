#Predictive Model for Views In YouTube Beauty Community 

###Background
This repository is for a Duke University Department of Statistics Honors thesis on the YouTube makeup community. The files availalbe are meant to enable users to sample makeup videos, scrape mundane and metadata, download thumbnails, perform face recognition on thumbnails, download auto-generated transcrips of the videos, download comments (through YouTube API), and finally, perform analysis on the resulting data set. 


###Data Collection 

####1. Starting link set (start_node.csv)
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
This step (not necessary) will cut the node sample file into different "chunks" to allow you to run later programs synchronously. When used, it saves the input file into x number of output files where each output file has maximum 35 entries (currently only one column as it was created to work with node_sample.csv. The output files will be in the format <input file name><n>.csv, where n is the "nth" cut of the file. For instance, if your node_sample.csv file had 72 entries, the cut_node_sample_data.py file would create three files, node_sample0.csv, node_sample1.csv, and node_sample2.csv, with 35, 35, and 2 entries respectively. 
```
python cut_node_sample_data.py -i <input file name>
```
###5. Download faces and use FaceDetect
This command downloads the thumbnail images for all of the videos inputted (in format of node_sample.csv). It also requires the location of the haar cascade file (located in the repository) to run correctly. The file downloads the faces as .png files, converts them to .jpeg files, and then outputs a file named called face_detect_result.csv that has four columns, one for every image, with cells filled with the number of detected faces per image. The file will download n files with file names <videoID>.jpg and <videoID>.png. Thanks to [Real Python][pyth] for direction on using OpenCV. 
[pyth]: https://realpython.com/blog/python/face-recognition-with-python/
```
python face_detect.py -i /<input file>-p /<location of haar file>
```

###6. Get WebVTT Subtitles
This uses a command line software, youtube-dl (need to download) in order to download the auto-generated transcripts from the YouTube videos. These auto-generated transcripts are downloaded in WebVtt format. The input file is node_sample.csv, and the output file is x number of .vtt files where the file name is <videoID>.en.vtt. Huge thanks to [youtube-dl][dl] for creating the tool to download transcripts.  
```
cat <input link file>| while read line ; do youtube-dl --write-auto-sub  -o 'VTT/%(id)s' --skip-download $line | cut -d'"' -f4; done
```

###6. Convert WebVTT file to .txt files 
This file converts the WebVTT files to an .srt, and then converts those files into a .txt files, eliminating any information about the timing of words. This file requires an input of the folder containing all of the .vtt files (with names <videoID>.en.vtt) and will output n files where the file name is <videoID>.en.vtt.txt. 

```
python subtitles.py -i <VTT folder>
```
###6. Scrape comments
This is by far the most time intensive and difficult aspect of the data collection process. First, one needs to create an API key in order to use the API and have authorized access. This is all (somewhat poorly) explained in the [YouTube API][api] documentation, and will not be detailed here. 

The basic command is:
```
python YoutubeComments2.py --videoid <link_file_name>
```
where the <link_file_name> would be node_sample.csv. However, because of how long the process takes, it is recommended to run parallel processes as follows:

```
python YoutubeComments2.py --videoid /Users/lavanyasunder1/node_sample0.csv > tmp & python YoutubeComments2.py --videoid /Users/lavanyasunder1/node_sample1.csv > tmp & python YoutubeComments2.py --videoid /Users/lavanyasunder1/node_sample2.csv  
```
However, note that before you run the file you must authenticate (through your browser) and that this authentication will time out. In my experience, it timed out every 170 videos or so. This will cause the current process to stop running, and you may have to repeat a process and delete repeated output files. The output files will be in the format <videoID>.txt. 

[pyth]: https://realpython.com/blog/python/face-recognition-with-python/
[dl]: https://github.com/rg3/youtube-dl
[api]: https://developers.google.com/youtube/v3/getting-started

###Data Preprocessing 
