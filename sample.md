<div class="outer">
<div class="middle">
<div class="inner">
<div style="float:right;margin-right: 50px;">
<img align="right" src=./dataplat.png alt="dbatools logo">
</div>

<font class="sup">Start-DbaMigration</font>


<div style="display: table;color: gray;font-size: 24px;">
<div style="display: table-row;">
<div style="display: table-cell;">Developed by Chrissy LeMaire (@cl) | Andreas Jordan (@jordaninix), ordanix.de</div>
</div>
<div style="display: table-row;">
<div style="display: table-cell;">Works on Windows, Linux, macOS</div>
</div>
</div>

<h2>Synopsis</h2>
<div>
Migrates SQL Server *ALL* databases, logins, database mail profiles/accounts, credentials, SQL Agent objects, linked servers, Central Management Server objects, server configuration settings (sp_configure), user objects in systems databases, system triggers and backup devices from one SQL Server to another.
</div>

<h2>Example</h2>
```
Start-DbaMigration -Source sqlserver\instance -Destination sqlcluster -DetachAttach Start-DbaMigration -Source sqlserver\instance -Destination sqlcluster -DetachAttach
```
</div>
</div>
</div>
<div class="navbar">dbatools.io</div>