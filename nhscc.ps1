<#
.NOTES
   Created on: 2/7/22
   Created by: Matt Simmons (matt.simmons@gmail.com)
.Synopsis
   NHSCC Potential New Class Grouping Tool
.DESCRIPTION
   Takes data from past results and groups into proposed new class structure
.EXAMPLE
   nhscc.ps1 -in olddata.csv -out newdata.csv
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({
            if ( Test-Path $_ ) { $true }
            else { throw "File $_ does not exist" }
     })
    ]
    [string]$in = "",
    
    [Parameter(Mandatory=$true)]
    [ValidateScript({
            if (!(Test-Path $_)) { $true } 
            else { throw "File $_ already exists, please pick a different name" }
        
     })
    ]
    [string]$out = ""
)

# Import the input CSV and save to results object

$results = import-csv $in

# Define class groupings in a hash table

[hashtable]$classes = @{
    Street1 = @("SS", "AS", "BS", "FS");
    Street2 = @("CS", "DS", "ES", "GS", "HS", "SSC");
    ST = @("STS", "STX", "STR", "STU", "STH");
    Provisional = @("CAMC", "CAMT", "CAMS", "XSA", "XSB", "EV");
    Race1 = @("SSP", "ASP", "BSP", "CSP", "DSP", "ESP", "FSP", "SMF", "SM", "SSM", "SSR");
    Race2 = @("XP", "BP", "CP", "DP", "EP", "FP", "AM", "BM", "CM", "DM", "EM", "FM");
    Vintage = @("");
}

<# 
Iterate over each entry in results and lookup class in the hash table adding a NoteProperty to each driver named "New Class"
I strip the numbers off using RegEx and add an asterix in front for use in the like comparison
This is to ensure that the classes must match fully at only the end to avoid matching SS with SSR for example
Stripped and Newclass variables are set to null at the end of every loop to avoid bad data if a class can't be found
In the event of a class not being able to be matched the driver with the issue will be outputted to the console for investigation
#>

foreach($result in $results){
    $stripped = $result.CarID -replace '[^a-zA-Z-]',''
    $stripped = $stripped.insert(0, "*")
    $newclass = $classes.Keys | Where-Object {$classes["$_"] -like $stripped}
    if(!$newclass){
        write-output "Error in classing $($result.driver)"
    }
    elseif($result.Class -ne "VIN"){
        $result | Add-Member -Type NoteProperty -Name "New Class" -Value $newclass
    }
    else{
        $result | Add-Member -Type NoteProperty -Name "New Class" -Value "Vintage"
    }
    $stripped = $null
    $newclass = $null
}

# Grab the list of New Classes from the Hash Table and sort A-Z

$sortedclass = $classes.Keys | Sort-Object

<# 
Loop over each class in the sorted list and grab the data from the Results object. Select which columns to export, sort by Indexed Time
And then output to the csv file inputted in the out parameters. After each class we will insert a blank line to improve readability
#>

foreach($class in $sortedclass){
    $results | Where-Object -Property "New Class" -eq $class | select "New Class", "CarID", "Driver", "Car", "PAX Index", "PAX Time" | sort-object "PAX Time" | Export-Csv -append -Force -NoTypeInformation -Path $out
    Add-Content -Path $out -Value (',' * 6)
}
