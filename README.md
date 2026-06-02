WindowsSubsystemForLinux_(WSL)_Uninstall.ps1  

<img width="257" height="174" alt="WindowsSubsystemForLinux_(WSL)" src="https://github.com/user-attachments/assets/044f8499-45ce-4c75-b390-ba9179c69131" />
<img width="386" height="274" alt="image" src="https://github.com/user-attachments/assets/6704d94d-01a4-4929-8faf-68050ef4bfc7" />


###############################################  
###############################################  
###############################################  
  
Extract_a_WIX_Package__DUP_2_EXE_2_MSI.ps1
  
# ###############################################
Prepare admin PC
# ###############################################
  
Install .NET SDK 10
  
<img width="573" height="431" alt="image" src="https://github.com/user-attachments/assets/5a755442-f23e-4e22-a086-a4748ea488b9" />
   
    
Check if 'nuget.org' as registered as source   - if not already registered
  
dotnet nuget list source  
<img width="758" height="134" alt="image" src="https://github.com/user-attachments/assets/c60a8abc-2f53-4b06-b4ce-27e50c454847" />
   
(Add it as source:      dotnet nuget add source "https://api.nuget.org/v3/index.json" --name "nuget.org"     )
  
Install WIX
    
<img width="569" height="114" alt="image" src="https://github.com/user-attachments/assets/4d6b473e-e361-4cf6-8c98-f29ee3f574ca" />
  
  
Download and install WIX Toolkit 3.1
  
<img width="597" height="462" alt="image" src="https://github.com/user-attachments/assets/14311712-8b3c-4578-bf85-376ffef86b6f" />


Download and install Orca (MSI-Database-Table editor) 
  
<img width="723" height="537" alt="image" src="https://github.com/user-attachments/assets/98a56c84-6e37-4676-bd7e-a10aa0f50244" />

<img width="875" height="74" alt="image" src="https://github.com/user-attachments/assets/6c264925-7a9e-403a-972f-34a6ac4b7bfd" />

# ###############################################
Download and extract SW-package (WIX format)
# ###############################################
https://www.dell.com/support/home/de-de/drivers/driversdetails?driverid=ny2v6  
- Dell-SupportAssist-OS-Recovery-Plugin-for-Dell-Update_NY2V6_WIN64_5.5.16.0_A00.EXE  

<img width="1075" height="388" alt="image" src="https://github.com/user-attachments/assets/4ae84825-249c-428f-a0e9-ef8c79aa9a13" />  
  
<img width="1173" height="427" alt="image" src="https://github.com/user-attachments/assets/d3f8b99c-0d94-4d2c-a492-7e243bbac8d8" />  


After RENAME you are ready to use the MSI as usual  
<img width="924" height="414" alt="image" src="https://github.com/user-attachments/assets/0f1efc03-eb4e-4f68-bd8d-1afe2f642759" />

