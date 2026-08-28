#!/bin/sh

datafile="$1"

#######################
#---------functions
######################



#==================Task #1 ============================
failedLoginReport(){
	grep -i '\[error\].*\[auth\].*failed login attempt' "$datafile" > failedLogin.tmp

	printf "number of failed login attempts: "
	wc -l < failedLogin.tmp
	echo ""

	cut -d' ' -f5,6 failedLogin.tmp | sort | uniq -c > list.tmp


	printf "Freq       USER        IP\n"
	cat list.tmp
	echo ""

	cut -d' ' -f6 failedLogin.tmp | sort | uniq -c | awk '$1 >= 3' > brute.tmp

	if [ $(wc -l < brute.tmp) -ne 0 ]; then
		printf "Possible brute-force sources:\n"
		cat brute.tmp
	else
		echo "No Possible brute-force sources detected."
	fi
	
	echo ""

	rm failedLogin.tmp list.tmp brute.tmp
}


#=======================Task #2 ===============================
queryActivitySummary(){
	
	grep "\[QUERY\]" "$datafile" > queryEvents.tmp
	printf "Total Number of QUERY events: "
	wc -l < queryEvents.tmp
	echo ""

	printf "Query type:\n"

	printf "SELECT: "
	grep "SELECT" queryEvents.tmp | wc -l 
	
	printf "UPDATE: "
	grep "UPDATE" queryEvents.tmp | wc -l
	
	printf "INSERT: "
	grep "INSERT" queryEvents.tmp | wc -l
	
	printf "DELETE: "
	grep "DELETE" queryEvents.tmp | wc -l
	
	echo ""

	rm queryEvents.tmp

}


###################
#-----main program
###################

#
# while loop for the menu
#
choice=-1
while [ "$choice" -ne 0 ]
do
	read -p "Enter your choice: " choice
	
	case "$choice" in
		1) failedLoginReport;;
		2) queryActivitySummary;;
		3) echo three;;
		4) echo four;;
		5) echo five;;
		6) echo six;;
		7) echo seven;;
		8) echo eight;;
		9) echo nine;;
		0) echo exiting...;;
		*) echo invalid menu choice;;
	esac
done

