FROM mcr.microsoft.com/windows:1809 as dll_source
FROM microsoft/iis

COPY --from=dll_source /windows/system32/oledlg.dll /windows/system32/oledlg.dll 
COPY --from=dll_source /windows/syswow64/oledlg.dll /windows/syswow64/oledlg.dll 


RUN ["powershell.exe", "Install-WindowsFeature NET-Framework-45-ASPNET"]  
RUN ["powershell.exe", "Install-WindowsFeature Web-Asp-Net45"]
WORKDIR c:/temp

COPY  ./Resources/CR13SP29MSI64_0-10010309.MSI .
RUN powershell.exe -Command Start-Process c:\temp\CR13SP29MSI64_0-10010309.msi -ArgumentList '/quiet /l*v c:\temp\install64.log' -Wait
RUN del "CR13SP29MSI64_0-10010309.MSI"


COPY ./bin/app.publish /inetpub/wwwroot


