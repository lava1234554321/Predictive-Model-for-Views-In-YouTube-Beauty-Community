from bs4 import BeautifulSoup
import requests 
import csv
import argparse
import numpy


def snowball_sample_nodes(full_file_name, depth, full_file_output_name):
    links = []
    with open(full_file_name, 'rb') as csvfile:
        spamreader = csv.reader(csvfile, delimiter=' ', quotechar='|')
        for row in spamreader:
            newstring = str(row)
            newstring = newstring.replace("['","")
            newstring = newstring.replace("']","")
            links.append(newstring)
    sample = []
    for link in links:
        taboo = []
        sample.append(snowball_sampling(link, int(depth), 0, taboo))
    sample = sum(sample, [])
    sample = list(set(sample))    
    with open(full_file_output_name, 'w+') as csvfile:
        fieldnames = ['link']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        for i in sample:
                writer.writerow({'link':i})


def snowball_sampling(link, max_depth = 1, current_depth = 0, taboo_list = []):
    
    if current_depth == max_depth:
        return taboo_list
    if link in taboo_list:
        return taboo_list
    else:
        taboo_list.append(link)
    try:
        r = requests.get("https://www.youtube.com/watch?v="+link)
        soup = BeautifulSoup(r.content, "html.parser")
        g_data = soup.find_all("li", {"class": "related-list-item-compact-video"})  
        x= 0
        for item in g_data:
            ite = item.contents[1].find("a")
            x=x+1
            prob = .8 - (x * .7/19)
            if(numpy.random.binomial(1,prob)==1):
                taboo_list = snowball_sampling(ite.get("href")[9:len(ite.get("href"))], max_depth = max_depth, current_depth = current_depth +1, taboo_list = taboo_list)
        return taboo_list
    except:
        return []

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', dest ="input")
    parser.add_argument('-o', dest = "output")
    parser.add_argument('-d', dest = "depth")
    args = parser.parse_args()
    snowball_sample_nodes(args.input, args.depth, args.output)   


    

