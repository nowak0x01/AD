if [ $# -ne 1 ]; then
    printf "\n$0 <out file>\n"
    exit 1
fi

printf "\n################################################################\n"
printf "\ntype "

cat "$1" | grep Directory | awk -F'Directory of ' '{print $2}' | while IFS= read -r path; do

    cat "$1" | grep -iE 'consolehost_history|transcript' | awk '{print $5}' | sort -u | while IFS= read -r file; do
        printf "\"$path\\$file\" 2>nul "
    done
done
echo
printf "\n################################################################\n"
echo
