import re
import sys

def operate (file_name):
    with open(file_name) as f2:
        texts = f2.readlines()
        gene_list = []
        for text in texts:
            m2 = re.search('FPKM "(.+?)";', text).group(1)
            #m3 = re.search('transcript_id "CUFF.(.+?)";', text).group(1)

            m3 = re.search('transcript_id "(.+?)";', text).group(1)
            m4 = text.split()[2]
            if m4 != 'exon':
                #to_write = m3 + '\t' + m2 + '\n' 
                #fw.write(to_write)
                gene_list.append((m3, m2))
        sort_list = sorted(gene_list, key=lambda x: x[0])
    return sort_list

def getFileNames():
    with open ('/home/xiezy/tophat/PepperUntar/runTophat/zunlaList.txt') as f1:
        lines = f1.readlines()
    pre_path = '/home/xiezy/tophat/PepperUntar/cuffLink/zunlaTest/'
    post_path = '/transcripts.gtf'
    post_dir = '.gtf'

    file_name_list = []
    dir_list = []
    for line in lines:
        name = re.search('data/(.+?)_L1_1', line)
        file_name = pre_path + name.group(1) + post_path
        file_name_list.append(file_name)
        dir_list.append(name.group(1))
    return file_name_list, dir_list


if __name__ == '__main__':
    file_name_list, dir_list = getFileNames()
    length = len(file_name_list)
    listList = []
    fw = open('zunlaFpkm.csv', 'w')

    fw.write('start,')
    for file_name, out_name in zip(file_name_list[0: length], dir_list[0: length]): 
        print file_name
        print out_name
        fw.write(out_name + ',') 
        listList.append(operate(file_name))

    fw.write('\n')

    lengthL = len(listList)
    lengthS = len(listList[0])
    for j in range(0, lengthS): #length
        sting = listList[0][j][0] + ',' 
        for i in range(0, lengthL): #width
            sting += listList[i][j][1] + ','
        print sting
        fw.write(sting[:-1] + '\n')
        
    fw.close()
