import re
import sys
from pathlib import Path


def sum_tot_values(name,
                   file,
                   horizon):
    
    sum = 0
    file.readline()
    n_instances=0
    for line in file:
        if line.find('clingcon,'+horizon) >= 0: 
           #and line.find('Instancesv2_round') < 0:
           n_instances+=1
           aggr = line.split(',')
           list = []
           h = lambda elem: list.append(elem.removesuffix('\n'))
           [h(elem) for elem in aggr]
           sum += float(list.pop())
    print(name+'['+str(n_instances)+']'+'('+horizon+')'+": "+str(sum))
        

def comparison(csv_clingcon,
               csv_second,
	       name,
               horizon):
    
    with open(csv_clingcon,'r') as f:
         sum_tot_values("clingcon",f,horizon)

    with open(csv_second,'r') as f:
         sum_tot_values(name,f,horizon)

def main():
    if len(sys.argv) != 5:
       print("Missed: clingo.csv other.csv")
       sys.exit(1)
    csv_clingcon = Path(sys.argv[1])
    csv_second = Path(sys.argv[2])
    name = sys.argv[3]
    horizon = sys.argv[4]
    comparison(csv_clingcon,
               csv_second,
	           name,
               horizon)



if __name__ == "__main__":
    main()

