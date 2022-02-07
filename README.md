# NHSCC Class Grouping Script
Script to compile SCCA classes from past results into proposed new class groupings

## How to run
* Copy results from past events "Indexed Times" tab into a .csv file. We are expecting columns for Class, CarID, Driver, Car, Index and Indexed Time.

* Save the csv in the same directory as nhscc.ps1.

* Open PowerShell (Right click start button and select PowerShell or Windows Terminal) and browse to the directory.

* Run
```
.\nhscc.ps1 -in olddata.csv -out newdata.csv
```
*olddata.csv is the filename of the csv you saved from the Indexed Times list. newdata.csv is you desired output file name (Must not exist already)*

* Drivers that were unable to be matched with a grouping will be outputted to the console

* If you get an error about script execution you need to run
```PowerShell
Set-ExecutionPolicy unrestricted
```
