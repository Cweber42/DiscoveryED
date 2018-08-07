#Discovery ED Import

#Determine location of input file
$file = "C:\scripts\AD-Import.csv"
$OutputDirectory="c:\scripts\DiscoveryEd"
$date = Get-date -Format MM_dd_yyy
$time = Get-date -Format HH_mm_ss_ms
$dsstudents = "DSstudents.csv"
$filefiltered = "C:\scripts\DiscoveryED\DiscoveryEDstu.csv"
#Clean up directory of old CSVs
Get-ChildItem -Recurse -Path C:\scripts\DiscoveryEd -Include *.csv | Remove-Item

#Create CSV headers and filter the student report
Import-Csv $file | Where {$_.'Site_ID' -ne '25'} | Where {$_.'Grade' -ne 'GG'} | Export-Csv $filefiltered -NoTypeInformation
echo "Site Passcode,Account Name,Site Name,First Name,Middle Initial,Last Name,UserName,Password,Student ID,Student Grade,Parent Email,Archive Flag" | Out-file -Encoding ascii $OutputDirectory\$dsstudents
#Create users
$error.insert(0,"Importing CSV")
$error.insert(0,"Import-CSV $file | ForEach-Object")
Import-CSV $filefiltered | ForEach-Object {
	$EmailDomain = "pearidgek12.com"
	$GradYearTwo = $_.GradYearTwo
	$Site_ID = $_.Site_ID
	#Student Id
		$Student_ID = $_.Student_Id
		#Delimit variable by spaces if there are any
		$Student_ID = $Student_ID.split(" ")
		#take first field of variable
		$Student_ID = $Student_ID[0]
		#GivenName
		$GivenName = $_.GivenName
		#Delimit variable by spaces if there are any
		$GivenName = $GivenName.split(" ")
		#take first field of variable
		$GivenName = $GivenName[0]
		#Delimit variable by dashes if there are any
		$GivenName = $GivenName.split("-")
		#take first field of variable
		$GivenName = $GivenName[0]
		$GivenName = (Get-Culture).TextInfo.ToLower($GivenName)
		$GivenName = (Get-Culture).TextInfo.ToTitleCase($GivenName)
	 #SurName
		$Surname = $_.Surname
		#Delimit variable by spaces if there are any
		$Surname = $Surname.split(" ")
		#take first field of variable
		$Surname = $Surname[0]
		#Delimit variable by dashes if there are any
		$Surname = $Surname.split("-")
		#take first field of variable
		$Surname = $Surname[0]
		$Surname = (Get-Culture).TextInfo.ToLower($Surname)
		$Surname = (Get-Culture).TextInfo.ToTitleCase($Surname)
	 #GRADE
		$Grade = $_.Grade
		
	$email = "$GivenName$Surname$GradYearTwo@$EmailDomain"
	$email = (Get-Culture).TextInfo.ToLower($email)
 #Output to CSV for DiscoveryED
 echo "$site_id,,,$GivenName,,$SurName,$email,[Reallyeasypasswordhereforstudents],$student_ID,$Grade,,N" | Out-file -append -Encoding ascii $OutputDirectory\$dsstudents

}

Copy-Item $OutputDirectory\$dsstudents $OutputDirectory\Upload\10000000-0000-XXXX-XXXX-000000000000_XXXXXXX-XXXX-XXXX-XXXXX-XXXXXXX_student_std_"$date"_"$time".csv

#Teacher import for DiscoveryED using the Schoology Cognos template
c:\scripts\CognosDownload-1.ps1 -report "Schoology-Users-Teachers-v.5" -savepath C:\scripts\discoveryED -ReportStudio

$teachers = "c:\scripts\DiscoveryED\Schoology-Users-Teachers-v.5.csv"
$savedir = "C:\scripts\discoveryED\"
$filteredteachers = "c:\scripts\discoveryed\filterteacher.csv"
$teacherheaders = "c:\scripts\discoveryed\teacher.csv"
$date = Get-date -Format MM_dd_yyy
$time = Get-date -Format HH_mm_ss_ms

Import-Csv $teachers | Where {$_.'Primary Building' -ne '25'} | Export-Csv $filteredteachers -NoTypeInformation
echo "Site Passcode,Account Name,Site Name,First Name,Last Name,UserName,Password,Grade,Teacher ID,Email,Assessment Access Flag,Archive Flag" | Out-file -Encoding ascii $teacherheaders

Import-Csv $filteredteachers | foreach {
    $site = $_."Primary Building"
    $site = $site.split("|")
    $site = $site[0]
    $FName = $_.Firstname
    $Lname = $_.LastName
    $TeacherID = $_.Unique_ID
    $Temail = $_.Email

    #Write to the upload file
    echo "$site,,,$fname,$lname,$Temail,[Greatpasswordstrengthehere],,$TeacherID,$Temail,,N" | Out-file -append -Encoding ascii $teacherheaders
}

Copy-Item $teacherheaders $savedir\Upload\10000000-0000-XXXXX-XXXXXX-000000000000_XXXXXXXXXXX-XXX-XXXX-XXXXX-XXXXXXXXXXXXX_teacher_"$date"_"$time".csv

c:\scripts\psftp.exe -P 22 -l Username -pw password transfer.discoveryeducation.com -b "c:\scripts\discoveryED\upload\DED-SFTP.Bat" -v -bc -batch
