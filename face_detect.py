import cv2
import sys
from PIL import Image
import urllib
import csv
import download_faces
import argparse

def downimages(inputfile):
    print(inputfile)
    links = []
    with open(inputfile, 'rb') as csvfile:
        print("try")
        spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in spamreader:
            newstring = str(row)
            newstring = newstring.replace("['","")
            newstring = newstring.replace("']","")
            links.append(newstring)
    print links
    for i in links:
        print i
        urllib.urlretrieve("http://img.youtube.com/vi/"+i+"/0.jpg", "/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic0.jpg")
        im = Image.open("/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic0.jpg")
        im.save("/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic0.png")
        urllib.urlretrieve("http://img.youtube.com/vi/"+i+"/1.jpg", "/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic1.jpg")
        im = Image.open("/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic1.jpg")
        im.save("/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic1.png")
        urllib.urlretrieve("http://img.youtube.com/vi/"+i+"/2.jpg", "/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic2.jpg")
        im = Image.open("/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic2.jpg")
        im.save("/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic2.png")
        urllib.urlretrieve("http://img.youtube.com/vi/"+i+"/3.jpg", "/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic3.jpg")
        im = Image.open("/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic3.jpg")
        im.save("/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic3.png")
    return(links)

def detectFaces(links, haarpath):
    results = []
    for i in links:  
        print i, "current link"  
        tempresult = []   
        tempresult.append(i)
        for x in range(0,4):
            imagePath = "/Users/lavanyasunder1/FaceDetect/Images/" + i+"_pic"+str(x)+".png"
            cascPath = haarpath
            # Create the haar cascade
            faceCascade = cv2.CascadeClassifier(cascPath)
            # Read the image
            image = cv2.imread(imagePath)
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    
            # Detect faces in the image
            faces = faceCascade.detectMultiScale(
                gray,
                scaleFactor=1.01,
                minNeighbors=5,
                minSize=(30, 30),
                flags = cv2.cv.CV_HAAR_SCALE_IMAGE
            ) 
            tempresult.append(format(len(faces)))   
        results.append(tempresult)
        
                        
    return(results)
    
def writeFile(results):
    with open('face_detect_result.csv', 'w+') as csvfile:
        fieldnames = ['link','img0', 'img1', 'img2', 'img3']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for i in results:
                writer.writerow({'link':i[0], 'img0':i[1], 'img1':i[2], 'img2':i[3], 'img3':i[4]})
                
                
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest ="input")
    parser.add_argument('-p', dest = "haarpath")
    args = parser.parse_args()
    links = downimages(args.input)
    writeFile(detectFaces(links, args.haarpath))

"""
# Draw a rectangle around the faces
for (x, y, w, h) in faces:
    cv2.rectangle(image, (x, y), (x+w, y+h), (0, 255, 0), 2)

cv2.imshow("Faces found", image)
cv2.waitKey(0)
"""