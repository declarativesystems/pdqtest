FROM microsoft/windowsservercore

RUN powershell -command "& { (New-Object Net.WebClient).DownloadFile('https://pm.puppet.com/puppet-agent/2018.1.4/5.5.6/repos/windows/puppet-agent-5.5.6-x64.msi', 'c:\puppet_agent.msi') }"
RUN msiexec /qn /norestart /i c:\puppet_agent.msi
RUN mkdir C:\testcase
RUN mkdir C:\spec
RUN mkdir C:\spec\fixtures
RUN mkdir C:\spec\fixtures\hieradata


VOLUME C:\\testcase

# the path from "command prompt with puppet"
ENV PATH="C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\facter\bin;C:\Program Files\Puppet Labs\Puppet\hiera\bin;C:\Program Files\Puppet Labs\Puppet\mcollective\bin;C:\Program Files\Puppet Labs\Puppet\bin;C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin;C:\Program Files\Puppet Labs\Puppet\sys\tools\bin;C:\Program Files\Docker\Docker\Resources\bin;C:\tools\ruby25\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\ProgramData\chocolatey\bin;C:\Program Files\Git\cmd;C:\Program Files\Puppet Labs\Puppet\bin;c:\windows:\c:\windows\system32;C:\Program Files (x86)\vim\vim80"

# install chocolatey
RUN @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# install a text editor 
RUN choco install vim /y

ADD pats.ps1 c:\\windows\\pats.ps1

# we dont have systemd/sysvinit on windows so just use notepad to keep the container open
ENTRYPOINT notepad
