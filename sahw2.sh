#!/usr/local/bin/bash
export PATH=$PATH:/usr/local/bin/bash
usage() {
	echo -n -e "\nUsage: sahw2.sh {--sha256 hashes ... | --md5 hashes ...} -i files ...\n\n--sha256: SHA256 hashes to validate input files.\n--md5: MD5 hashes to validate input files.\n-i: Input files.\n"
}
errorM()
{
	echo -n -e "Error: Invalid arguments." >&2
}
errorType()
{
	echo -n -e "Error: Only one type of hash function is allowed." >&2
}
errorNum()
{
	echo -n -e "Error: Invalid values." >&2
}
errorHash()
{
	echo -n -e "Error: Invalid checksum." >&2 
}
errorFormat()
{
	echo -n -e "Error: Invalid file format." >&2
}
get_sha256sum()
{
	cat $1 | sha256sum | head -c 64
}
get_md5sum()
{
	cat $1 | md5sum | head -c 64
}
warningUser()
{
	echo -e "Warning: user $1 already exists."
}
if [ "${1}" == "-h" ]; then
	usage
	exit 0 
elif [ "${1}" == "--md5" ] || [ "${1}" == "--sha256" ] || [ "${1}" == "-i" ]; then
	readfile=0
	readhash=0
	filearr=()
	hasharr=()
	typearr=()
	filenum=0
	hashnum=0
	typenum=0
	for num in "$@"
	do
		if [ "$num" == "-i" ]; then
			readfile=1
			readhash=0
		elif [ "$num" == "--md5" ] || [ "$num" == "--sha256" ]; then
			readhash=1
			readfile=0
			typearr[$typenum]="$num"
			typenum=$(($typenum+1))
		elif [ "$readhash" == 1 ]; then
			hasharr[$hashnum]="$num"
			hashnum=$(($hashnum+1))
		elif [ "$readfile" == 1 ]; then
			filearr[$filenum]="$num"
			filenum=$(($filenum+1))
		fi
	done
	for num in "${typearr[@]}"
	do
		if [ "$num" != "${typearr[0]}" ]; then
			errorType
			exit 1
		fi		
	done
	if [ "$filenum" != "$hashnum" ]; then
		errorNum
		exit 1
	fi
	i=0
	for num in "${filearr[@]}"
	do
		if [ "--sha256" == "${typearr[0]}" ] && [ "$(get_sha256sum $num)" != "${hasharr[${i}]}" ]; then
			errorHash
			exit 1
		elif [ "--md5" == "${typearr[0]}" ] && [ "$(get_md5sum $num)" != "${hasharr[${i}]}" ]; then
			errorHash
			exit 1
		fi
		i=$(($i+1))
	done
	usernamel=()
	passwordl=()
	shelll=()
	groupsl=()
	accumulate=0
	for num in "${filearr[@]}"
	do
		check="$(file -b ${num} | grep 'document')"
		checkCSV="$(file -b ${num} | grep 'CSV')"
		checkJSON="$(file -b ${num} | grep 'JSON')"
		if [ "${checkCSV}" == "" ] && [ "${checkJSON}" == "" ]; then
			errorFormat
			exit 1
		fi
		if [ "${checkJSON}" != "" ]; then
			len=$(($( jq -r -e '. | length' $num )))
			for index in $(seq 0 $((len-1)));
			do
				usernamel[${accumulate}]=$( jq -r ".[$(($index))].username" $num )
				passwordl[${accumulate}]=$( jq -r ".[$(($index))].password" $num )
				shelll[${accumulate}]=$( jq -r ".[$(($index))].shell" $num )
				len1=$(($( jq -r -e ".[$(($index))].groups | length" $num )))
				if [ "${len1}" == "0" ]; then
					groupsl[${accumulate}]=""
				else	
					for index2 in $(seq 0 $((len1-1)));
					do
						temp=$( jq -r ".[$(($index))].groups[$(($index2))]" $num )
						groupsl[${accumulate}]=${groupsl[$(($accumulate))]}" "${temp}
					done
				fi
				accumulate=$(($accumulate+1))
			done	
		elif [ "${checkCSV}" != "" ]; then
			INPUT=$num
			OLDIFS=$IFS
			IFS=','
			first=1
			while IFS=',' read -r username password shell groups
			do
				if [ "${first}" == 1 ]; then
					first=0
				else
					usernamel[${accumulate}]=$username
					passwordl[${accumulate}]=$password
					shelll[${accumulate}]=$shell
					groupsl[${accumulate}]=$groups
					accumulate=$(($accumulate+1))
				fi
			done < $INPUT
			IFS=$OLDIFS
		fi
	done
	usernamelist=""
	for num in "${usernamel[@]}"
	do
		usernamelist="$usernamelist""$num "
	done
	echo "This script will create the following user(s): $usernamelist""Do you want to continue? [y/n]:"
        read input
		
	if [ $input == "\n" ] || [ $input == "n" ]; then
		exit 0
	fi
	index=0
       	for num in "${usernamel[@]}"
	do
		if grep ${usernamel[$(($index))]} > /dev/null /etc/passwd 
	       	then
			warningUser ${usernamel[$(($index))]}
		else
			if [ "${groupsl[$(($index))]}" != "" ]; then
				OIFS="$IFS"
				IFS=' '
				read -a new_string <<< "${groupsl[$(($index))]}"
				IFS="$OIFS"
				groupList=""
				for i in "${new_string[@]}"
				do
					if ! grep -q "$i" > /dev/null /etc/group 
					then 
						pw groupadd "$i"
					
					fi
						groupList="$groupList""$i "
				done
				echo "${passwordl[$(($index))]}" | pw useradd "${usernamel[$(($index))]}" -m -h 0 -G "${groupList}" -s "${shelll[$(($index))]}" > /dev/null 
			else	
				echo "${passwordl[$(($index))]}" | pw useradd "${usernamel[$(($index))]}" -m -h 0 -s "${shelll[$(($index))]}" > /dev/null
			fi
		fi
	index=$(($index+1))
	done
	exit 0
else
	errorM
	usage
	exit 1
fi



