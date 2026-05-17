import sys
import re
from pathlib import Path
import matplotlib.pyplot as plt # type: ignore
import numpy as np
import math

def plot(horizons, 
         name1, 
         name2, 
         cliname, 
         data1, 
         data2, 
         clidata, 
         opt1,
         opt2,
         figure):

    print(name1)
    print(name2)
    traffic_results = {
        name1: data1,
        name2: data2,
        cliname: clidata
    }
    
    print(data1)
    print(data2)
    print(clidata)
    
    major = []
    for d in data1+data2+clidata:
        major.append(int(d))
    major.sort()

    lmt = 10
    for _ in range(1,math.floor(math.log10(abs(major.pop())))):
        lmt *= 10

    x = np.arange(len(horizons))  # the label locations
    width = 0.20  # the width of the bars
    multiplier = 0.30

    fig, ax = plt.subplots(layout='constrained',figsize=(12, 8))

    c = 0
    for attribute, measurement in traffic_results.items():
        offset = width * multiplier
        if str(opt1).find("OPT") >= 0:
            ax.bar(x + offset, measurement, width, label=attribute) if c%2 == 0 else\
            ax.bar(x + offset, measurement, width, label=attribute)
        else:
            ax.bar(x + offset, measurement, width, label=attribute,color="#025E93") if c%2 == 0 else\
            ax.bar(x + offset, measurement, width, label=attribute,color="#E57519")
        #ax.bar_label(rects, padding=2)
        multiplier += 1
        c += 1
        
    

    # Add some text for labels, title and custom x-axis tick labels, etc.
    #ax.spines['top'].set_visible(False)
    #ax.spines['right'].set_visible(False)
    #ax.spines['left'].set_visible(False)
    #ax.spines['bottom'].set_color("#DDDDDD")
    #ax.set_ylabel('PCUs',fontsize=13.5)
    #ax.set_xlabel('Horizon (# of instances)',fontsize=13.5)
    ax.set_ylabel('aggregated counter',fontsize=13.5)
    ax.set_xlabel('Horizon',fontsize=13.5)
    ax.set_axisbelow(True)
    ax.yaxis.grid(True, color="#CEC9C9",linestyle='--') 
    ax.xaxis.grid(False) 
    ax.set_xticks(x + width, horizons)
    #ax.legend(loc='upper left',title='Encoding', ncols=2,alignment='left')
    #ax.set_ylim(0, 17000)
    #ax.set_ylim(0, major.pop()+(lmt/2))
    ax.set_ylim(0,65000)
    #plt.xticks(fontsize=13.5,weight='bold')
    #plt.yticks(fontsize=13.5,weight='bold') 
    plt.legend(loc='upper left',title='Encoding',fontsize=14.5)
    plt.savefig('plot/'+str(figure)+'.jpg',dpi=300)
    #plt.show()

def collect_data(file,
                 target1,
                 target2,
                 flag,
                 opt1,
                 opt2,
                 name_figure,
                 name1,
                 name2):
    
    horizon = []
    exp_data1 = []
    exp_data2 = []
    cli_data = []

    with open(file,'r') as f:
        for line in f:
            if line.find('clingcon') >= 0 and len(cli_data) < 6:
               data = re.search(r'\: \d+\.\d+',line).group()
               cli_data.append(float(data[2:]))
            elif line.find(str(target1)+'[') >= 0:
                 n_inst = re.search(r'\[\d+',line).group()
                 hrz = re.search(r'\(\d\d\d',line).group()
                 data1 = re.search(r'\: \d+\.\d+',line).group()
                 #horizon.append(hrz[1:]+' ('+n_inst[1:]+')')
                 horizon.append(hrz[1:])
                 exp_data1.append(float(data1[2:]))
            elif line.find(str(target2)+'[') >= 0:
                 data2 = re.search(r'\: \d+\.\d+',line).group()
                 #horizon.append(hrz)
                 exp_data2.append(float(data2[2:]))
            if re.search(r'\-{10}',line) != None and len(exp_data1) > 0 and len(exp_data2) > 0:
               #print(exp_data)
               #print(cli_data)
               plot(horizon,name1,name2,'clingcon',exp_data1,exp_data2,cli_data,opt1,opt2,name_figure) if str(flag) == "target" else \
               plot(horizon,flag,name2,'clingcon',exp_data1,exp_data2,cli_data,opt1,opt2,name_figure) 
               horizon.clear()
               cli_data.clear()
               exp_data1.clear()
               exp_data2.clear()
            elif re.search(r'\-{10}',line) != None and len(cli_data) > 0 and len(exp_data1) == 0 and len(exp_data2) == 0:
               cli_data.clear()
            
                
            
            
        
def main():
    if len(sys.argv) != 10:
       print("Missed: file target")
       sys.exit(1)
    file = Path(sys.argv[1])
    target1 = Path(sys.argv[2])
    target2 = Path(sys.argv[3])
    flag = Path(sys.argv[4])  
    opt1 = Path(sys.argv[5]) 
    opt2 = Path(sys.argv[6]) 
    name_figure = Path(sys.argv[7])
    name1 = Path(sys.argv[8])
    name2 = Path(sys.argv[9])
    collect_data(file,
                 target1,
                 target2,
                 flag,
                 opt1,
                 opt2,
                 name_figure,
                 name1,
                 name2)

if __name__ == "__main__":
    main()