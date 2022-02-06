The single file in this project was intended to measure disk transfers.  The original two use cases are.
1. See how much overhead anti-malaware has on disk performance
1. See the relative speed difference between two drives.

# What does it do?
The program works best if you have two different drives.  

1. It takes the names of two directories 
1. It creates the number of files that you specify of a size you specify in both of the directories passed in.
    1. You want big numbers for both.  The default is 10,000 files of 200,000B each.
1. It copies the large number of files in the 4 possible source/destination pair combinations. 
1. It writes the timings to the console and deletes the test files.

# Malware Overhead
In my case I ran a couple different variations to see what was happening
1. Drive A anti-malware enabled .  Drive B anti-malware enabled
1. Drive A anti-malware enabled .  Drive B anti-malware disabled
1. Drive A anti-malware disabled .  Drive B anti-malware enabled
1. Drive A anti-malware disabled .  Drive B anti-malware disabled
