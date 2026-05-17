# How to execute your favourite CASP model using &ldquo;this stuff&rdquo;...

## Preliminaries
The framework is divided into three parts:

- **Model**: it contains all the .lp files that you want to test.
- **Manager**: it allows to select your .lp files, set options and run the **tail** script.
- **Tail**: it represents the group of scripts that handle and use all the variables you set up with **manager** script.

## Model

You can load all your .lp files into the folder ./model. You are free to create other directories inside or just put your encodings anywhere, as long as they are in this folder, otherwise you won't be able to access them.


## Tail

The organization of the tail scripts is enterely up to you, but in order to make it works use the
following API:

- *move*: copy your scripts from their own directory to the current one.
- *execute*: run the code with the options set with **manager** script.
- *delete*: allow to do some other operations once the tests are finished. DO NOT USE IT TO DELETE 
THE PREVIOUS MOVED SCRIPTS...otherwise problems will occur when multiple experiments are run simultaneously.

In the current setting the **Tail** is structured as follow:

1. The file ./packgs0.csv contains all the informations you'll want to give about your *tail* scripts:

```bash
name,package_test,label,tail,run_tail
OPT_Aggrel1,theory_delta,OPT_aggrel1,./tail0.sh,./tail2.sh
OPT_Heurate,heu_volume,OPT_heurate,./heu0.sh,./heu2.sh
OPT_Heuphase,heu_volume,OPT_heuphase,./heu0.sh,./heu2.sh
BND_DHphase,heu_volume,BND_dhphase,./heu0.sh,./heu1.sh
```
1. **name**: it is the name of the experiment. It must match at most one of the tags in ./export_files.txt.
2. **package_test**: it is the folder containing your **tail** scripts (less the file used as API interface).
3. **label**: it is the code name assign to the experiment result of the same type.
4. **tail**: this script manages internally the folder **package_test** and adds an extra level of interface.
5. **run_tail**: the code for running the instaces of each task. For TASK_1, set the suffix number to '1' (e.g. ./heu1.sh), for TASK_2 set it to '2' (e.g. ./heu2.sh).


2. The file ./inst13.sh represents the **Tail** interface:

- the function **get_tails** select from the file ./packgs0.csv the experiment you want to test and
fills the internal variables

```bash
pack_test="${package}"
label="${_label}"
tail="${_tail}"
test_run="${runtail}"
```
with the fildes specified before, in order to choose the correct folder, upload the .sh files 
from it (like *tail*, *tail_run*) and set the label for the results;

- all these parameters are used by the functions **move**, **execute** and **delete**.

## Manager

The file manager that represents the link between **Model** and **Tail** is ./inst2.sh.
Here we show an example of execution.

1. You cannot access directly to ./inst2.sh script. Run ./info to open it!

```bash
(base) amministratore@Gabris-MacBook-Air test % bash ./info.sh 
1) aux0.sh           3) inst11.sh        5) inst13.sh        7) inst2.sh         9) inst5.sh
2) create_file.sh    4) inst12.sh        6) inst14.sh        8) inst4.sh        10) exit
#? 7
bash filename -h
1) continue...
2) run
3) exit
#? 
```

2. If you choose the option 'total_run', you will run all the problem instances. Select 'test_run' 
if you desire to customise your instance set.

```bash
#? 2
1) total_run
2) test_run
3) done
```

3. Select your .lp encodings...

