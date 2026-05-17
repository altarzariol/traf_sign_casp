import sys
import re
from pathlib import Path
import matplotlib.pyplot as plt # type: ignore
import numpy as np
import math

def plot(horizons, 
         name1, 
         name2, 
         data1, 
         data2,
         opt,
         name_figure,
         place):

    traffic_results = {
        name1: data1,
        name2: data2,
    }
    
    major = []
    for d in data1+data2:
        major.append(int(d))
    major.sort()

    lmt = 10
    for _ in range(1,math.floor(math.log10(abs(major.pop())))):
        lmt *= 10

    x = np.arange(len(horizons))  # the label locations
    width = 0.30  # the width of the bars
    multiplier = 0.5

    fig, ax = plt.subplots(layout='constrained',figsize=(12, 8))

    c = 0
    for attribute, measurement in traffic_results.items():
        offset = width * multiplier
        if str(opt).find("CAFE") >= 0 or str(opt).find("FIRE") >= 0:
            ax.bar(x + offset, measurement, width, label=attribute,color='tab:orange') if c%2 == 0 else\
            ax.bar(x + offset, measurement, width, label=attribute,color='m')
        elif str(opt).find("BND") >= 0:
            ax.bar(x + offset, measurement, width, label=attribute,color="#025E93") if c%2 == 0 else\
            ax.bar(x + offset, measurement, width, label=attribute,color="#E57519")
        elif str(opt).find("OPT") >= 0:
            ax.bar(x + offset, measurement, width, label=attribute,color="#026B62") if c%2 == 0 else\
            ax.bar(x + offset, measurement, width, label=attribute,color="#E57519")
        else:
            ax.bar(x + offset, measurement, width, label=attribute) if c%2 == 0 else\
            ax.bar(x + offset, measurement, width, label=attribute)
        #ax.bar_label(rects, padding=2)
        multiplier += 1
        c += 1 

    # Add some text for labels, title and custom x-axis tick labels, etc.
    #ax.spines['top'].set_visible(False)
    #ax.spines['right'].set_visible(False)
    #ax.spines['left'].set_visible(False)
    #ax.spines['bottom'].set_color("#DDDDDD")
    #ax.set_ylabel('aggregate counters',fontsize=13.5)
    #ax.set_xlabel('Horizon (# of instances)',fontsize=13.5)
    ax.set_ylabel('Improvement',fontsize=13.5)
    ax.set_xlabel('Horizon',fontsize=13.5)
    ax.set_axisbelow(True)
    ax.yaxis.grid(True, color="#CEC9C9",linestyle='--') 
    ax.xaxis.grid(False) 
    #ax.set_title('Penguin attributes by species')
    ax.set_xticks(x + width, horizons)
    #ax.legend(loc='upper left',title='Encoding', ncols=2,alignment='left')
    ax.set_ylim(0, 150)
    #ax.set_ylim(0, major.pop()+(lmt/(2)))
    #ax.set_ylim(0, major.pop()+(lmt/(2/3)))
    #plt.xticks(fontsize=13.5,weight='bold')
    #plt.yticks(fontsize=13.5,weight='bold') 
    plt.legend(loc='upper right',title='Encoding',fontsize=14.5)
    plt.savefig(str(place)+'/'+str(name_figure)+'.jpg',dpi=300)
    #plt.show()

def collect_data(file,
                 target,
                 name,
                 opt,
                 enc,
                 name_fig,
                 place):
    
    horizon = []
    exp_data = []
    cli_data = []

    with open(file,'r') as f:
        for line in f:
            if line.find(str(enc)) >= 0:
               data = re.search(r'\: \d+\.\d+',line).group()
               cli_data.append(float(data[2:]))
            elif line.find(str(target)) >= 0:
                 n_inst = re.search(r'\[\d+',line).group()
                 hrz = re.search(r'\(\d\d\d',line).group()
                 data = re.search(r'\: \d+\.\d+',line).group()
                 #horizon.append(hrz[1:]+' ('+n_inst[1:]+')')
                 horizon.append(hrz[1:])
                 exp_data.append(float(data[2:]))
            if re.search(r'\-{10}',line) != None and len(exp_data) > 0:
               plot(horizon,target,enc,exp_data,cli_data,opt,name_fig,place) if str(name) == "target" else \
               plot(horizon,name,enc,exp_data,cli_data,opt,name_fig,place) 
               horizon.clear()
               cli_data.clear()
               exp_data.clear()
            elif re.search(r'\-{10}',line) != None and len(cli_data) > 0 and len(exp_data) == 0:
               cli_data.clear()
            
                
            
            
        
def main():
    if len(sys.argv) != 8:
       print("Missed: file target")
       sys.exit(1)
    file = Path(sys.argv[1])
    name_test = Path(sys.argv[2])
    flag = Path(sys.argv[3]) 
    tag = Path(sys.argv[4]) 
    name_ref = Path(sys.argv[5]) 
    name_fig = Path(sys.argv[6]) 
    place = Path(sys.argv[7])
    collect_data(file,
                name_test,
                flag,
                tag,
                name_ref,
                name_fig,
                place)

if __name__ == "__main__":
    main()