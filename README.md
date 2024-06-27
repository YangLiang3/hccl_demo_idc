Support all_reduce/all_gather/all2all/reduce_scatter collectives, for example:  
./start.sh  "8cards"        "all_reduce"   //8cards in one node
./start.sh  "16cards"        "all_reduce"      
./start.sh  "16cards_group"  "all_reduce"
./start.sh  "64cards"        "all_reduce"
./start.sh  "64cards_group"  "all_reduce"
./start.sh  "128cards"       "all_reduce"
./start.sh  "128cards_group" "all_reduce"
./start.sh  "256cards"       "all_reduce"
./start.sh  "256cards_group" "all_reduce"