```bash
#? 2
1) ./model/constants.lp               9) ./model/enc_conf.lp              17) ./model/heu/max_volume.lp
2) ./model/dates/activation.lp       10) ./model/enc_counter.lp           18) ./model/heu/min_volume.lp
3) ./model/dates/capacity.lp         11) ./model/enc_delta.lp             19) ./model/heu/old_conf.lp
4) ./model/dates/init_occ.lp         12) ./model/enc_delta_sum.lp         20) ./model/heu/phmax_volume.lp
5) ./model/dates/phase_limit.lp      13) ./model/enc_delta_sum_NotOpt.lp  21) ./model/instance_fixed.lp
6) ./model/dates/turnrate.lp         14) ./model/enc_deltacon.lp          22) ./model/theory.lp
7) ./model/enc_clingcon.lp           15) ./model/heu/conf_value.lp        23) export_files.txt
8) ./model/enc_clingcon_not_opt.lp   16) ./model/heu/heuristics.lp        24) done
#? 7
1) ./model/constants.lp               9) ./model/enc_conf.lp              17) ./model/heu/max_volume.lp
2) ./model/dates/activation.lp       10) ./model/enc_counter.lp           18) ./model/heu/min_volume.lp
3) ./model/dates/capacity.lp         11) ./model/enc_delta.lp             19) ./model/heu/old_conf.lp
4) ./model/dates/init_occ.lp         12) ./model/enc_delta_sum.lp         20) ./model/heu/phmax_volume.lp
5) ./model/dates/phase_limit.lp      13) ./model/enc_delta_sum_NotOpt.lp  21) ./model/instance_fixed.lp
6) ./model/dates/turnrate.lp         14) ./model/enc_deltacon.lp          22) ./model/theory.lp
7) ./model/enc_clingcon.lp           15) ./model/heu/conf_value.lp        23) export_files.txt
8) ./model/enc_clingcon_not_opt.lp   16) ./model/heu/heuristics.lp        24) done
#? 9
1) ./model/constants.lp               9) ./model/enc_conf.lp              17) ./model/heu/max_volume.lp
2) ./model/dates/activation.lp       10) ./model/enc_counter.lp           18) ./model/heu/min_volume.lp
3) ./model/dates/capacity.lp         11) ./model/enc_delta.lp             19) ./model/heu/old_conf.lp
4) ./model/dates/init_occ.lp         12) ./model/enc_delta_sum.lp         20) ./model/heu/phmax_volume.lp
5) ./model/dates/phase_limit.lp      13) ./model/enc_delta_sum_NotOpt.lp  21) ./model/instance_fixed.lp
6) ./model/dates/turnrate.lp         14) ./model/enc_deltacon.lp          22) ./model/theory.lp
7) ./model/enc_clingcon.lp           15) ./model/heu/conf_value.lp        23) export_files.txt
8) ./model/enc_clingcon_not_opt.lp   16) ./model/heu/heuristics.lp        24) done
#? 24
good choice!
bye
The files are
./model/enc_clingcon.lp
./model/enc_conf.lp
The export variables are
enc_clingcon
enc_conf
Are you sure of your choices?[y/n]y
```
...and give them a name (it is the TAG!!!).

```bash
Do you want to save this file set?[y/n]y
How do you call this file set?
Name: MyTest
The name is: MyTest
Are you sure of your choice[y/n]?y
The file set MyTest is saved!
There are also these additional packages:
1) clingo_constants    3) traffic_parameters  5) set_task
2) clingo_options      4) set_instance        6) done
#? 
```
Now, if you check the file ./export_file.sh, the tag **Name::MyTest** has been added.

```txt
...
Name::BND_Longrate
 ./model/instance_fixed.lp ./model/enc_clingcon_not_opt.lp ./model/heu/max_volume.lp--BND_Longrate
Name::BND_PhLngrate
 ./model/instance_fixed.lp ./model/enc_clingcon_not_opt.lp ./model/heu/phmax_volume.lp--BND_PhLngrate
Name::OPT_DHphase
 ./model/constants.lp ./model/instance_fixed.lp ./model/enc_conf.lp ./model/enc_delta_sum.lp ./model/heu/heuristics.lp--OPT_DHphase
Name::MyTest
 ./model/enc_clingcon.lp ./model/enc_conf.lp--MyTest
```

This allow you to select in your following runs the same files setting without repeat the 
procedure again:

