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
        

def comparison(csv_reference,
               csv_test,
               name_ref,
	            name_test,
               horizon,
	            key,
               enc_ref,
               enc_test):
    
    with open(csv_reference,'r') as f:
         sum_tot_values(enc_ref,name_ref,f,horizon,key)

    with open(csv_test,'r') as f:
         sum_tot_values(enc_test,name_test,f,horizon,key)
         
def main():
    if len(sys.argv) != 9:
       print("Missed: clingo.csv other.csv")
       sys.exit(1)
    csv_reference = Path(sys.argv[1])
    csv_test  = Path(sys.argv[2])
    name_ref  = sys.argv[3]
    name_test = sys.argv[4]
    horizon = sys.argv[5]
    key = sys.argv[6]
    enc_ref  = sys.argv[7]
    enc_test = sys.argv[8]
    comparison(csv_reference,
               csv_test,
               name_ref,
	            name_test,
               horizon,
	            key,
               enc_ref,
               enc_test)
    
if __name__ == "__main__":
    main()

