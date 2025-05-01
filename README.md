# A CASP-based Solution for Traffic Signal Optimisation
### Requirements
- [Clingcon](https://potassco.org/clingcon/)
- [Java](https://www.java.com/en/download/manual.jsp): to run [enhsp](https://sites.google.com/view/enhsp/) and [pps](https://github.com/hstairs/pps) (compiled files are in ./bin)


### Parse pddl domains into asp instances 
```
python extract_instances.py [Directory_with_pddl_files]
```
Example
```
python extract_instances.py ./Test
```

### Run clingcon 
```
clingcon instance_fixed.lp enc_clingcon.lp [ASP_instance] --const horizon=[horizon] --const bound=[cars_bound] --config=crafty 
```
Example
```
clingcon instance_fixed.lp enc_clingcon.lp ./Test/p01[count=350].lp --const horizon=600 --const bound=1000000 --config=crafty 
```
Note: 1000000 stands for 10.00000

## Run experiments 
### Task 1 [Remove optimisation statements from encoding]
```
task1_run_clingcon_with_bounds.sh 
task1_run_enhsp.sh [Directory]
task1_run_pps.sh [Directory]
```
### Task 2
```
task2_run_clingcon.sh 
task2_run_enhsp.sh [Directory]
task2_run_pps.sh [Directory]
```

### Extra 
Run clingo-dl encoding
```
clingo-dl instance_fixed.lp enc_clingodl.lp Instances_A/sippv2/fixlen4/muse/p05\[count\=350\].lp --const h=900 --config=crafty --heuristic=Domain [--minimize-variable="counter(900,[link])"]
```
Run asp encoding
```
clingo instance_fixed.lp enc_asp.lp Instances_A/sippv2/fixlen4/muse/p05\[count\=350\].lp --const h=900 --config=crafty 
```