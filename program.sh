#!/bin/sh

datafile=data/bank_server.log

#######################
#---------functions
######################

#=================== show menu ========================
showMenu() {
   
    echo
    echo "1. Failed Login Report"
    echo "2. Query Activity Summary"
    echo "3. Slow Query Detector"
    echo "4. Transaction Report"
    echo "5. Critical Events Report"
    echo "6. User Activity Report"
    echo "7. Login/Logout Session Report"
    echo "8. Events-per-Hour Report"
    echo "9. General Log Summary"
    echo "10. Run All Reports"
    echo "0. Exit"
    echo
}


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

#=========================Task #3 ====================================
slowQueryDetector(){
	grep "\[WARNING\]" "$datafile" | grep "\[QUERY\]" | grep -i "slow" > slowQueries.tmp

	printf "\n%-15s %-15s\n" "User" "Execution time"
	while read line
	do

		user=$(echo "$line" | awk '{print $5}')
		time=$(echo "$line" | grep -io "time.*" | awk '{print $2}') 

		printf "%-15s %-15s\n" "$user" "$time"
done < slowQueries.tmp
	rm slowQueries.tmp
echo
}

#===========================Task #4==========================
transactionReport(){

	echo

	grep "\[TRANSACTION\]" "$datafile" > transactions.tmp
	grep -io "deposit.*" transactions.tmp | grep -o "\$.*" | tr -d '$' > deposits.tmp
	grep -io "withdraw.*" transactions.tmp | grep -o "\$.*" | tr -d '$' > withdrawals.tmp


	depNum=$(grep -i "deposit" transactions.tmp | wc -l )
	withNum=$(grep -i "withdraw" transactions.tmp | wc -l )
	decNum=$(grep -i "decline" transactions.tmp | wc -l )
	rollNum=$(grep -i "rollback" transactions.tmp | wc -l )

	totDep=0
	totWith=0
	
	while read line
	do

		totDep=$(echo "$totDep + $line" | bc)
	done < deposits.tmp

		while read line
	do

		totWith=$(echo "$totWith + $line" | bc)
	done < withdrawals.tmp


	echo "deposits: "$depNum""
	echo "Withdrawals: "$withNum""
	echo "declined transactions: "$decNum""
	echo "rollbacks: "$rollNum""
	echo "-----------------------"

	echo "total depostis: "$totDep""
	echo "total withdrawals: "$totWith""

	rm transactions.tmp deposits.tmp withdrawals.tmp

	echo

}



#=============================================Task 5=====================
criticalEventsReport(){
	echo

	grep "\[CRITICAL\]" "$datafile" > criticals.tmp


	printf "%-20s %s\n" "Timestamp" "Message" 
	while read line
	do

		timestamp=$(echo "$line" | awk -F'[][ ]+' '{print $2,$3}')
		message=$(echo "$line" | sed 's/^.*\] - //')
		printf "%-20s %s\n" "$timestamp" "$message"
	done < criticals.tmp

	
	
	rm criticals.tmp
	
	echo

}


#===============================Task #6=============
userActivityReport(){
	echo 
	
	read -p "Enter the username: " username
	grep "\["$username"\]" "$datafile" > user.tmp

	if [ $(wc -l < user.tmp) -eq 0 ]; then
		echo "user not found"
	else
		echo
		cat user.tmp | sort
	fi



	rm user.tmp
	echo
}

#===========================Task #7====================
loginLogoutSessionReport(){
	echo
	grep -o "\[SESSION_[0-9]*\]" "$datafile" | tr -d '[]' | sort -u > sessionsID.tmp
	
	grep "\[SESSION_[0-9]*\]" "$datafile" | grep "\[AUTH\]" > sessions.tmp

	while read session
	do
		login=$(grep "$session" sessions.tmp | grep -i "successful.*login" | awk -F'[][ ]+' '{print $2,$3}')
		logout=$(grep "$session" sessions.tmp | grep -i "log.*out" | awk -F'[][ ]+' '{print $2,$3}')

		if [ -n "$logout" ]; then

			login_epoch=$(date -d "$login" +%s)
			logout_epoch=$(date -d "$logout" +%s)
			diff=$((logout_epoch - login_epoch))
			duration=$(printf "%02d:%02d:%02d" $((diff/3600)) $((diff%3600/60)) $((diff%60)))
		else
			duration=0
		fi

		if [ -n "$login" ]; then
			
			echo "$session: "
			echo 
			echo "Login Time: "$login""
			echo "Logout Time: "$logout""
			echo "duration: "$duration""
			echo "--------------------------------------"
			echo
		fi
	done < sessionsID.tmp
	
	rm sessions.tmp sessionsID.tmp

	echo
}
	
#==================================Task #8====================
ephReport(){
	echo  
	grep -o " [0-9][0-9]:" "$datafile" | tr -d ' :' | sort -u > hours.tmp

	printf "%-7s %-7s\n" "Hour" "Freq."
	while read hour
	do
		freq=$(grep "$hour:[0-9][0-9]:[0-9][0-9]\]" "$datafile" | wc -l)

		printf "%-7s %-7s\n" "$hour" "$freq"
	done < hours.tmp


	rm hours.tmp
	echo

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
	showMenu
	read -p "Enter your choice: " choice
	
	case "$choice" in
		1) failedLoginReport;;
		2) queryActivitySummary;;
		3) slowQueryDetector;;
		4) transactionReport;;
		5) criticalEventsReport;;
		6) userActivityReport;;
		7) loginLogoutSessionReport;;
		8) ephReport;;
		9) echo nine;;
		0) echo exiting...;;
		*) echo invalid menu choice;;
	esac
done