```bash
#? 2
1) ./model/constants.lp               9) ./model/enc_conf.lp              17) ./model/heu/max_volume.lp
2) ./model/dates/activation.lp       10) ./model/enc_counter.lp           18) ./model/heu/min_volume.lp
3) ./model/dates/capacity.lp         11) ./model/enc_delta.lp             19) ./model/heu/old_conf.lp
4) ./model/dates/init_occ.lp         12) ./model/enc_delta_sum.lp         20) ./model/heu/phmax_volume.lp
5) ./model/dates/phase_limit.lp      13) ./model/enc_delta_sum_NotOpt.lp  21) ./model/instance_fixed.lp
6) ./model/dates/turnrate.lp         14) ./model/enc_deltacon.lp          22) ./model/theory.lp
7) ./model/enc_clingcon.lp           15) ./model/heu/conf_value.lp        23) export_files.txt
8) ./model/enc_clingcon_not_opt.lp   16) ./model/heu/heuristics.lp        24) done
#? 23
 1) ::Test_Delta                           14) ::NotOptQuickrate
 2) ::Test_Delta_Duplex                    15) ::NotOpt_Delta_#sum
 3) ::Delta_&sum                           16) ::NotOpt_HeuTest1(or NotOpt_HighRate)
 4) ::Delta_#sum                           17) ::NotOpt_Heuristics
 5) ::High_rate                            18) ::OPT_Aggrel1
 6) ::Change_in/out                        19) ::OPT_Heurate
 7) ::Heu_Test1                            20) ::OPT_Heuphase
 8) ::QuickRate                            21) ::BND_DHphase
 9) ::PrintQuick                           22) ::BND_Longrate
10) ::QuickPrint2                          23) ::BND_PhLngrate
11) ::LongRate                             24) ::OPT_DHphase
12) ::Delta#_and_HighRate                  25) ::MyTest
13) ::NotOptTest                           26) done
#? 25
::MyTest...
./model/enc_clingcon.lp
./model/enc_conf.lp
MyTest
 1) ::Test_Delta                           14) ::NotOptQuickrate
 2) ::Test_Delta_Duplex                    15) ::NotOpt_Delta_#sum
 3) ::Delta_&sum                           16) ::NotOpt_HeuTest1(or NotOpt_HighRate)
 4) ::Delta_#sum                           17) ::NotOpt_Heuristics
 5) ::High_rate                            18) ::OPT_Aggrel1
 6) ::Change_in/out                        19) ::OPT_Heurate
 7) ::Heu_Test1                            20) ::OPT_Heuphase
 8) ::QuickRate                            21) ::BND_DHphase
 9) ::PrintQuick                           22) ::BND_Longrate
10) ::QuickPrint2                          23) ::BND_PhLngrate
11) ::LongRate                             24) ::OPT_DHphase
12) ::Delta#_and_HighRate                  25) ::MyTest
13) ::NotOptTest                           26) done
#? 26
bye
1) ./model/constants.lp               9) ./model/enc_conf.lp              17) ./model/heu/max_volume.lp
2) ./model/dates/activation.lp       10) ./model/enc_counter.lp           18) ./model/heu/min_volume.lp
3) ./model/dates/capacity.lp         11) ./model/enc_delta.lp             19) ./model/heu/old_conf.lp
4) ./model/dates/init_occ.lp         12) ./model/enc_delta_sum.lp         20) ./model/heu/phmax_volume.lp
5) ./model/dates/phase_limit.lp      13) ./model/enc_delta_sum_NotOpt.lp  21) ./model/instance_fixed.lp
6) ./model/dates/turnrate.lp         14) ./model/enc_deltacon.lp          22) ./model/theory.lp
7) ./model/enc_clingcon.lp           15) ./model/heu/conf_value.lp        23) export_files.txt
8) ./model/enc_clingcon_not_opt.lp   16) ./model/heu/heuristics.lp        24) done
#? 24
good choice!
bye
The files are
./model/enc_clingcon.lp
./model/enc_conf.lp
The export variables are
enc_clingcon
enc_conf
Are you sure of your choices?[y/n]y
Do you want to save this file set?[y/n]n
There are also these additional packages:
1) clingo_constants    3) traffic_parameters  5) set_task
2) clingo_options      4) set_instance        6) done
#? 
```

