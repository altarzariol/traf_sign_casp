import re
import sys
from pathlib import Path


def clean(_res,
          inst,
	  label):
    
  
    pattern = "_"+label+r"_(\d+).(\w+)"
    _res.append(re.sub(pattern,"",inst))
        
def assemble(list,
             _list):

    _list.extend(list[6:])
    _list.reverse()
    return ','.join(_list)


def dot(list,
        _list,
        item):
    
    if list.index(item) < 6 and str(item).isnumeric():
        _list.append(str(float(item)/100000))
    elif list.index(item) < 6:
        _list.append('')

def number_conversion(csv,
                      csv_dot,
		      label):
     
    results=[]
    with open(csv, 'r') as f:
         
         results.append(f.readline().removesuffix('\n'))
         for line in f:
             aggr = line.split(',')
             list = []
             h = lambda elem: list.append(elem.removesuffix('\n'))
             [h(elem) for elem in aggr]
             list.reverse()
             _list = []
             g = lambda item: dot(list,_list,item) 
             [g(item) for item in list]
             results.append(assemble(list,_list))
             
    _res = []
    c = lambda inst: clean(_res,inst,label)
    [c(inst) for inst in results]
    ###TEST###
    #p = lambda x: print(x)
    #[p(x) for x in _res]
    
    with open(csv_dot, 'w') as f:
        for line in _res:
            f.write(line + '\n')         

def main():
    if len(sys.argv) != 3:
        print("Missed: file.csv")
        sys.exit(1)
    csv_file = sys.argv[1]
    input_path = Path(csv_file)
    label = sys.argv[2]
    csv_dot_file = input_path.with_name(f"{input_path.stem}_dot{input_path.suffix}")
    number_conversion(csv_file,
                      csv_dot_file,
                      label)



if __name__ == "__main__":
    main()
