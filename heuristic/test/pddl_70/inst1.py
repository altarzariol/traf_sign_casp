import re
import sys
from pathlib import Path

def sum_tot_values(enc,
                   name,
                   file,
                   horizon,
		             key):
  
    sum = 0
    file.readline()
    n_instances=0
    for line in file:
        if line.find(enc+','+horizon) >=0 and line.find(key) >= 0: 
           #and line.find('Instancesv2_round') < 0:
           n_instances+=1
           aggr = line.split(',')
           list = []
           h = lambda elem: list.append(elem.removesuffix('\n'))
           [h(elem) for elem in aggr]
           sum += float(list.pop())
    if key != "":
       key = "|"+key
   
    print(name+'['+str(n_instances)+']'+'('+horizon+key+')'+": "+str(sum))
        

def comparison(csv_clingcon,
               csv_second,
	            name,
               horizon,
	            key):
    
    with open(csv_clingcon,'r') as f:
         sum_tot_values("pddl","pddlplan",f,horizon,key)

    with open(csv_second,'r') as f:
         sum_tot_values("clingcon",name,f,horizon,key)
         
def main():
    if len(sys.argv) != 6:
       print("Missed: clingo.csv other.csv")
       sys.exit(1)
    csv_clingcon = Path(sys.argv[1])
    csv_second = Path(sys.argv[2])
    name = sys.argv[3]
    horizon = sys.argv[4]
    key = sys.argv[5]
    comparison(csv_clingcon,
               csv_second,
	            name,
               horizon,
	            key)

if __name__ == "__main__":
    main()

