import sys
import re
from pathlib import Path
import matplotlib.pyplot as plt # type: ignore
import numpy as np
import math

def plot(horizons, name1, name2, data1, data2,opt):

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
        if str(opt).find("OPT") >= 0:
            ax.bar(x + offset, measurement, width, label=attribute) if c%2 == 0 else\
            ax.bar(x + offset, measurement, width, label=attribute)
        else:
            ax.bar(x + offset, measurement, width, label=attribute,color="#025E93") if c%2 == 0 else\
            ax.bar(x + offset, measurement, width, label=attribute,color="#E57519")
        #ax.bar_label(rects, padding=2)
        multiplier += 1
        c += 1
    '''  
    for bar in ax.patches:
        # The text annotation for each bar should be its height.
        bar_value = bar.get_height()
        # Format the text with commas to separate thousands. You can do
        # any type of formatting here though.
        tmp=int(bar_value)
        if tmp >= 1000:
           text = f'{int(bar_value):,}k'
        else:
           text = f'{int(bar_value):,}'
        # This will give the middle of each bar on the x-axis.
        text_x = bar.get_x() + bar.get_width() / 2
        # get_y() is where the bar starts so we add the height to it.
        text_y = bar.get_y() + bar_value
        # If we want the text to be the same color as the bar, we can
        # get the color like so:
        bar_color = bar.get_facecolor()
        # If you want a consistent color, you can just set it as a constant, e.g. #222222
        ax.text(text_x, text_y, text, ha='center', va='bottom', color=bar_color,size=9)
    '''  

    # Add some text for labels, title and custom x-axis tick labels, etc.
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    #ax.spines['bottom'].set_color("#DDDDDD")
    #ax.set_ylabel('PCUs',fontsize=13.5)
    ax.set_ylabel('aggregated counter',fontsize=13.5)
    ax.set_xlabel('Horizon (# of instances)',fontsize=13.5)
    ax.set_axisbelow(True)
    ax.yaxis.grid(True, color="#CEC9C9",linestyle='--') 
    ax.xaxis.grid(False) 
    #ax.set_title('Penguin attributes by species')
    ax.set_xticks(x + width, horizons)
    #ax.legend(loc='upper left',title='Encoding', ncols=2,alignment='left')
    #ax.set_ylim(0, 17000)
    ax.set_ylim(0, major.pop()+(lmt/2))
    #plt.xticks(fontsize=13.5,weight='bold')
    #plt.yticks(fontsize=13.5,weight='bold') 
    plt.legend(loc='upper left',title='Encoding',fontsize=14.5)
    plt.savefig('plot/'+str(name1)+'.jpg',dpi=300)
    #plt.show()

def collect_data(file,target,name,opt):
    
    horizon = []
    exp_data = []
    cli_data = []

    with open(file,'r') as f:
        for line in f:
            if line.find('pddl') >= 0:
               data = re.search(r'\: \d+\.\d+',line).group()
               cli_data.append(float(data[2:]))
            elif line.find(str(target)) >= 0:
                 n_inst = re.search(r'\[\d+',line).group()
                 hrz = re.search(r'\(\d\d\d',line).group()
                 data = re.search(r'\: \d+\.\d+',line).group()
                 horizon.append(hrz[1:]+' ('+n_inst[1:]+')')
                 #horizon.append(hrz)
                 exp_data.append(float(data[2:]))
            if re.search(r'\-{10}',line) != None and len(exp_data) > 0:
               #print(exp_data)
               #print(cli_data)
               plot(horizon,target,'pddl',exp_data,cli_data,opt) if str(name) == "target" else \
               plot(horizon,name,'pddl',exp_data,cli_data,opt) 
               horizon.clear()
               cli_data.clear()
               exp_data.clear()
            elif re.search(r'\-{10}',line) != None and len(cli_data) > 0 and len(exp_data) == 0:
               cli_data.clear()
            
                
            
            
        
def main():
    if len(sys.argv) != 5:
       print("Missed: file target")
       sys.exit(1)
    file = Path(sys.argv[1])
    target = Path(sys.argv[2])
    name = Path(sys.argv[3]) 
    opt = Path(sys.argv[4]) 
    collect_data(file,target,name,opt)

if __name__ == "__main__":
    main()