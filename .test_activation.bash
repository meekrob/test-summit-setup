#!/usr/bin/env bash

# Test the suitability of the following 
# configuration script to set up the
# environment.
source activate.bashrc
######################################

# Report and count errors 
error_count=0

report_error() {
    echo $1
    error_count=$((error_count+1))
}
ERROR_FILE="error.log"
if [ -e $ERROR_FILE ]
then
    rm $ERROR_FILE
fi

echo "Error report: $(date)" > $ERROR_FILE
echo "----------------------------------" >> $ERROR_FILE

# Individual tests

# subread
echo -n "Testing for subread-align..."
if subread-align -v 2>&1 | grep -q Subread-align 
then
    echo "OK" 
else 
    report_error "ERROR: subread-align not found or couldn't be run."
    subread-align -v 2>> $ERROR_FILE
fi

# samtools
echo -n "Testing for samtools..."
if samtools 2>&1 | grep -q '^Version: 1.'
then 
    echo "OK" 
else
    report_error "ERROR: samtools not found or couldn't be run."
    samtools 2>> $ERROR_FILE
fi

# hisat
echo -n "Testing for hisat2..."
hisat2 --version > /dev/null 2>>$ERROR_FILE && echo "OK" || report_error "ERROR: hisat2 not found or couldn't be run."

# bedtools
echo -n "Testing for bedtools..."
bedtools --version 2>>$ERROR_FILE | grep -q "^bedtools v2" && echo "OK" || report_error "ERROR: bedtools not found or couldn't be run."

# trimmomatic
echo -n "Testing for trimmomatic..."
java -jar Trimmomatic-0.36/trimmomatic-0.36.jar  -version 2>>$ERROR_FILE | grep -q '^0.' && echo "OK" || report_error "ERROR: trimmomatic not found or couldn't be run."

# fastqc
echo -n "Testing for fastqc..."
fastqc --version  2>>$ERROR_FILE | grep -q '^FastQC v0.' && echo "OK" || report_error "ERROR: Fastqc not found or couldn't be run."

# Summarize
if [ $error_count -gt 0 ]
then
    echo
    echo "There was/were $error_count error(s)."
    echo "List of reported errors in $ERROR_FILE."
    cat $ERROR_FILE
    exit 1
else
    rm $ERROR_FILE
fi