4. Here a possible sequence of choices for setting the parameters:

```bash
There are also these additional packages:
1) clingo_constants    3) traffic_parameters  5) set_task
2) clingo_options      4) set_instance        6) done
#? 1
--const horizon=
--const bound=
Do you want to export these variables?[y/n]y
There are also these additional packages:
1) clingo_constants    3) traffic_parameters  5) set_task
2) clingo_options      4) set_instance        6) done
#? 2
 --config=crafty --time-limit=600 
 --config=crafty --time-limit=600  --heuristic=Domain 
Do you want to export these variables?[y/n]y
digit -heu for selecting heuristic version:-heu
--config=crafty --time-limit=600 --heuristic=Domain
There are also these additional packages:
1) clingo_constants    3) traffic_parameters  5) set_task
2) clingo_options      4) set_instance        6) done
#? 3
current setting:
horizon-empty
time-empty
day-empty
muse-empty
instance-empty
1) horizon
2) time
3) day
4) muse
5) instance
6) done
#? 4
muse
y
current setting:
horizon-empty
time-empty
day-empty
muse::muse
instance-empty
1) horizon
2) time
3) day
4) muse
5) instance
6) done
#? 5
instance: p01 p02 p03 p04 p05
choose:: p01
current setting:
horizon-empty
time-empty
day-empty
muse::muse
instance::p01
1) horizon
2) time
3) day
4) muse
5) instance
6) done
#? 1
horizon: 600 660 720 780 840 900
choose:: 6000
input not valid
current setting:
horizon-empty
time-empty
day-empty
muse::muse
instance::p01
1) horizon
2) time
3) day
4) muse
5) instance
6) done
#? 1
horizon: 600 660 720 780 840 900
choose:: 900
current setting:
horizon::900
time-empty
day-empty
muse::muse
instance::p01
1) horizon
2) time
3) day
4) muse
5) instance
6) done
#? 
```

Write '-parallel' if you want to execute Instancesv2/ and Instancesv2_round/ concurrently.
By default the choice is set to Instancesv2/.

```bash
#? 6
bye
There are also these additional packages:
1) clingo_constants    3) traffic_parameters  5) set_task
2) clingo_options      4) set_instance        6) done
#? 4
Instancesv2_round/
Instancesv2/
Do you want to export these variables?[y/n]y
digit -round|-parallel for selecting Instancesv2_round/|both:
```

Same reasoning with '-bound'...

```bash
There are also these additional packages:
1) clingo_constants    3) traffic_parameters  5) set_task
2) clingo_options      4) set_instance        6) done
#? 5
../../Results_experiments/Task1/bounds.csv
../../Results_experiments/Task2
Do you want to export these variables?[y/n]y
digit -bound for selecting ../../Results_experiments/Task1/bounds.csv:-bound
../../Results_experiments/Task1/bounds.csv
There are also these additional packages:
1) clingo_constants    3) traffic_parameters  5) set_task
2) clingo_options      4) set_instance        6) done
#? 6
bye
```

5. Here it comes to select the **Tail** interface.

```bash
Choose the script for testing your code:
1) aux0.sh           3) info.sh          5) inst12.sh        7) inst14.sh        9) inst4.sh        11) done
2) create_file.sh    4) inst11.sh        6) inst13.sh        8) inst2.sh        10) inst5.sh
#? 6
The file choosen is inst13.sh
Continue?[y/n]y
1) total_run
2) test_run
3) done
#?
```

6. Once pressed 3, the work is...done!